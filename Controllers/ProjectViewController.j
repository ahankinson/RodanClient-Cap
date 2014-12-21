@import <AppKit/CPViewController.j>

@global RodanDidFinishLoadingProjectNotification

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
        CPLog.debug(@"Initializing Project View Controller");

        [[CPNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(activateProjectView:)
                                             name:RodanDidFinishLoadingProjectNotification
                                           object:nil];

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
}

- (void)activateProjectView:(CPNotification)aNotification
{
    var projectView = [self view],
        contentScrollView = [[CPApp delegate] contentScrollView];

    [projectView setFrame:[contentScrollView bounds]];
    [projectView setAutoresizingMask:CPViewWidthSizable];
    [contentScrollView setDocumentView:projectView];

}

- (@action)closeProject:(id)aSender
{
    CPLog.debug(@"Closing Project");
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