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
@global RodanCannotLogInNotification
@global RodanDidLogInNotification
@global RodanDidLogOutNotification
@global RodanAuthenticationSuccessNotification

@implementation AuthenticationController : CPObject
{
    @outlet         ServerController    serverController;
    @outlet         User                activeUser          @accessors;
}

- (void)checkAuthenticationStatus
{
    CPLog.debug(@"Checking Authentication Status");

    var authURLRequest = [serverController statusRoute];
    [authURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    if ([serverController authenticationType] === 'session')
    {
        CPLog.debug(@"Setting the cookie for session authentication");

        // if the server controller doesn't have the CSRF Token, set it now.
        if (![serverController CSRFToken])
            [serverController setCSRFToken:[[CPCookie alloc] initWithName:@"csrftoken"]];

        [authURLRequest setValue:[[serverController CSRFToken] value]
              forHTTPHeaderField:@"X-CSRFToken"];
    }

    [CPURLConnection connectionWithRequest:authURLRequest delegate:self];
}

- (void)logInWithUsername:(CPString)aUsername password:(CPString)aPassword
{
    var authURLRequest = [serverController authenticationRoute];

    [authURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [authURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [authURLRequest setHTTPBody:@"username=" + [aUsername objectValue] + "&password=" + [aPassword objectValue]];
    [authURLRequest setHTTPMethod:@"POST"];

    [CPURLConnection connectionWithRequest:authURLRequest delegate:self];
}

#pragma mark CPURLConnection Delegate Methods

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
    CPLog.debug("Authentication Controller has received data");

    if (data)
    {
        var parsed = JSON.parse(data);
        [self setActiveUser:[[User alloc] initWithJson:parsed]];
        [serverController setAuthenticationToken:[[self activeUser] authenticationToken]];

        [[CPNotificationCenter defaultCenter] postNotificationName:RodanAuthenticationSuccessNotification
                                                            object:nil];
    }
}

@end