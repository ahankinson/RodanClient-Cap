@import <Foundation/CPObject.j>
@import <Foundation/CPNotificationCenter.j>
@import <Foundation/CPBundle.j>
@import <Foundation/CPURLConnection.j>
@import <Foundation/CPURLRequest.j>

@import <Ratatosk/WLRemoteLink.j>

@global RodanSetRoutesNotification

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
}

- (id)init
{
    if (self = [super init])
    {
        var mainBundle = [CPBundle mainBundle];

        server = [mainBundle objectForInfoDictionaryKey:@"ServerHost"];
        authenticationType = [mainBundle objectForInfoDictionaryKey:@"AuthenticationType"];
        refreshRate = [mainBundle objectForInfoDictionaryKey:@"RefreshRate"];

        // Grab the routes from the Rodan server. These are published at the server root.
        [[CPNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setRoutesFromNotification:)
                                                     name:RodanSetRoutesNotification
                                                   object:nil];

        var routesDelegate = [[RoutesDelegate alloc] init];
        var request = [CPURLRequest requestWithURL:server];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

        [CPURLConnection connectionWithRequest:request delegate:routesDelegate];
    }

    return self;
}

- (void)setRoutesFromNotification:(id)aNotification
{
    console.log('Setting Routes');
    routes = [aNotification object];
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

- (CPURLRequest)statusRoute
{
    return [CPURLRequest requestWithURL:[[self routes] objectForKey:@"session-status"]];
}

- (CPURLRequest)logOutRoute
{
    return [CPURLRequest requestWithURL:[[self routes] objectForKey:@"session-close"]];
}

#pragma mark Ratatosk delegate

- (void)remoteLink:(WLRemoteLink)aLink willSendRequest:(CPURLRequest)aRequest withDelegate:(id)aDelegate context:(id)aContext
{
    console.log("WLRemoteLink controller");
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
    var jsData = JSON.parse(data),
        dictionary = [CPDictionary dictionaryWithJSObject:jsData];

    // The ServerController's setRoutes: method is subscribed to this notification
    [[CPNotificationCenter defaultCenter] postNotificationName:RodanSetRoutesNotification
                                                        object:dictionary];
}

@end