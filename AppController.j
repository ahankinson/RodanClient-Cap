@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Models/Project.j"
@import "Categories/CPButtonBar+PopupButton.j"
@import "Categories/CPURLConnection+AsyncBlock.j"
@import "Controllers/LoadingViewController.j"
@import "Controllers/ProjectViewController.j"
@import "Controllers/LoginViewController.j"
@import "Controllers/WorkflowViewController.j"
@import "Controllers/AuthenticationController.j"
@import "Controllers/ServerController.j"

RodanDidFinishLaunching = @"RodanDidFinishLaunching";

RodanRoutesWillStartLoadingNotification = @"RodanRoutesWillStartLoadingNotification";
RodanSetRoutesNotification = @"RodanSetRoutesNotification";
RodanRoutesDidFinishLoadingNotification = @"RodanRoutesDidFinishLoadingNotification";

RodanMustLogInNotification = @"RodanMustLogInNotification";
RodanCannotLogInNotification = @"RodanCannotLogInNotification";
RodanFailedLogInNotification = @"RodanFailedLogInNotification";
RodanDidLogInNotification = @"RodanDidLogInNotification";
RodanDidLogOutNotification = @"RodanDidLogOutNotification";
RodanAuthenticationSuccessNotification = @"RodanAuthenticationSuccessNotification";

RodanMenubarAndToolbarAreReadyNotification = @"RodanMenubarAndToolbarAreReadyNotification";


@implementation AppController : CPObject
{
    @outlet     CPWindow                    theWindow;
    @outlet     CPToolbar                   theToolbar;
    @outlet     LoadingViewController       loadingViewController;
    @outlet     LoginViewController         loginViewController;
    @outlet     ServerController            serverController          @accessors(readonly);
    @outlet     AuthenticationController    authenticationController;
    @outlet     ProjectViewController       projectViewController;
    @outlet     CPArrayController           projectArrayController    @accessors;

                CPScrollView                contentScrollView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var debug = [[CPBundle mainBundle] objectForInfoDictionaryKey:@"Debug"];

    if (!debug)
    {
        CPLogRegister(CPLogConsole, "info");

        // this gets annoying on a dev machine.
        window.onbeforeunload = function()
        {
            return "This will terminate the Application. Are you sure you want to leave?";
        }

    }
    else
    {
        CPLogRegister(CPLogConsole, "debug");
        CPLog.debug(@"Debug log level set.");
    }

    /*
        Start the Rodan startup process
    */

    // hide the toolbar until we're authenticated
     [CPMenu setMenuBarVisible:NO];
     [theToolbar setVisible:NO];

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
                                             selector:@selector(showProjectView:)
                                                 name:RodanMenubarAndToolbarAreReadyNotification
                                               object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:loadingViewController
                                             selector:@selector(updateProgressAndStatus:)
                                                 name:RodanRoutesWillStartLoadingNotification
                                               object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:loadingViewController
                                             selector:@selector(updateProgressAndStatus:)
                                                 name:RodanRoutesDidFinishLoadingNotification
                                               object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enableMenubarAndToolbarOnAuthentication:)
                                                 name:RodanAuthenticationSuccessNotification
                                               object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleanUpApplicationAfterLogout:)
                                                 name:RodanDidLogOutNotification
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

    var loadingView = [loadingViewController view],
        loadingViewMidX = CGRectGetWidth([loadingView frame]) / 2,
        loadingViewMidY = CGRectGetHeight([loadingView frame]) / 2,
        scrollViewCenter = [contentScrollView center];

    [loadingView setFrameOrigin:CGPointMake(scrollViewCenter.x - loadingViewMidX, scrollViewCenter.y - loadingViewMidY)];
    [loadingView setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];

    [contentScrollView setDocumentView:loadingView];
    // [loadingView setAutoresizingMask:CPViewWidthSizable];
    // [loadingView setFrame:[contentScrollView bounds]];


    CPLog.debug(@"Application finished launching");
}

- (void)enableMenubarAndToolbarOnAuthentication:(CPNotification)aNotification
{
     [CPMenu setMenuBarVisible:YES];
     [theToolbar setVisible:YES];

     [[CPNotificationCenter defaultCenter] postNotificationName:RodanMenubarAndToolbarAreReadyNotification
                                                         object:nil];
}

- (void)cleanUpApplicationAfterLogout:(CPNotification)aNotification
{
    [CPMenu setMenuBarVisible:NO];
    [theToolbar setVisible:NO];

    // after cleanup trigger the log-in process again.
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanMustLogInNotification
                                                        object:nil];
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

    var loginView = [loginViewController view],
        loginViewMidX = CGRectGetWidth([loginView frame]) / 2,
        loginViewMidY = CGRectGetHeight([loginView frame]) / 2,
        scrollViewCenter = [contentScrollView center];

    [loginView setFrameOrigin:CGPointMake(scrollViewCenter.x - loginViewMidX, scrollViewCenter.y - loginViewMidY)];
    [loginView setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    [contentScrollView setDocumentView:loginView];
}

- (void)showProjectView:(CPNotification)aNotification
{
    CPLog.debug(@"Show Project Chooser View");
    /*
        The notification calls this *after* the menubar and toolbar have been
        drawn, since their presence affects the drawing of any subviews.
    */
    var projectView = [projectViewController view];
    [projectView setFrame:[contentScrollView bounds]];
    [projectView setAutoresizingMask:CPViewWidthSizable];
    [contentScrollView setDocumentView:projectView];
}

- (void)awakeFromCib
{
    [theWindow setFullPlatformWindow:YES];
}

@end
