@import <AppKit/CPViewController.j>
@import "../Categories/CPButtonBar+PopupButton.j"
@import "ProjectController.j"


@implementation ProjectViewController : CPViewController
{
    @outlet     ProjectController       projectController;
    @outlet     CPArrayController       projectArrayController      @accessors;
    @outlet     CPButtonBar             projectAddRemoveButtonBar;
    @outlet     CPTableView             projectList;

    @outlet     CPTableCellView         projectListCellView;
    @outlet     CPTextField             projectListProjectName;
    @outlet     CPTextField             projectListProjectDescription;
}

- (id)init
{
    if (self = [super initWithCibName:@"ProjectView" bundle:nil owner:self])
    {
    }

    return self;
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

        var tableViewDelegate = [[ProjectListTableViewDelegate alloc] initWithArrayController:projectArrayController];
        [projectList setDelegate:tableViewDelegate];
        [projectList setDataSource:tableViewDelegate];

        // this will fetch the first page of projects
        CPLog.debug(@"Loading Projects...");

        // ensure the project array controller knows about object it will be
        // representing.
        [projectArrayController setRepresentedObject:Project];
        [projectArrayController loadRowsForPage:1
                                      withRoute:@"projects"];

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
    PaginatedArrayController  projectArrayController          @accessors;
    CPInteger                 totalNumberOfProjects           @accessors;
}

- (id)initWithArrayController:(CPArrayController)anArrayController
{
    if (self = [super init])
    {
        projectArrayController = anArrayController;
    }

    return self;
}

- (int)numberOfRowsInTableView:(CPTableView)aTableView
{
    CPLog.debug("Project TableView: numberOfRowsInTableView:");
    return [projectArrayController totalObjects];  // debug
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)aRowIndex
{
    CPLog.debug("Project TableView: objectValueForTableColumn:row")
}

- (CPView)tableView:(CPTableView)tableView viewForTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)aRowIndex
{
    CPLog.debug("Project TableView: viewForTableColumn:row");
    //[projectArrayController shouldLoadPageForRow:aRowIndex];

    var view = [tableView makeViewWithIdentifier:[aTableColumn identifier] owner:self];
    //console.log(view);

    return view;
}

@end

