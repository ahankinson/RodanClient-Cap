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

@end