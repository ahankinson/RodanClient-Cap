@import <Foundation/CPObject.j>
@import <Foundation/CPNotificationCenter.j>
@import <Foundation/CPBundle.j>
@import <Foundation/CPURLConnection.j>
@import <Foundation/CPURLRequest.j>

@import <Ratatosk/WLRemoteLink.j>

@global CPURLErrorCannotFindHost
@global RodanServerWentAwayNotification
@global RodanServerConfigurationHasReturnedNotification
@global RodanClientConfigurationWillStartNotification
@global RodanClientConfigurationHasFinishedNotification

/**
    This controller stores and manages all of the
    information required for communication with the Rodan
    server.

    @property server
    @brief    The URL to the Rodan server instance
    @property authenticationToken
    @brief    If using the authentication token type, stores the user's auth token.
    @property authenticationType
    @brief    Either "session" or "token"
    @property routes
    @brief    A dictionary holding some of the URL endpoints for the Rodan server.

*/
@implementation ServerController : CPObject
{
    @outlet     CPString        server                 @accessors;
    @outlet     CPString        authenticationToken    @accessors;
    @outlet     CPString        authenticationType     @accessors;
    @outlet     CPNumber        refreshRate            @accessors;
    @outlet     CPDictionary    routes                 @accessors;
    @outlet     CPDictionary    configuration          @accessors;
    @outlet     CPCookie        CSRFToken              @accessors;
    @outlet     User            activeUser             @accessors;
}

- (id)init
{
    if (self = [super init])
    {
        var mainBundle = [CPBundle mainBundle];

        server = [mainBundle objectForInfoDictionaryKey:@"ServerHost"];
        authenticationType = [mainBundle objectForInfoDictionaryKey:@"AuthenticationType"];
        refreshRate = [mainBundle objectForInfoDictionaryKey:@"RefreshRate"];
        CSRFToken = [[CPCookie alloc] initWithName:@"csrftoken"];

        [[WLRemoteLink sharedRemoteLink] setDelegate:self];

        [[CPNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setClientConfiguration:)
                                                     name:RodanServerConfigurationHasReturnedNotification
                                                   object:nil];

        CPLog.debug(@"Server Controller initialized");
    }

    return self;
}


/**
 *  Queries the root of the Rodan server for the routes to the various
 *  REST endpoints.
 */
- (void)configureFromServer
{
    CPLog.debug(@"Establishing Routes from the server");
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanClientConfigurationWillStartNotification
                                                        object:nil];

     // Grab the routes from the Rodan server. These are published at the server root.
    var request = [CPURLRequest requestWithURL:server];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    var completionHandler = function(response, data, error)
    {
        if (data !== nil && [response statusCode] === 200)
        {
            CPLog.debug(@"Routes were received from the server.");
            var jsData = JSON.parse(data),
                dictionary = [CPDictionary dictionaryWithJSObject:jsData];

            // The ServerController's setRoutes: method is subscribed to this notification
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanServerConfigurationHasReturnedNotification
                                                                object:dictionary];
        }
        else if ([error code] === CPURLErrorCannotFindHost)
        {
            CPLog.debug("Server went away or could not be contacted");
            [[CPNotificationCenter defaultCenter] postNotificationName:RodanServerWentAwayNotification
                                                                object:nil];

            return nil;
        }
    }

    [CPURLConnection sendAsynchronousRequest:request
                                       queue:[CPOperationQueue mainQueue]
                           completionHandler:completionHandler];
}

- (void)setClientConfiguration:(id)aNotification
{
    CPLog.debug(@"Configuration data has returned");

    routes = [CPDictionary dictionaryWithJSObject:[[aNotification object] objectForKey:@"routes"]];
    configuration = [CPDictionary dictionaryWithJSObject:[[aNotification object] objectForKey:@"configuration"]];

    [[CPNotificationCenter defaultCenter] postNotificationName:RodanClientConfigurationHasFinishedNotification
                                                        object:nil]
}

#pragma mark Routes Helpers

/**
    Returns the appropriate authentication URL depending on the type of authentication
    (session or token).
*/
- (CPURLRequest)authenticationRoute
{
    switch (authenticationType)
    {
        case 'session':
            return [CPURLRequest requestWithURL:[[self routes] objectForKey:@"session-auth"]];
            break;
        case 'token':
            return [CPURLRequest requestWithURL:[[self routes] objectForKey:@"token-auth"]];
            break;
        default:
            CPLog.error(@"An acceptable Authentication Type was not provided");
            break;
    }
}

/**
 *  Returns the route to the user's authentication status on the server.
 */
- (CPURLRequest)statusRoute
{
    return [CPURLRequest requestWithURL:[[self routes] objectForKey:@"session-status"]];
}

/**
 *  Returns the route to log out from the server.
 */
- (CPURLRequest)logOutRoute
{
    return [CPURLRequest requestWithURL:[[self routes] objectForKey:@"session-close"]];
}

/**
 *  Returns the route for a given name as a URL string.
 */
- (CPString)routeForRouteName:(CPString)aName
{
    return [[self routes] objectForKey:aName];
}

#pragma mark Configuration Helpers

- (CPString)valueForConfiguration:(CPString)aName
{
    return [[self configuration] objectForKey:aName];
}

#pragma mark Ratatosk delegate

/**
 * @brief Delegate method for the Ratatosk Framework
 * @details This method is used by the Ratatosk Framework to intercept every
 *          request and add in routing information.
 */
- (void)remoteLink:(WLRemoteLink)aLink willSendRequest:(CPURLRequest)aRequest withDelegate:(id)aDelegate context:(id)aContext
{
    CPLog.debug("WL Remote Link was called");
    switch ([[aRequest HTTPMethod] uppercaseString])
    {
        case "GET":
        case "POST":
        case "PUT":
        case "PATCH":
        case "DELETE":
            if (authenticationType === 'session')
            {
                [aRequest setValue:[CSRFToken value] forHTTPHeaderField:@"X-CSRFToken"];
            }
            else
            {
                //token auth
                [aRequest setValue:authenticationToken forHTTPHeaderField:@"Authorization"];
            }
            break;
    }
}

@end
