@import <AppKit/CPWindowController.j>


@implementation NewProjectWindowController : CPWindowController

- (id)init
{
    if (self = [self initWithWindowCibName:@"NewProjectWindow" owner:self])
    {
    }

    return self;
}

@end