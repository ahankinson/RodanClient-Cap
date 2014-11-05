@import <AppKit/CPArrayController.j>

/*
 *  Provides support for loading paginated content from the Rodan server.
 */
@implementation PaginatedArrayController : CPArrayController
{
    // the total number of objects on the server
    CPInteger       totalObjects           @accessors;

    // a small array that keeps track of which pages are currently loaded in the content array
    CPArray         pagesLoaded            @accessors;
}



@end