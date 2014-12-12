@import <Ratatosk/WLRemoteObject.j>

@class Workflow
@class Job

@implementation WorkflowJob : WLRemoteObject
{
    CPString    uuid            @accessors;
    CPString    pk              @accessors;
    Workflow    workflow        @accessors;
    Job         job             @accessors;
    CPArray     jobSettings     @accessors;

    CPDate      created         @accessors;
    CPDate      updated         @accessors;

    CPString    route           @accessors(readonly);
}

- (id)init
{
    if (self = [super init])
    {
        route = @"workflowjobs";
    }

    return self;
}

+ (CPArray)remoteProperties
{
    return [
        ['uuid', 'uuid', nil, YES],
        ['pk', 'url', nil, YES],
        ['workflow', 'workflow', [WLForeignObjectTransformer forObjectClass:Workflow]],
        ['job', 'job', [WLForeignObjectTransformer forObjectClass:Job]],
        ['jobSettings', 'job_settings'],
        ['created', 'created', [[WLDateTransformer alloc] init], YES],
        ['updated', 'updated', [[WLDateTransformer alloc] init], YES]
    ];
}

@end