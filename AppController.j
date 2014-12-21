@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "Models/Job.j"
@import "Models/Output.j"
@import "Models/OutputPort.j"
@import "Models/OutputPortType.j"
@import "Models/Project.j"
@import "Models/Resource.j"
@import "Models/ResourceType.j"
@import "Models/RunJob.j"
@import "Models/User.j"
@import "Models/Workflow.j"
@import "Models/WorkflowJob.j"
@import "Models/WorkflowRun.j"
@import "Categories/CPButtonBar+PopupButton.j"
@import "Categories/CPURLConnection+AsyncBlock.j"
@import "Categories/WLRemoteObject+RemotePath.j"
@import "Controllers/ResourceController.j"
@import "Controllers/WorkflowController.j"
@import "Controllers/ProjectController.j"
@import "Controllers/ServerController.j"
@import "Controllers/NewProjectWindowController.j"
@import "Controllers/OpenProjectWindowController.j"
@import "Controllers/ProjectViewController.j"
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

#pragma mark Project Listing Notifications

RodanRefreshProjectListNotification = @"RodanRefreshProjectListNotification"
RodanDidLoadProjectsNotification = @"RodanDidLoadProjectsNotification";

#pragma mark Project Loading Notifications

RodanShouldLoadProjectNotification = @"RodanShouldLoadProjectNotification";
RodanDidLoadProjectNotification = @"RodanDidLoadProjectNotification";
RodanWillCreateProjectNotification = @"RodanWillCreateProjectNotification";
RodanDidCreateProjectNotification = @"RodanDidCreateProjectNotification";
RodanDidFinishLoadingProjectNotification = @"RodanDidFinishLoadingProjectNotification";
RodanWillCloseProjectNotification = @"RodanWillCloseProjectNotification";


@implementation AppController : CPObject
{
    @outlet     CPWindow                    theWindow;
    @outlet     CPToolbar                   theToolbar;
    @outlet     LoadingViewController       loadingViewController;
    @outlet     LoginViewController         loginViewController;
    @outlet     ServerController            serverController          @accessors(readonly);
    @outlet     AuthenticationController    authenticationController;
    @outlet     NewProjectWindowController  newProjectWindowController;
    @outlet     ProjectViewController       projectViewController;
    @outlet     CPArrayController           projectArrayController    @accessors;
    @outlet     CPView                      blankApplicationView;

                CPScrollView                contentScrollView         @accessors;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    /*
        Start the Rodan startup process
    */

    // hide the toolbar until we're authenticated
    [CPMenu setMenuBarVisible:NO];
    [theToolbar setVisible:NO];

    // Register the callback methods for when the routes have finished loading.
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

    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayBlankApplicationView:)
                                                 name:RodanWillCloseProjectNotification
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

/*
 *  If the Rodan server is not reachable, show a message.
 */
- (void)serverWentAway:(CPNotificationCenter)aNotification
{
    var alert = [[CPAlert alloc] init];

    [alert setMessageText:CPLocalizedString(@"The Rodan server could not be contacted", @"The Rodan server could not be contacted")];
    [alert setDelegate:self];
    [alert setAlertStyle:CPCriticalAlertStyle];
    [alert addButtonWithTitle:CPLocalizedString(@"Dismiss", @"Dismiss")];
    [alert runModal];
}

- (void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
}

#pragma mark Action Handlers


- (void)awakeFromCib
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

    [theWindow setFullPlatformWindow:YES];
}

@end
