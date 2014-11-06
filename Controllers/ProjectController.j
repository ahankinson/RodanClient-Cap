@import "../Models/Project.j"

@global RodanDidLoadProjectsNotification

@implementation ProjectController : CPObject
{
    @outlet     ServerController          serverController;
    @outlet     CPArrayController   projectArrayController      @accessors;
                CPInteger                 numberOfProjects      @accessors;
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

- (void)loadProjectsOnPage:(CPInteger)pageNumber
{
    var url = [serverController routeForRouteName:@"projects"] + @"?page=" + pageNumber;
    [WLRemoteAction schedule:WLRemoteActionGetType
                        path:url
                    delegate:self
                     message:pageNumber];
}

- (CPInteger)objectsPerPage
{
    return [serverController valueForConfiguration:@"page_length"];
}

#pragma mark Ratatosk response delegate

- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    CPLog.debug("Project response came back");
    var response = [anAction result],
        results = response.results;

    if (!numberOfProjects)
        numberOfProjects = response.count;

    // e.g., idx set page 1 is 0 (0 * 20) to 19 (0 * 20) + 20, page 2 is 20 (1 * 20)
    var page = [anAction message],
        startingIndex = ((page - 1) * [self objectsPerPage]),
        idxSet = [CPIndexSet indexSetWithIndexesInRange:CPMakeRange(startingIndex, results.length)];

    var p = [Project objectsFromJson:results];
    [[projectArrayController contentArray] insertObjects:p atIndexes:idxSet];

    [[CPNotificationCenter defaultCenter] postNotificationName:RodanDidLoadProjectsNotification
                                                        object:nil];
}

@end