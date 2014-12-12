@import <Ratatosk/WLRemoteObject.j>

@implementation WorkflowRun : WLRemoteObject
{
    CPString        uuid        @accessors;
    CPString        pk          @accessors;
    Workflow        workflow    @accessors;
    User            creator     @accessors;
    BOOL            testRun     @accessors;
    CPInteger       status      @accessors;

    CPDate          created     @accessors;
    CPDate          updated     @accessors;

    CPString        route       @accessors(readonly);
}

- (id)init
{
    if (self = [super init])
    {
        route = @"workflowruns";
    }

    return self;
}

+ (CPArray)remoteProperties
{
    return [
        ['uuid', 'uuid', nil, YES],
        ['pk', 'url', nil, YES],
        ['workflow', 'workflow', [WLForeignObjectTransformer forObjectClass:Workflow]],
        ['creator', 'creator', [WLForeignObjectTransformer forObjectClass:User]],
        ['testRun', 'test_run'],
        ['status', 'status'],
        ['created', 'created', [[WLDateTransformer alloc] init], YES],
        ['updated', 'updated', [[WLDateTransformer alloc] init], YES]
    ];
}

@end