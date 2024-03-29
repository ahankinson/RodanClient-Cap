@import <Ratatosk/WLRemoteObject.j>

@class RunJob
@class Resource
@class OutputPort

@implementation Output : WLRemoteObject
{
    CPString        uuid            @accessors;
    CPString        pk              @accessors;
    RunJob          runJob          @accessors;
    Resource        resource        @accessors;
    OutputPort      outputPort      @accessors;

    CPDate          created         @accessors;
    CPDate          updated         @accessors;

    CPString        route           @accessors(readonly);

}

- (id)init
{
    if (self = [super init])
    {
        route = @"outputs";
    }

    return self;
}

+ (CPArray)remoteProperties
{
    return [
        ['uuid', 'uuid', nil, YES],
        ['pk', 'url', nil, YES],
        ['ouptutPort', 'output_port', [WLForeignObjectTransformer forObjectClass:OutputPort]],
        ['resource', 'resouce', [WLForeignObjectTransformer forObjectClass:Resource]],
        ['runJob', 'run_job', [WLForeignObjectTransformer forObjectClass:RunJob]],
        ['created', 'created', [[WLDateTransformer alloc] init], YES],
        ['updated', 'updated', [[WLDateTransformer alloc] init], YES]
    ];
}

@end