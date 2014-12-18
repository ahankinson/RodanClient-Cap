#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Localize.py - Incremental localization on XCode projects
# João Moreno 2009
# http://joaomoreno.com/

# Modified by Steve Streeting 2010 http://www.stevestreeting.com
# Changes
# - Use .strings files encoded as UTF-8
#   This is useful because Mercurial and Git treat UTF-16 as binary and can't
#   diff/merge them. For use on iPhone you can run an iconv script during build to
#   convert back to UTF-16 (Mac OS X will happily use UTF-8 .strings files).
# - Clean up .old and .new files once we're done

# Modified by Antoine Mercadal
# Changes
# - Support for Cappuccino
# - Support for xib string generation /  injection

from codecs import open
from re import compile
from copy import copy
import os
from optparse import OptionParser

re_translation = compile(r'^"(.+)" = "(.+)";$')
re_comment_single = compile(r'^/\*.*\*/$')
re_comment_start = compile(r'^/\*.*$')
re_comment_end = compile(r'^.*\*/$')


class LocalizedString():
    def __init__(self, comments, translation):
        self.comments, self.translation = comments, translation
        self.key, self.value = re_translation.match(self.translation).groups()

    def __unicode__(self):
        return u'%s%s\n' % (u''.join(self.comments), self.translation)


class LocalizedFile():
    def __init__(self, fname=None, auto_read=False, encoding='utf_8'):
        self.fname = fname
        self.encoding = encoding
        self.strings = []
        self.strings_d = {}

        if auto_read:
            self.read_from_file(fname)

    def read_from_file(self, fname=None):
        fname = self.fname if fname == None else fname
        try:
            f = open(fname, encoding=self.encoding, mode='r')
        except:
            print 'File %s does not exist.' % fname
            exit(-1)

        line = f.readline()
        while line:
            comments = [line]

            if not re_comment_single.match(line):
                while line and not re_comment_end.match(line):
                    line = f.readline()
                    comments.append(line)

            line = f.readline()
            if line and re_translation.match(line):
                translation = line
            else:
                raise Exception('invalid file')

            line = f.readline()
            while line and line == u'\n':
                line = f.readline()

            string = LocalizedString(comments, translation)
            self.strings.append(string)
            self.strings_d[string.key] = string

        f.close()

    def save_to_file(self, fname=None):
        fname = self.fname if fname == None else fname
        try:
            f = open(fname, encoding=self.encoding, mode='w')
        except:
            print 'Couldn\'t open file %s.' % fname
            exit(-1)

        for string in self.strings:
            f.write(string.__unicode__())

        f.close()

    def merge_with(self, new):
        merged = LocalizedFile()

        for string in new.strings:
            if self.strings_d.has_key(string.key):
                new_string = copy(self.strings_d[string.key])
                new_string.comments = string.comments
                string = new_string

            merged.strings.append(string)
            merged.strings_d[string.key] = string

        return merged


def merge(merged_fname, old_fname, new_fname, encoding='utf_8'):
    try:
        old = LocalizedFile(old_fname, auto_read=True, encoding=encoding)
        new = LocalizedFile(new_fname, auto_read=True, encoding=encoding)
        merged = old.merge_with(new)
        merged.save_to_file(merged_fname)
    except Exception as ex:
        print 'Error: input files have invalid format. %s' % ex

STRINGS_FILE = 'Localizable.strings'
DEFAULT_LANGUAGE = 'en'


def localize(path, routine):
    languages = [name for name in os.listdir(path) if name.endswith('.lproj') and os.path.isdir(path)]
    languages = map(lambda x: "Resources/%s" % x, languages)
    findCommand = 'find . ! -path "*/ModulesSources/*" ! -path "*/Libraries/*" ! -path "*/Build/*" -name "*.j"'

    for language in languages:
        original = merged = language + os.path.sep + STRINGS_FILE

        old = original + '.old'
        new = original + '.new'

        if os.path.isfile(original):
            os.rename(original, old)
            os.system('genstrings -q -s %s -o "%s" `%s`' % (routine, language, findCommand))
            os.system('iconv -f UTF-16 -t UTF-8 "%s" > "%s"' % (original, new))
            merge(merged, old, new)
        else:
            os.system('genstrings -q -s %s -o "%s" `%s`' % (routine, language, findCommand))
            os.rename(original, old)
            os.system('iconv -f UTF-16 -t UTF-8 "%s" > "%s"' % (old, original))

        os.system("plutil -convert xml1 %s/Localizable.strings -o %s/Localizable.xstrings" % (language, language))

        xibs = [name for name in os.listdir(language) if name.endswith('.xib')]
        xibs = map(lambda x: "%s/%s" % (language, x), xibs)

        for xib in xibs:
            print " * working on %s" % xib
            bname = os.path.basename(xib)
            bname_noext = os.path.splitext(bname)[0]

            base_xib = os.path.join("Resources", bname)

            if not os.path.isfile(base_xib):
                base_xib = os.path.join("Resources", "%s.lproj" % DEFAULT_LANGUAGE, bname)

            xib_original = xib_merged = language + os.path.sep + bname_noext + ".strings"
            xib_old = xib_original + '.old'
            xib_new = xib_original + '.new'

            if os.path.isfile(xib_original):
                os.rename(xib_original, xib_old)
                os.system('ibtool --generate-strings-file %s/%s.strings %s' % (language, bname_noext, base_xib))
                os.system('iconv -f UTF-16 -t UTF-8 "%s" > "%s"' % (xib_original, xib_new))
                merge(xib_merged, xib_old, xib_new)
            else:
                os.system('ibtool --generate-strings-file %s/%s.strings %s' % (language, bname_noext, base_xib))
                os.rename(xib_original, xib_old)
                os.system('iconv -f UTF-16 -t UTF-8 "%s" > "%s"' % (xib_old, xib_original))

            os.system('ibtool --strings-file %s/%s.strings --write %s %s' % (language, bname_noext, xib, base_xib))
            if os.path.isfile(xib_new):
                os.remove(xib_new)
            if os.path.isfile(xib_old):
                os.remove(xib_old)

        if os.path.isfile(old):
            os.remove(old)
        if os.path.isfile(new):
            os.remove(new)

if __name__ == '__main__':
    routine = "CPLocalizedString"

    parser = OptionParser()
    parser.add_option("-s", "--routine",
                        dest="routine",
                        help="set the routine to use",
                        metavar="ROUTINE")
    options, args = parser.parse_args()

    if options.routine:
        routine = options.routine

    if os.path.isfile("Categories/CPBundle+Localizable.j"):
        os.rename("Categories/CPBundle+Localizable.j", "Categories/CPBundle+Localizable.sj")
    localize(os.getcwd() + "/Resources/", routine=routine)
    if os.path.isfile("Categories/CPBundle+Localizable.sj"):
        os.rename("Categories/CPBundle+Localizable.sj", "Categories/CPBundle+Localizable.j")
