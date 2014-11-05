@import <AppKit/CPViewController.j>
@import "../Categories/CPButtonBar+PopupButton.j"
@import "ProjectController.j"

@global RodanDidLoadProjectsNotification

@implementation ProjectViewController : CPViewController
{
    @outlet     ProjectController       projectController;
    @outlet     CPArrayController       projectArrayController      @accessors;
    @outlet     CPButtonBar             projectAddRemoveButtonBar;
    @outlet     CPTableView             projectList;

    @outlet     CPTextField             projectName;
    @outlet     CPTextField             projectCreated;
}

- (id)init
{
    if (self = [super initWithCibName:@"ProjectView" bundle:nil owner:self])
    {
        [[CPNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshProjectList:)
                                                     name:RodanDidLoadProjectsNotification
                                                   object:nil];
    }

    return self;
}

- (void)refreshProjectList:(CPNotification)aNotification
{
    CPLog.debug(@"Reloading the project list");
    [projectList reloadData];
}

- (void)viewDidLoad
{
        var addButton = [CPButtonBar plusButton],
            removeButton = [CPButtonBar minusButton];

        [projectAddRemoveButtonBar setButtons:[addButton, removeButton]];

        [addButton setAction:@selector(createNewProject:)];
        [addButton setTarget:self];

        // confirm before we delete.
        [removeButton setAction:@selector(confirmDeleteProjects:)];
        [removeButton setTarget:self];

        // only activate the remove button if a project is selected
        [removeButton bind:@"enabled"
                 toObject:projectArrayController
              withKeyPath:@"selectedObjects.@count"
                  options:nil];

        // set up the delegate for the tableview
        var delegate = [[ProjectListTableViewDelegate alloc] initWithProjectController:projectController];
        [projectList setDelegate:delegate];
        [projectList setDataSource:delegate];

        [projectName bind:@"value"
                 toObject:projectArrayController
              withKeyPath:@"selection.projectName"
                  options:nil];

        // this will fetch the first page of projects
        CPLog.debug(@"Loading Projects...");
        [projectController loadProjectsOnPage:1];
}

- (@action)createNewProject:(id)aSender
{
    [projectController newProject];
}

- (@action)confirmDeleteProjects:(id)aSender
{
    var numToBeDeleted = [[projectArrayController selectedObjects] count];

    if (numToBeDeleted > 1)
    {
        var plThis = @"These",
            plProj = @"projects";
    }
    else
    {
        var plThis = @"This",
            plProj = @"project";
    }

    var message = [CPString stringWithFormat:@"%@ %@ %@ and all associated files will be deleted! This cannot be undone. Are you sure?", plThis, numToBeDeleted, plProj],
        alert = [[CPAlert alloc] init];

    [alert setMessageText:message];
    [alert setDelegate:self];
    [alert setAlertStyle:CPCriticalAlertStyle];
    [alert addButtonWithTitle:@"Delete"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert runModal];
}

- (void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
    if (returnCode == 0)
        [projectController deleteProjects];
}

@end

/*
 *  Provides a paged table view delegate.
 */
@implementation ProjectListTableViewDelegate : CPObject
{
    ProjectController       theProjectController        @accessors;
}

- (id)initWithProjectController:(ProjectController)aController
{
    if (self = [super init])
    {
        theProjectController = aController;
    }

    return self;
}

- (int)numberOfRowsInTableView:(CPTableView)aTableView
{
    CPLog.debug("Project TableView: numberOfRowsInTableView:");
    return [theProjectController numberOfProjects];  // debug
}

// - (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)aRowIndex
// {
//     CPLog.debug("Project TableView: objectValueForTableColumn:row")
// }

- (CPView)tableView:(CPTableView)tableView viewForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)aRowIndex
{
    CPLog.debug("Project TableView: viewForTableColumn:row");

    var projectContentArray = [[theProjectController projectArrayController] contentArray],
        representedProject = nil;

    try
    {
        representedProject = [projectContentArray objectAtIndex:aRowIndex];
    }
    catch (CPRangeExeception)
    {
        // the first page is page 1, but that creates 
        var objectsPerPage = [theProjectController objectsPerPage],
            page = Math.ceil(aRowIndex / (objectsPerPage - 1));

        CPLog.debug(@"Row " + aRowIndex + " is on (page " + page + ") and must be loaded.");

        [theProjectController loadProjectsOnPage:page];

        return nil;
    }

    var view = [tableView makeViewWithIdentifier:[aTableColumn identifier] owner:self];

    [[view projectName] bind:@"value"
                    toObject:representedProject
                 withKeyPath:@"projectName"
                     options:nil];

    [[view projectDescription] bind:@"value"
                           toObject:representedProject
                        withKeyPath:@"projectDescription"
                            options:nil];

    return view;
}

@end

@implementation ProjectListCellView : CPTableCellView
{
    @outlet     CPTextField     projectName         @accessors;
    @outlet     CPTextField     projectDescription  @accessors;
    @outlet     CPTextField     projectCreated      @accessors;
}

@end

