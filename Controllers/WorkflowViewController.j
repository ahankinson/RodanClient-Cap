@import <AppKit/CPViewController.j>

@implementation WorkflowViewController : CPViewController
{
}

- (id)init
{
    var localizedCibFile = [[CPBundle mainBundle] bundleLocale] + @".lproj/WorkflowView";
    if (self = [super initWithCibName:localizedCibFile bundle:nil])
    {
    }

    return self;
}

@end