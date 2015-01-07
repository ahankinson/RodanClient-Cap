@import <AppKit/CPViewController.j>

@global RodanDidFinishLoadingWorkflowNotification
@global RodanShouldShowWorkflowViewNotification

@implementation WorkflowViewController : CPViewController
{
    @outlet         WorkflowController      workflowController;
    @outlet         CPArrayController       workflowArrayController;
}

- (id)init
{
    var localizedCibFile = [[CPBundle mainBundle] bundleLocale] + @".lproj/WorkflowView";
    if (self = [super initWithCibName:localizedCibFile bundle:nil])
    {
        [[CPNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(activateWorkflowView:)
                                                     name:RodanShouldShowWorkflowViewNotification
                                                   object:nil];
    }

    return self;
}

- (void)workflowHasLoaded:(CPNotification)aNotification
{
}

- (void)activateWorkflowView:(CPNotification)aNotification
{
    var workflowView = [self view],
        contentScrollView = [[CPApp delegate] contentScrollView];

    [workflowView setFrame:[contentScrollView bounds]];
    [workflowView setAutoresizingMask:CPViewWidthSizable];
    [contentScrollView setDocumentView:workflowView];

}

@end