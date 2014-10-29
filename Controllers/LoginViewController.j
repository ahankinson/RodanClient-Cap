@import <AppKit/CPViewController.j>
@import "AuthenticationController.j"
@import "ServerController.j"


@implementation LoginViewController : CPViewController
{
    @outlet         AuthenticationController    authenticationController    @accessors;
    @outlet         ServerController            serverController            @accessors;
    @outlet         CPTextField                 username;
    @outlet         CPSecureTextField           password;
    @outlet         CPButton                    loginButton;

}

- (id)init
{
    if (self = [super initWithCibName:@"LoginView" bundle:nil])
    {
        var shadowView = [[CPShadowView alloc] initWithFrame:[[self view] bounds]];
        [[self view] addSubview:shadowView];
        [[self view] setNeedsLayout];
        [[self view] setNeedsDisplay:YES];
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

#pragma mark - Private Methods -

@end