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
    }

    return self;
}

- (@action)logIn:(id)aSender
{
    [authenticationController logInWithUsername:username password:password];
}

- (@action)logOut:(id)aSender
{
    console.log("log out");
}

#pragma mark - Private Methods -

@end