@import <AppKit/CPViewController.j>
@import "AuthenticationController.j"
@import "ServerController.j"

@global RodanFailedLogInNotification


@implementation LoginViewController : CPViewController
{
    @outlet         AuthenticationController    authenticationController    @accessors;
    @outlet         ServerController            serverController            @accessors;
    @outlet         CPTextField                 username;
    @outlet         CPSecureTextField           password;
    @outlet         CPButton                    loginButton;
    @outlet         CPTextField                 statusLabel                 @accessors;

    @outlet         CPArrayController           fooArrayController;

}

- (id)init
{
    if (self = [super initWithCibName:@"LoginView" bundle:nil])
    {
        var shadowView = [[CPShadowView alloc] initWithFrame:[[self view] bounds]];
        [[self view] addSubview:shadowView];
        [[self view] setNeedsLayout];
        [[self view] setNeedsDisplay:YES];

        [[CPNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(warnUserOfFailedLogin:)
                                                     name:RodanFailedLogInNotification
                                                   object:nil];

        [[self statusLabel] setObjectValue:@""];
    }

    return self;
}

- (@action)logIn:(id)aSender
{
    CPLog.debug(@"Application Log In");
    [authenticationController logInWithUsername:username password:password];
}

- (@action)logOut:(id)aSender
{
    CPLog.debug(@"Application Log Out");

    [authenticationController logOut];
}

- (void)warnUserOfFailedLogin:(CPNotification)aNotification
{
    [[self statusLabel] setTextColor:[CPColor redColor]];
    [[self statusLabel] setObjectValue:@"Your username or password was not correct. Please try again"];
}

#pragma mark - Private Methods -

@end