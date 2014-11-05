@import <AppKit/CPArrayController.j>

/*
 *  Provides support for loading paginated content from the Rodan server.
 */
@implementation PaginatedArrayController : CPArrayController
{
    // the total number of objects on the server
    CPInteger           totalObjects           @accessors;
    CPInteger           objectsPerPage         @accessors;

    // a small array that keeps track of which pages are currently loaded in the content array
    CPArray             pagesLoaded            @accessors;

    @outlet  ServerController   serverController    @accessors;
             WLRemoteObject     RepresentedObject   @accessors;
}

- (BOOL)shouldLoadRowsForPage:(CPInteger)aPage
{
    if (![pagesLoaded containsObject:aPage])
        return NO
    else
        return YES
}

- (void)loadRowsForPage:(CPInteger)aPage withRoute:(CPString)aRoute
{
    if (!objectsPerPage)
        objectsPerPage = [serverController valueForConfiguration:@"page_length"];

    // e.g, page 2 w/20 per page starts at #40
    var beginningRow = aPage * objectsPerPage,
        url = [serverController routeForRouteName:aRoute] + @"?page=" + aPage;

    // this passes along the page number in the message so that we know
    // which action provoked which response.
    [WLRemoteAction schedule:WLRemoteActionGetType
                        path:url
                    delegate:self
                     message:aPage];

}

- (void)unloadRowsForPage:(CPInteger)aPage
{
    // null out the rows for that page.
}

#pragma mark Ratatosk Delegate Method

- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    CPLog.debug('Remote Action Did Finish');
    if (!totalObjects)
        totalObjects = [anAction result].count;

    // e.g., idx set page 1 is 0 (0 * 20) to 19 (0 * 20) + 20, page 2 is 20 (1 * 20)
    var page = [anAction message],
        startingIndex = ((page - 1) * objectsPerPage),
        idxSet = [CPIndexSet indexSetWithIndexesInRange:CPMakeRange(startingIndex, startingIndex + objectsPerPage)];

    // initialize the projects from the server response.
    var objects = [RepresentedObject objectsFromJson:[anAction result].results];

    [[self contentArray] insertObjects:objects
                             atIndexes:idxSet];
}

@end