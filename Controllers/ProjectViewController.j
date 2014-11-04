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

        [projectList bind:@"content"
                 toObject:projectArrayController
              withKeyPath:@"arrangedObjects"
                  options:nil];

        [projectListProjectName bind:@"value"
                            toObject:projectListCellView
                         withKeyPath:@"objectValue.projectName"
                             options:nil];

        [projectListProjectDescription bind:@"value"
                                   toObject:projectListCellView
                                withKeyPath:@"objectValue.projectDescription"
                                    options:nil];
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