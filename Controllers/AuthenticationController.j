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
@import <AppKit/CPCookie.j>

@import "../Models/User.j"
@import "ServerController.j"

@global RodanServerWentAwayNotification
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

    // status request completion handler -- called when the request returns.
    var completionHandler = function(response, data, error)
    {
        if (data === nil && [error code] === CPURLErrorCannotFindHost)
        {
            CPLog.debug("Server went away or could not be contacted");

            [[CPNotificationCenter defaultCenter] postNotificationName:RodanServerWentAwayNotification
                                                                object:nil];
        }

        switch ([response statusCode])
        {
            case 200:
                CPLog.debug(@"Success; User must already be logged in.");
                var parsed = JSON.parse(data);
                [serverController setActiveUser:[[User alloc] initWithJson:parsed]];
                [serverController setAuthenticationToken:@"Token " + [[serverController activeUser] authenticationToken]];

                [[CPNotificationCenter defaultCenter] postNotificationName:RodanAuthenticationSuccessNotification
                                                                    object:nil];
                break;
            case 400:
                CPLog.debug(@"Bad Auth Status Request.");
                break;
            case 401:
                // needs to authenticate
                CPLog.debug(@"User must authenticate");
                [[CPNotificationCenter defaultCenter] postNotificationName:RodanMustLogInNotification
                                                                    object:nil];
                break;
            case 403:
                // forbidden
                CPLog.debug(@"Forbidden");
                [[CPNotificationCenter defaultCenter] postNotificationName:RodanCannotLogInNotification
                                                                    object:nil];
                break;
            default:
                CPLog.error(@"An uncaught error code was returned during Authentication: " + [response statusCode]);
        }
    };

    [CPURLConnection sendAsynchronousRequest:authURLRequest
                                       queue:[CPOperationQueue mainQueue]
                                       completionHandler:completionHandler];
}

- (void)logInWithUsername:(CPString)aUsername password:(CPString)aPassword
{
    var authURLRequest = [serverController authenticationRoute];

    [authURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [authURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [authURLRequest setHTTPBody:@"username=" + [aUsername objectValue] + "&password=" + [aPassword objectValue]];
    [authURLRequest setHTTPMethod:@"POST"];

    if ([serverController authenticationType] === 'session')
    {
        if (![serverController CSRFToken])
            [serverController setCSRFToken:[[CPCookie alloc] initWithName:@"csrftoken"]];

        [authURLRequest setValue:[[serverController CSRFToken] value]
              forHTTPHeaderField:@"X-CSRFToken"];
    }

    // this callback function handles the response from the server.
    var completionHandler = function(response, data, error)
    {
        switch ([response statusCode])
        {
            case 200:
                CPLog.debug(@"Success.");
                var parsed = JSON.parse(data);
                [serverController setActiveUser:[[User alloc] initWithJson:parsed]];
                [serverController setAuthenticationToken:@"Token " + [[serverController activeUser] authenticationToken]];

                [[CPNotificationCenter defaultCenter] postNotificationName:RodanAuthenticationSuccessNotification
                                                                    object:nil];
                break;
            case 400:
                CPLog.debug(@"Bad Request");
                break;
            case 401:
                // needs to authenticate
                CPLog.debug(@"User must authenticate");

                // Warn listeners that the attempt to authenticated with a 401, then allow the user to try again.
                [[CPNotificationCenter defaultCenter] postNotificationName:RodanFailedLogInNotification
                                                                    object:nil];

                [[CPNotificationCenter defaultCenter] postNotificationName:RodanMustLogInNotification
                                                                    object:nil];
                break;
            case 403:
                // forbidden
                [[CPNotificationCenter defaultCenter] postNotificationName:RodanCannotLogInNotification
                                                                    object:nil];
                CPLog.debug(@"Forbidden");
                break;
            default:
                CPLog.error(@"An uncaught error code was returned during Authentication: " + [response statusCode]);
        }
    };

    [CPURLConnection sendAsynchronousRequest:authURLRequest
                                       queue:[CPOperationQueue mainQueue]
                           completionHandler:completionHandler];
}

- (void)logOut
{
    var logoutURLRequest = [serverController logOutRoute];
    [logoutURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    if ([serverController authenticationType] === 'session')
        [logoutURLRequest setValue:[[serverController CSRFToken] value] forHTTPHeaderField:@"X-CSRFToken"];
    else
        [logoutURLRequest setValue:[serverController authenticationToken] forHTTPHeaderField:@"Authorization"];

    [logoutURLRequest setHTTPMethod:@"POST"];

    var completionHandler = function(response, data, error)
    {
        switch ([response statusCode])
        {
            case 200:
                CPLog.debug(@"Success.");
                [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLogOutNotification
                                                    object:nil];
                break;
            case 400:
                CPLog.debug(@"Bad Request");
                break;
            case 401:
                // needs to authenticate
                CPLog.debug(@"User must authenticate");
                [[CPNotificationCenter defaultCenter] postNotificationName:RodanMustLogInNotification
                                                                    object:nil];
                break;
            case 403:
                // forbidden
                [[CPNotificationCenter defaultCenter] postNotificationName:RodanCannotLogInNotification
                                                                    object:nil];
                CPLog.debug(@"Forbidden");
                break;
            default:
                CPLog.error(@"An uncaught error code was returned during Authentication: " + [response statusCode]);
        }
    };

    [CPURLConnection sendAsynchronousRequest:logoutURLRequest
                                    queue:[CPOperationQueue mainQueue]
                                    completionHandler:completionHandler];
}

@end


