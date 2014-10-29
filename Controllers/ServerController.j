@import <Foundation/CPObject.j>
@import <Foundation/CPNotificationCenter.j>
@import <Foundation/CPBundle.j>
@import <Foundation/CPURLConnection.j>
@import <Foundation/CPURLRequest.j>

@import <Ratatosk/WLRemoteLink.j>

@global RodanSetRoutesNotification
@global RodanRoutesDidFinishLoadingNotification

/**
    This controller stores and manages all of the
    information required for communication with the Rodan
    server.

    Reads the configuration options from the app's Info.plist
    and makes them accessible to the rest of the application
    in a convenient and friendly way.

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
    @outlet     CPCookie        CSRFToken              @accessors;
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
                                                 selector:@selector(setRoutesFromNotification:)
                                                     name:RodanSetRoutesNotification
                                                   object:nil];

        CPLog.debug(@"Server Controller initialized");
    }

    return self;
}

- (void)establishRoutes
{
    CPLog.debug(@"Establishing Routes from the server");

     // Grab the routes from the Rodan server. These are published at the server root.
    var routesDelegate = [[RoutesDelegate alloc] init];
    var request = [CPURLRequest requestWithURL:server];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [CPURLConnection connectionWithRequest:request delegate:routesDelegate];
}

- (void)setRoutesFromNotification:(id)aNotification
{
    routes = [aNotification object];

    CPLog.debug(@"Routes have been established");

    [[CPNotificationCenter defaultCenter] postNotificationName:RodanRoutesDidFinishLoadingNotification
                                                        object:nil]
}

#pragma mark Routes Helpers

/**
    Returns the appropriate authentication URL depending on the type of authentication
    (session or token).
*/
- (CPURLRequest)authenticationRoute
{
    console.log([self routes]);

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

#pragma mark Ratatosk delegate

/**
 * @brief Delegate method for the Ratatosk Framework
 * @details This method is used by the Ratatosk Framework to intercept every
 *          request and add in routing information.
 */
- (void)remoteLink:(WLRemoteLink)aLink willSendRequest:(CPURLRequest)aRequest withDelegate:(id)aDelegate context:(id)aContext
{
    switch ([[aRequest HTTPMethod] uppercaseString])
    {
        case "POST":
        case "PUT":
        case "PATCH":
        case "DELETE":
            [aRequest setValue:[CSRFToken value] forHTTPHeaderField:"X-CSRFToken"];
    }
}

@end


@implementation RoutesDelegate : CPObject
{
}

/**
    @TODO: Implement error checking
*/
- (void)connection:(CPURLConnection)connection didReceiveResponse:(CPHTTPURLResponse)response
{
}

/**
    The response to the fetch routes command goes through here.
*/
- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
    CPLog.debug(@"Routes were received from the server.");

    var jsData = JSON.parse(data),
        dictionary = [CPDictionary dictionaryWithJSObject:jsData];

    // The ServerController's setRoutes: method is subscribed to this notification
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanSetRoutesNotification
                                                        object:dictionary];
}

@end