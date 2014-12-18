@import <AppKit/CPWindowController.j>


@implementation NewProjectWindowController : CPWindowController
{
    @outlet     CPTextField          projectName;
    @outlet     CPTextField          projectCreator;
    @outlet     CPTextField          projectDescription;
}

- (id)init
{
    var localizedCibFile = [[CPBundle mainBundle] bundleLocale] + @".lproj/NewProjectWindow";
    if (self = [self initWithWindowCibName:localizedCibFile
                                     owner:self])
    {
    }

    return self;
}

- (@action)createProject:(id)aSender
{
    // pass
}

@end