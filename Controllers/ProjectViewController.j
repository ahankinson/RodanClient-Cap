@import <AppKit/CPViewController.j>

@implementation ProjectViewController : CPViewController
{
    @outlet     CPArrayController       workflowArrayController;
    @outlet     CPArrayController       resourceArrayController;
}

- (id)init
{
    var localizedCibFile = [[CPBundle mainBundle] bundleLocale] + @".lproj/ProjectView";
    if (self = [super initWithCibName:localizedCibFile bundle:nil])
    {
    }

    return self;
}

@end