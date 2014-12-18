@import <AppKit/CPWindowController.j>

@global RodanDidLoadProjectsNotification

@implementation OpenProjectWindowController : CPWindowController
{
    @outlet     CPTableView         projectList;
    @outlet     CPButton            openProjectButton;
    @outlet     ServerController    serverController;
    @outlet     ProjectController   projectController;
}

- (id)init
{
    var localizedCibFile = [[CPBundle mainBundle] bundleLocale] + @".lproj/OpenProjectWindow.cib";
    if (self = [self initWithWindowCibName:localizedCibFile owner:self])
    {
        [[CPNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshProjectList:)
                                                     name:RodanDidLoadProjectsNotification
                                                   object:nil];
    }

    return self;
}

- (void)windowDidLoad
{
    var tableDelegate = [[ProjectListTableDelegate alloc] initWithProjectController:projectController];
    [projectList setDelegate:tableDelegate];
    [projectList setDataSource:tableDelegate];

    [projectController loadProjectsOnPage:1];
}

- (void)refreshProjectList:(CPNotification)aNotification
{
    [projectList reloadData];
}

#pragma mark Actions

- (@action)openProject:(id)aSender
{
    // TODO
    CPLog.debug('open project');
}
@end


@implementation ProjectListTableDelegate : CPObject
{
    ProjectController       _projectController;
}

- (id)initWithProjectController:(ProjectController)aProjectController
{
    if (self = [self init])
    {
        _projectController = aProjectController;
    }

    return self;
}

- (int)numberOfRowsInTableView:(CPTableView)aTableView
{
    CPLog.debug("Project TableView: numberOfRowsInTableView:");
    return [_projectController numberOfProjects];
}

- (CPView)tableView:(CPTableView)tableView viewForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)aRowIndex
{
    var projectContentArray = [[_projectController projectArrayController] contentArray],
        representedProject = nil;

    try
    {
        representedProject = [projectContentArray objectAtIndex:aRowIndex];
    }
    catch (CPRangeExeception)
    {
        var objectsPerPage = [_projectController objectsPerPage],
            page = Math.ceil(aRowIndex / (objectsPerPage - 1));

        CPLog.debug(@"Row " + aRowIndex + " is on page " + page + " and must be loaded.");

        [_projectController loadProjectsOnPage:page];

        return nil;
    }

    var view = [tableView makeViewWithIdentifier:[aTableColumn identifier] owner:self];

    if ([aTableColumn identifier] === @"projectCreator")
    {
        [[view textField] bind:@"value"
                      toObject:representedProject
                   withKeyPath:[aTableColumn identifier] + ".username"
                       options:nil];
    }
    else
    {
        [[view textField] bind:@"value"
                      toObject:representedProject
                   withKeyPath:[aTableColumn identifier]
                       options:nil];

    }
    return view;
}

@end