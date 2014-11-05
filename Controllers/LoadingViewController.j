@import <AppKit/CPViewController.j>

@global RodanClientConfigurationHasFinishedNotification
@global RodanClientConfigurationWillStartNotification


@implementation LoadingViewController : CPViewController
{
    @outlet     CPProgressIndicator     loadingProgress;
    @outlet     CPTextField             loadingStatus;
    @outlet     CPImageView             rodanLogo;
}

- (id)initWithCibName:(CPString)aNibName bundle:(CPBundle)aBundle
{
    if (self = [super initWithCibName:@"LoadingView" bundle:nil])
    {
        CPLog.debug(@"Initializing Loading Status View");

        var shadowView = [[CPShadowView alloc] initWithFrame:[[self view] bounds]];
        [[self view] addSubview:shadowView];
        [[self view] setNeedsLayout];
        [[self view] setNeedsDisplay:YES];

        [loadingProgress setIndeterminate:YES];
    }

    return self;
}

- (void)awakeFromCib
{
    [loadingStatus setObjectValue:@"Initializing..."];
}

- (void)updateProgressAndStatus:(CPNotification)aNotification
{
    CPLog.debug(@"Updating progress and status");
    switch ([aNotification name])
    {
        case RodanClientConfigurationWillStartNotification:
            CPLog.debug(@"Routes will start loading; setting status");
            [loadingStatus setObjectValue:@"Loading Configuration from the Server"];
            break;
        case RodanClientConfigurationHasFinishedNotification:
            [loadingStatus setObjectValue:@"Client configuration finished"];
            break;
        default:
            break;
    }
}

@end