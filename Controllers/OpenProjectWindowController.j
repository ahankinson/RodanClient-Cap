@import <AppKit/CPWindowController.j>


@implementation OpenProjectWindowController : CPWindowController
{
    @outlet     CPTableView         projectTable;
    @outlet     CPButton            openProjectButton;
}

- (id)init
{
    if (self = [self initWithWindowCibName:@"OpenProjectWindow" owner:self])
    {
    }

    return self;
}

#pragma mark Actions

- (@action)openProject:(id)aSender
{
    // TODO
    CPLog.debug('open project');
}
@end