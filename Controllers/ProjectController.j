@import "../Models/Project.j"

@global RodanDidLoadProjectsNotification
@global RodanRefreshProjectListNotification
@global RodanProjectWasMadeActiveProject
@global RodanProjectDidFinishLoading

@class ServerController

@implementation ProjectController : CPObject
{
                Project              currentlyActiveProject     @accessors(readonly);
    @outlet     ServerController          serverController;
    @outlet     CPArrayController    projectArrayController     @accessors;
    @outlet     CPArrayController   workflowArrayController     @accessors;
    @outlet     CPArrayController   resourceArrayController     @accessors;
                CPInteger                  numberOfProjects     @accessors;
                CPInteger            _currentlyLoadingPage;
}

- (id)init
{
    if (self = [super init])
    {
        CPLog.debug('initializing project controller');

        _currentlyLoadingPage = 0;  // there is no page 0, so this is a safe initial value.

        [[CPNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshProjectList:)
                                                     name:RodanRefreshProjectListNotification
                                                   object:nil];

        [[CPNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setCurrentlyActiveProject:)
                                                     name:RodanProjectWasMadeActiveProject
                                                   object:nil];
    }

    return self;
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

- (void)openProject:(Project)aProject
{
    /*
        When fetching the list of projects, a minimal representation without all the workflow
        and resource objects is fetched. Calling reload on a single project object will hit the
        remote endpoint for a single object, where the workflow and resource objects *are* returned.
        This will update the project object with the new info.

        When this fires, a delegate on the Project object itself will receive the response and kick
        off the rest of the project opening process.
    */
    [aProject ensureLoaded];
}

- (void)setCurrentlyActiveProject:(CPNotification)aNotification
{
    var theProject = [aNotification object];

    currentlyActiveProject = theProject;

    [workflowArrayController bind:@"contentArray"
                         toObject:theProject
                      withKeyPath:@"workflows"
                          options:nil];

    [resourceArrayController bind:@"contentArray"
                         toObject:theProject
                      withKeyPath:@"resources"
                          options:nil];

    [[CPNotificationCenter defaultCenter] postNotificationName:RodanProjectDidFinishLoading
                                                        object:nil];
}

- (void)refreshProjectList:(CPNotification)aNotification
{
    // loading page 1 should restart the loading process.
    [[self projectArrayController] setContent:[]];
    [self loadProjectsOnPage:1];
}

#pragma mark Project Listings

- (void)loadProjectsOnPage:(CPInteger)pageNumber
{
    // if we're already loading this page, ignore future requests. This will get
    // reset once this request returns;
    if (_currentlyLoadingPage === pageNumber)
        return;

    _currentlyLoadingPage = pageNumber;

    CPLog.debug("Load Projects on Page " + pageNumber);
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

- (void)remoteActionDidFail:(WLRemoteAction)anAction dueToAuthentication:(BOOL)dueToAuthentication
{
    CPLog.debug(@"Remote action failed due to Authentication " + dueToAuthentication);
    _currentlyLoadingPage = 0;
}

- (void)remoteActionDidFinish:(WLRemoteAction)anAction
{
    CPLog.debug("Project response came back");

    _currentlyLoadingPage = 0;

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