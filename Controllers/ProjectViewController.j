@import <AppKit/CPViewController.j>

@implementation ProjectViewController : CPViewController
{
    @outlet     CPButtonBar         projectAddRemoveButtonBar;
    @outlet     CPTableView         projectList;
}

- (id)init
{
    if (self = [super initWithCibName:@"ProjectView" bundle:nil])
    {

    }

    return self;
}

@end