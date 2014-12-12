@import <Ratatosk/WLRemoteObject.j>

@class WorkflowRun
@class WorkflowJob

@implementation RunJob : WLRemoteObject
{
    CPString        uuid            @accessors;
    CPString        pk              @accessors;
    WorkflowRun     workflowRun     @accessors;
    WorkflowJob     workflowJob     @accessors;
    CPArray         jobSettings     @accessors;
    BOOL            readyForInput   @accessors;
    CPInteger       status          @accessors;
    CPString        celeryTaskId    @accessors;
    CPString        errorSummary    @accessors;
    CPString        errorDetails    @accessors;

    CPDate          created         @accessors;
    CPDate          updated         @accessors;

    CPString        route           @accessors;
}

- (id)init
{
    if (self = [super init])
    {
        route = 'runjobs';
    }

    return self;
}

+ (CPArray)remoteProperties
{
    return [
        ['uuid', 'uuid', nil, YES],
        ['pk', 'url', nil, YES],
        ['workflowRun', 'workflow_run', [WLForeignObjectTransformer objectForClass:WorkflowRun]],
        ['workflowJob', 'workflow_job', [WLForeignObjectTransformer objectForClass:WorkflowJob]],
        ['jobSettings', 'job_settings'],
        ['readyForInput', 'ready_for_input'],
        ['status', 'status'],
        ['celeryTaskId', 'celery_task_id'],
        ['errorSummary', 'error_summary'],
        ['errorDetails', 'error_details'],
        ['created', 'created', [[WLDateTransformer alloc] init], YES],
        ['updated', 'updated', [[WLDateTransformer alloc] init], YES]
    ];
}

@end