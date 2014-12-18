/*
 * AppController.j
 * RodanNext
 *
 * Created by You on October 2, 2014.
 * Copyright 2014, Your Company All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Categories/CPBundle+Localizable.j"

@import "AppController.j"

/*
    This actually uses a customized version of the main method
    for localized applications, defined in CPBundle+Localizable.j
*/
function main(args, namedArgs)
{
    CPApplicationMain(args, namedArgs);
}
