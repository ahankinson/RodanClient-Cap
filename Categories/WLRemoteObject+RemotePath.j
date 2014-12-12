/*
    This category is the 'glue' for routing model objects to their endpoints on the Rodan server. The
    `remotePath` method gets applied to all WLRemoteObject classes (i.e., all Ratatosk model classes).

    If a model object has the `pk` key set, the model object represents an object on the server with a known
    URL. If, however, the `pk` is null, then the model object has not yet been synchronized with the server
    and must do so. To do this, a `POST` request must be sent to the collection endpoint (typically the plural
    of the model name; e.g., "Project" -> "projects").

    This method uses the `route` parameter set in every model object (see the Models/ folder) to determine
    the route to the collection endpoint.
*/
@implementation WLRemoteObject (RemotePath)

- (CPString)remotePath
{
    if ([self pk])
        return [self pk];
    else
    {
        /* 
            This is ugly, but magical. This allows the Rodan client to automatically configure the URLs
            for the resource endpoints as provided by the server. The 'route' property on this object matches
            the key for the collection property as provided by the Rodan server; all the routes for each individual
            resource can then be automatically discovered.

            To help centralize this mechanism, the 'server controller' is the designated place for interacting with
            the Rodan server. The best way to get to the instance of that is to route it through the central 
            App Controller, since the object itself is instantiated in the CIB file. (See MainMenu.xib to control
            the parameters for the ServerController object.)
        */
        return [[[[CPApplication sharedApplication] delegate] serverController] routeForRouteName:[self route]];
    }
}

@end