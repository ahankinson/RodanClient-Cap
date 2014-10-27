@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Models/Project.j"
@import "Controllers/ProjectViewController.j"
@import "Controllers/LoginViewController.j"
@import "Controllers/WorkflowViewController.j"
@import "Controllers/AuthenticationController.j"
@import "Controllers/ServerController.j"

RodanSetRoutesNotification = @"RodanSetRoutesNotification";
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
    [[WLRemoteLink sharedRemoteLink] setDelegate:serverController];

    var aView = [loginViewController view];
    [aView setFrame:[[theWindow contentView] frame]];
    [[theWindow contentView] addSubview:aView];
}

- (void)awakeFromCib
{
    [theWindow setFullPlatformWindow:YES];
}

@end
