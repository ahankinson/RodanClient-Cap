@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Models/Project.j"
@import "Controllers/ProjectViewController.j"
@import "Controllers/LoginViewController.j"
@import "Controllers/WorkflowViewController.j"
@import "Controllers/AuthenticationController.j"
@import "Controllers/ServerController.j"

RodanDidFinishLaunching = @"RodanDidFinishLaunching";

RodanSetRoutesNotification = @"RodanSetRoutesNotification";
RodanRoutesDidFinishLoadingNotification = @"RodanRoutesDidFinishLoadingNotification";

RodanMustLogInNotification = @"RodanMustLogInNotification";
RodanCannotLogInNotification = @"RodanCannotLogInNotification";
RodanDidLogInNotification = @"RodanDidLogInNotification";
RodanAuthenticationSuccessNotification = @"RodanAuthenticationSuccessNotification";


@implementation AppController : CPObject
{
    @outlet     CPWindow                    theWindow;
    @outlet     LoginViewController         loginViewController;
    @outlet     ServerController            serverController          @accessors(readonly);
    @outlet     AuthenticationController    authenticationController;
    @outlet     ProjectViewController       projectViewController;

                CPScrollView                contentScrollView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var debug = [[CPBundle mainBundle] objectForInfoDictionaryKey:@"Debug"];

    if (!debug)
    {
        CPLogRegister(CPLogConsole, "info");
    }
    else
    {
        CPLogRegister(CPLogConsole, "debug");
        CPLog.debug(@"Debug log level set.");
    }

    /*
        Start the Rodan startup process
    */

    // Register the callback methods for when the routes have finished loading.
    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkAuthenticationStatus:)
                                                 name:RodanRoutesDidFinishLoadingNotification
                                               object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLoginWindowView:)
                                                 name:RodanMustLogInNotification
                                               object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showProjectChooserView:)
                                                 name:RodanAuthenticationSuccessNotification
                                               object:nil];

    // Establish the server routes.
    // NB: These calls are asynchronous.
    [serverController establishRoutes];

    // while we're waiting, set up some views.
    var contentView = [theWindow contentView];
    [contentView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    contentScrollView = [[CPScrollView alloc] initWithFrame:[contentView bounds]];
    [contentScrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    [contentView setSubviews:[contentScrollView]];

    CPLog.debug(@"Application finished launching");
}

/**
 * @brief Checks the user's authentication status against the server
 */
- (void)checkAuthenticationStatus:(CPNotification)aNotification
{
    [authenticationController checkAuthenticationStatus];
}

- (void)showLoginWindowView:(CPNotification)aNotification
{
    CPLog.debug(@"Show Login Window View");

    var loginView = [loginViewController view];

    [contentScrollView setDocumentView:loginView];
    [loginView setAutoresizingMask:CPViewWidthSizable];
    [loginView setFrame:[contentScrollView bounds]];
}

- (void)showProjectChooserView:(CPNotification)aNotification
{
    CPLog.debug(@"Show Project Chooser View");

    var projectView = [projectViewController view];

    [contentScrollView setDocumentView:projectView];
    [projectView setAutoresizingMask:CPViewWidthSizable];
    [projectView setFrame:[contentScrollView bounds]];
}

- (void)awakeFromCib
{
    [theWindow setFullPlatformWindow:YES];
}

@end
