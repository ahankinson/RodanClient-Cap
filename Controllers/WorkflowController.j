
@implementation WorkflowController : CPObject
{
    @outlet     CPArrayController       workflowArrayController;
}

- (id)init
{
    if (self = [super init])
    {
        CPLog.debug(@"Initializing Workflow Controller");
    }

    return self;
}

@end