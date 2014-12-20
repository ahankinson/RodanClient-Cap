@import <AppKit/CPViewController.j>

@implementation ProjectViewController : CPViewController
{
    @outlet     ProjectController             projectController;
    @outlet     CPArrayController       workflowArrayController;
    @outlet     CPArrayController       resourceArrayController;

    @outlet     CPTextField                         projectName;
    @outlet     CPTextField                  projectDescription;
    @outlet     CPTextField                      projectCreated;
    @outlet     CPTextField                      projectUpdated;
    @outlet     CPTextField                      projectCreator;

    @outlet     CPTableView    projectOverviewWorkflowTableView;
    @outlet     CPTableView    projectOverviewResourceTableView;
}

- (id)init
{
    var localizedCibFile = [[CPBundle mainBundle] bundleLocale] + @".lproj/ProjectView";

    if (self = [super initWithCibName:localizedCibFile bundle:nil])
    {
    }

    return self;
}

- (void)viewDidLoad
{
    var currentlyActiveProject = [projectController currentlyActiveProject],
        workflowTableViewDelegate = [[WorkflowTableViewDelegate alloc] init],
        resourceTableViewDelegate = [[ResourceTableViewDelegate alloc] init];

    [projectOverviewWorkflowTableView setDelegate:workflowTableViewDelegate];
    [projectOverviewWorkflowTableView setDataSource:workflowTableViewDelegate];
    [projectOverviewResourceTableView setDelegate:resourceTableViewDelegate];
    [projectOverviewResourceTableView setDataSource:resourceTableViewDelegate];

    [projectName bind:@"value"
             toObject:currentlyActiveProject
          withKeyPath:@"projectName"
              options:nil];

    [projectDescription bind:@"value"
                    toObject:currentlyActiveProject
                 withKeyPath:@"projectDescription"
                     options:nil];

    [projectCreated bind:@"value"
                toObject:currentlyActiveProject
             withKeyPath:@"created"
                 options:nil];

    [projectUpdated bind:@"value"
                toObject:currentlyActiveProject
             withKeyPath:@"updated"
                 options:nil];

    [projectCreator bind:@"value"
                toObject:currentlyActiveProject
             withKeyPath:@"projectCreator.username"
                 options:nil];

    // [projectOverviewWorkflowTableView bind:@"content"
    //                               toObject:workflowArrayController
    //                            withKeyPath:@"arrangedObjects"
    //                                options:nil];

    // [projectOverviewWorkflowTableView bind:@"selectionIndexes"
    //                               toObject:workflowArrayController
    //                            withKeyPath:@"selectionIndexes"
    //                                options:nil];

    // [projectOverviewResourceTableView bind:@"content"
    //                               toObject:resourceArrayController
    //                            withKeyPath:@"arrangedObjects"
    //                                options:nil];

    // [projectOverviewResourceTableView bind:@"selectionIndexes"
    //                               toObject:resourceArrayController
    //                            withKeyPath:@"selectionIndexes"
    //                                options:nil];
}

@end

@implementation WorkflowTableViewDelegate : CPObject
{
}

- (int)numberOfRowsInTableView:(CPTableView)aTableView
{
}

- (CPView)tableView:(CPTableView)tableView viewForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)aRowIndex
{
}

@end


@implementation ResourceTableViewDelegate : CPObject
{
}

- (int)numberOfRowsInTableView:(CPTableView)aTableView
{
}

- (CPView)tableView:(CPTableView)tableView viewForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)aRowIndex
{
}


@end