@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Models/Project.j"
@import "Controllers/ProjectViewController.j"
@import "Controllers/LoginViewController.j"
@import "Controllers/WorkflowViewController.j"
@import "Controllers/AuthenticationController.j"
@import "Controllers/ServerController.j"

RodanSetRoutesNotification = @"RodanSetRoutesNotification";
RodanRoutesHaveLoadedNotification = @"RodanRoutesHaveLoadedNotification";

RodanMustLogInNotification = @"RodanMustLogInNotification";
RodanCannotLogInNotification = @"RodanCannotLogInNotification";
RodanDidLogInNotification = @"RodanDidLogInNotification";


@implementation AppController : CPObject
{
    @outlet     CPWindow                    theWindow;
    @outlet     LoginViewController         loginViewController;
    @outlet     ServerController            serverController;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    CPLogRegister(CPLogConsole);
}

- (void)awakeFromCib
{
    [theWindow setFullPlatformWindow:YES];
}

@end
