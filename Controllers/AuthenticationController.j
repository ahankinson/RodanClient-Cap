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

@implementation AuthenticationController : CPObject
{
    @outlet         ServerController    serverController;
}

- (void)logInWithUsername:(CPString)aUsername password:(CPString)aPassword
{
    var authURLRequest = [serverController authenticationRoute];
    console.log(authURLRequest);

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
        case 400:
            [aConnection cancel];
            break;
        case 401:
            // needs to authenticate
            [aConnection cancel];
            break;
        case 403:
            // forbidden
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

- (void)connection:(CPURLConnection)aConnection didReceiveResponse:(CPURLResponse)data
{
    console.log("Received data");
    if (data)
    {
        console.log(data);
    }
}

@end