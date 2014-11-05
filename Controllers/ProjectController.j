@import "../Models/Project.j"


@implementation ProjectController : CPObject
{
    @outlet     ServerController          serverController;
    @outlet     PaginatedArrayController  projectArrayController;
}

- (void)newProject
{
    var newProject = [[Project alloc] initWithCreator:[[serverController activeUser] pk]];
    [projectArrayController addObject:newProject];
    [newProject ensureCreated];
}

- (void)deleteProjects
{
    var selectedObjects = [projectArrayController selectedObjects];
    [projectArrayController removeObjects:selectedObjects];

    // delete from server
    [selectedObjects makeObjectsPerformSelector:@selector(ensureDeleted)];
}

- (void)fetchProjectsOnPage:(CPInteger)aPageNumber
{
    if (aPageNumber === nil)
        aPageNumber = 1;

    var url = [serverController routeForRouteName:@"projects"] + @"?page=" + aPageNumber;

    [WLRemoteAction schedule:WLRemoteActionGetType
                        path:url
                    delegate:self
                     message:nil];
}

- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    console.log(anAction);
    // var p = [Project objectsFromJson:[anAction result]];
    // [projectArrayController addObjects:p];
}

@end