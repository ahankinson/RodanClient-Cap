@import <AppKit/CPWindowController.j>

@global RodanWillCreateProjectNotification

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
    var projectInfo = @{
        "projectName": [projectName objectValue],
        "projectDescription": [projectDescription objectValue]
        };

    [[CPNotificationCenter defaultCenter] postNotificationName:RodanWillCreateProjectNotification
                                                        object:projectInfo];

    // [projectController newProjectWithName:pname andDescription:pdesc];

    [self close];
}

@end