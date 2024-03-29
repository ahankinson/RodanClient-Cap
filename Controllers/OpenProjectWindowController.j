@import <AppKit/CPWindowController.j>

@global RodanDidLoadProjectsNotification
@global RodanShouldLoadProjectNotification

@implementation OpenProjectWindowController : CPWindowController
{
    @outlet     CPTableView         projectList;
    @outlet     CPButton            openProjectButton;
    @outlet     ServerController    serverController;
    @outlet     ProjectController   projectController;
}

- (id)init
{
    var localizedCibFile = [[CPBundle mainBundle] bundleLocale] + @".lproj/OpenProjectWindow";
    if (self = [self initWithWindowCibName:localizedCibFile owner:self])
    {
        [[CPNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshProjectList:)
                                                     name:RodanDidLoadProjectsNotification
                                                   object:nil];
    }

    return self;
}

- (void)windowWillLoad
{
    CPLog.debug(@"Window will load");
}

- (void)windowDidLoad
{
    [[self window] setDelegate:self];

    var tableDelegate = [[ProjectListTableDelegate alloc] initWithProjectController:projectController];
    [projectList setDelegate:tableDelegate];
    [projectList setDataSource:tableDelegate];
    [projectController loadProjectsOnPage:1];
}

- (void)refreshProjectList:(CPNotification)aNotification
{
    CPLog.debug(@"Refreshing project list");
    [projectList reloadData];
}

#pragma mark Actions

- (@action)openProject:(id)aSender
{
    var selectedRow = [projectList selectedRow],
        paController = [projectController projectArrayController],
        selectedProject = [[paController contentArray] objectAtIndex:selectedRow];

    [[CPNotificationCenter defaultCenter] postNotificationName:RodanShouldLoadProjectNotification
                                                        object:selectedProject];

    [self close];
}

#pragma mark Window Delegate Methods

- (void)windowDidBecomeKey:(CPNotification)aNotification
{
    CPLog.debug(@"Window did become key");

    [projectController loadProjectsOnPage:1];
}

@end


@implementation ProjectListTableDelegate : CPObject
{
    ProjectController       _projectController;
}

- (id)initWithProjectController:(ProjectController)aProjectController
{
    if (self = [super init])
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