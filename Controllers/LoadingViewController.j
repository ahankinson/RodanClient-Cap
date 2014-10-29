

@implementation LoadingViewController : CPViewController
{
    @outlet     CPProgressIndicator     loadingProgress;
    @outlet     CPTextField             loadingStatus;
    @outlet     CPImageView             rodanLogo;
}

- (id)init
{
    if (self = [super initWithCibName:@"LoadingView" bundle:nil])
    {
        CPLog.debug(@"Initializing Loading Status View");
    }

    return self;
}

@end