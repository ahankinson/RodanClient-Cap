@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Models/Output.j"
@import "Models/Project.j"
@import "Models/Resource.j"
@import "Models/ResourceType.j"
@import "Models/RunJob.j"
@import "Models/User.j"
@import "Models/Workflow.j"
@import "Categories/CPButtonBar+PopupButton.j"
@import "Categories/CPURLConnection+AsyncBlock.j"
@import "Categories/WLRemoteObject+RemotePath.j"
@import "Controllers/ProjectController.j"
@import "Controllers/ServerController.j"
@import "Controllers/NewProjectWindowController.j"
@import "Controllers/OpenProjectWindowController.j"
@import "Controllers/LoadingViewController.j"
@import "Controllers/LoginViewController.j"
@import "Controllers/WorkflowViewController.j"
@import "Controllers/AuthenticationController.j"
@import "Controllers/ServerController.j"

#pragma mark Launch Notifications

RodanDidFinishLaunching = @"RodanDidFinishLaunching";
RodanServerConfigurationHasReturnedNotification = @"RodanServerConfigurationHasReturnedNotification";
RodanClientConfigurationHasFinishedNotification = @"RodanClientConfigurationHasFinishedNotification";
RodanClientConfigurationWillStartNotification = @"RodanClientConfigurationWillStartNotification";

#pragma mark Authentication Notifications

RodanMustLogInNotification = @"RodanMustLogInNotification";
RodanCannotLogInNotification = @"RodanCannotLogInNotification";
RodanFailedLogInNotification = @"RodanFailedLogInNotification";
RodanDidLogInNotification = @"RodanDidLogInNotification";
RodanDidLogOutNotification = @"RodanDidLogOutNotification";
RodanAuthenticationSuccessNotification = @"RodanAuthenticationSuccessNotification";

#pragma mark Application Status Notifications

RodanServerWentAwayNotification = @"RodanServerWentAwayNotification";
RodanMenubarAndToolbarAreReadyNotification = @"RodanMenubarAndToolbarAreReadyNotification";
RodanRefreshProjectListNotification = @"RodanRefreshProjectListNotification"
RodanDidLoadProjectsNotification = @"RodanDidLoadProjectsNotification";


@implementation AppController : CPObject
{
    @outlet     CPWindow                    theWindow;
    @outlet     CPToolbar                   theToolbar;
    @outlet     LoadingViewController       loadingViewController;
    @outlet     LoginViewController         loginViewController;
    @outlet     ServerController            serverController          @accessors(readonly);
    @outlet     AuthenticationController    authenticationController;
    @outlet     NewProjectWindowController  newProjectWindowController;
    @outlet     CPArrayController           projectArrayController    @accessors;
    @outlet     CPView                      blankApplicationView;

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
                                                 name:RodanClientConfigurationHasFinishedNotification
                                               object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLoginWindowView:)
                                                 name:RodanMustLogInNotification
                                               object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:loadingViewController
                                             selector:@selector(updateProgressAndStatus:)
                                                 name:RodanClientConfigurationWillStartNotification
                                               object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:loadingViewController
                                             selector:@selector(updateProgressAndStatus:)
                                                 name:RodanClientConfigurationHasFinishedNotification
                                               object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:loadingViewController
                                             selector:@selector(updateProgressAndStatus:)
                                                 name:RodanServerWentAwayNotification
                                               object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enableMenubarAndToolbarOnAuthentication:)
                                                 name:RodanAuthenticationSuccessNotification
                                               object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cleanUpApplicationAfterLogout:)
                                                 name:RodanDidLogOutNotification
                                               object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serverWentAway:)
                                                 name:RodanServerWentAwayNotification
                                               object:nil];

    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayBlankApplicationView:)
                                                 name:RodanMenubarAndToolbarAreReadyNotification
                                               object:nil];

    // Establish the server routes.
    // NB: This call is asynchronous.
    [serverController configureFromServer];

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

#pragma mark Notification Handlers

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

- (void)displayBlankApplicationView:(CPNotification)aNotification
{
    [blankApplicationView setFrame:[contentScrollView bounds]];
    [blankApplicationView setAutoresizingMask:CPViewWidthSizable];
    [contentScrollView setDocumentView:blankApplicationView];
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

- (void)serverWentAway:(CPNotificationCenter)aNotification
{
    var alert = [[CPAlert alloc] init];

    [alert setMessageText:@"The Rodan server could not be contacted"];
    [alert setDelegate:self];
    [alert setAlertStyle:CPCriticalAlertStyle];
    [alert addButtonWithTitle:@"Dismiss"];
    [alert runModal];
}

- (void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
}

#pragma mark Action Handlers


- (@action)activateProjectView:(id)aSender
{
    [self _showProjectView];
}

- (void)awakeFromCib
{
    [theWindow setFullPlatformWindow:YES];
}

// #pragma mark - Private Implementation

// - (void)_showProjectView
// {
//     var projectView = [projectViewController view];
//     [projectView setFrame:[contentScrollView bounds]];
//     [projectView setAutoresizingMask:CPViewWidthSizable];
//     [contentScrollView setDocumentView:projectView];
// }

@end
