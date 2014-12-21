@import <AppKit/CPWindowController.j>


@implementation NewProjectWindowController : CPWindowController
{
    @outlet     CPTextField          projectName;
    @outlet     CPTextField          projectCreator;
    @outlet     CPTextField          projectDescription;
    @outlet     ProjectController    projectController;
    @outlet     ServerController     serverController;
}

- (id)init
{
    var localizedCibFile = [[CPBundle mainBundle] bundleLocale] + @".lproj/NewProjectWindow";
    if (self = [self initWithWindowCibName:localizedCibFile owner:self])
    {
    }

    return self;
}

- (void)windowDidLoad
{
    CPLog.debug(@"New Project Window Will Load");

    [projectCreator setObjectValue:[[serverController activeUser] username]];
}

- (@action)createProject:(id)aSender
{
    var pname = [projectName objectValue],
        pdesc = [projectDescription objectValue];

    // [projectController newProjectWithName:pname andDescription:pdesc];

    [self close];
}

@end