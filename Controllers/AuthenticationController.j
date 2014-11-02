/**
 * This class handles all authentication to the remote server. Two types of
 * authentication are supported: "token" and "session" (see Rodan wiki).
 * The type of authentication can be set in the root Info.plist.
 *
 * This controller also offers the minimum requirements for a UI login
 * via its outlets.
 *
 * This also acts as a delegate for WLRemoteLink so it can add the
 * appropriate headers for REST calls.
 */

@import <Foundation/CPURL.j>
@import <Foundation/CPObject.j>
@import <Foundation/CPNotificationCenter.j>
@import "../Models/User.j"
@import "ServerController.j"

@global RodanMustLogInNotification
@global RodanFailedLogInNotification
@global RodanCannotLogInNotification
@global RodanDidLogInNotification
@global RodanDidLogOutNotification
@global RodanAuthenticationSuccessNotification

@implementation AuthenticationController : CPObject
{
    @outlet         ServerController    serverController;
}

- (void)checkAuthenticationStatus
{
    CPLog.debug(@"Checking Authentication Status");

    var authURLRequest = [serverController statusRoute];
    [authURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    if ([serverController authenticationType] === 'session')
    {
        CPLog.debug(@"Injecting the cookie for session authentication");

        // if the server controller doesn't have the CSRF Token, set it now.
        if (![serverController CSRFToken])
            [serverController setCSRFToken:[[CPCookie alloc] initWithName:@"csrftoken"]];

        [authURLRequest setValue:[[serverController CSRFToken] value]
              forHTTPHeaderField:@"X-CSRFToken"];
    }

    var authStatusDelegate = [[AuthStatusDelegate alloc] init];
    [authStatusDelegate setServerController:serverController];

    [CPURLConnection connectionWithRequest:authURLRequest delegate:authStatusDelegate];
}

- (void)logInWithUsername:(CPString)aUsername password:(CPString)aPassword
{
    var authURLRequest = [serverController authenticationRoute];

    [authURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [authURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [authURLRequest setHTTPBody:@"username=" + [aUsername objectValue] + "&password=" + [aPassword objectValue]];
    [authURLRequest setHTTPMethod:@"POST"];

    var logInDelegate = [[LogInDelegate alloc] init];
    [logInDelegate setServerController:serverController];

    [CPURLConnection connectionWithRequest:authURLRequest delegate:logInDelegate];
}

- (void)logOut
{
    var logoutURLRequest = [serverController logOutRoute];
    [logoutURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    if ([serverController authenticationType] === 'session')
    {
        [logoutURLRequest setValue:[[serverController CSRFToken] value] forHTTPHeaderField:@"X-CSRFToken"];
    }
    else
    {
        [logoutURLRequest setValue:[serverController authenticationToken] forHTTPHeaderField:@"Authorization"];
    }

    [logoutURLRequest setHTTPMethod:@"POST"];

    var logOutDelegate = [[LogOutDelegate alloc] init];
    [logOutDelegate setServerController:serverController];

    [CPURLConnection connectionWithRequest:logoutURLRequest delegate:logOutDelegate];
}

@end


@implementation AuthStatusDelegate : CPObject
{
    ServerController    serverController    @accessors;
}

- (void)connection:(CPURLConnection)aConnection didReceiveResponse:(CPURLResponse)response
{
    switch ([response statusCode])
    {
        case 200:
            CPLog.debug(@"Success.");
            break;
        case 400:
            CPLog.debug(@"Bad Request");
            [aConnection cancel];
            break;
        case 401:
            // needs to authenticate
            CPLog.debug(@"User must authenticate");
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanMustLogInNotification
                                                                object:nil];
            [aConnection cancel];
            break;
        case 403:
            // forbidden
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanCannotLogInNotification
                                                                object:nil];
            CPLog.debug(@"Forbidden");
            [aConnection cancel];
            break;
        default:
            CPLog.error(@"An uncaught error code was returned during Authentication: " + [response statusCode]);
    }
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(id)anError
{
    CPLog.error(@"An authentication request failed with an error: " + anError);
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPURLResponse)data
{
}


@end


@implementation LogInDelegate : CPObject
{
    ServerController    serverController    @accessors;
}

- (void)connection:(CPURLConnection)aConnection didReceiveResponse:(CPURLResponse)response
{
    CPLog.debug(@"Received a status code of " + [response statusCode]);

    switch ([response statusCode])
    {
        case 200:
            CPLog.debug(@"Success.");
            break;
        case 400:
            CPLog.debug(@"Bad Request");
            [aConnection cancel];
            break;
        case 401:
            // needs to authenticate
            CPLog.debug(@"User must authenticate");
            // Warn listeners that the attempt to authenticated with a 401, then allow the user to try again.
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanFailedLogInNotification
                                                                object:nil];

            [[CPNotificationCenter defaultCenter] postNotificationName:RodanMustLogInNotification
                                                                object:nil];
            [aConnection cancel];
            break;
        case 403:
            // forbidden
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanCannotLogInNotification
                                                                object:nil];
            CPLog.debug(@"Forbidden");
            [aConnection cancel];
            break;
        default:
            CPLog.error(@"An uncaught error code was returned during Authentication: " + [response statusCode]);
    }
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(id)anError
{
    CPLog.error(@"An authentication request failed with an error: " + anError);
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPURLResponse)data
{
    CPLog.debug("Log In Delegate has received data");
    if (data)
    {
        var parsed = JSON.parse(data);
        [serverController setActiveUser:[[User alloc] initWithJson:parsed]];
        [serverController setAuthenticationToken:@"Token " + [[serverController activeUser] authenticationToken]];

        [[CPNotificationCenter defaultCenter] postNotificationName:RodanAuthenticationSuccessNotification
                                                            object:nil];
    }
}

@end

@implementation LogOutDelegate : CPObject
{
    ServerController    serverController    @accessors;
}

- (void)connection:(CPURLConnection)aConnection didReceiveResponse:(CPURLResponse)response
{
    switch ([response statusCode])
    {
        case 200:
            CPLog.debug(@"Success.");
            break;
        case 400:
            CPLog.debug(@"Bad Request");
            [aConnection cancel];
            break;
        case 401:
            // needs to authenticate
            CPLog.debug(@"User must authenticate");
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanMustLogInNotification
                                                                object:nil];
            [aConnection cancel];
            break;
        case 403:
            // forbidden
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanCannotLogInNotification
                                                                object:nil];
            CPLog.debug(@"Forbidden");
            [aConnection cancel];
            break;
        default:
            CPLog.error(@"An uncaught error code was returned during Authentication: " + [response statusCode]);
    }
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(id)anError
{
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPURLResponse)data
{
    CPLog.debug(@"Log out delegate has received data");

    [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLogOutNotification
                                                        object:nil];
}

@end

