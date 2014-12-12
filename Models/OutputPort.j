@import <Ratatosk/WLRemoteObject.j>

@class OutputPortType
@class WorkflowJob


@implementation OutputPort : WLRemoteObject
{
    CPString        uuid            @accessors;
    CPString        pk              @accessors;
    OutputPortType  outputPortType  @accessors;
    CPString        label           @accessors;

    CPDate          created         @accessors;
    CPDate          updated         @accessors;

    CPString        route           @accessors(readonly);
}

- (id)init
{
    if (self = [super init])
    {
        route = @"outputports";
    }

    return self;
}

+ (CPArray)remoteProperties
{
    return [
        ['uuid', 'uuid', nil, YES],
        ['pk', 'url', nil, YES],
        ['outputPortType', 'output_port_type', [WLForeignObjectTransformer forObjectClass:OutputPortType]],
        ['label', 'label'],
        ['created', 'created', [[WLDateTransformer alloc] init], YES],
        ['updated', 'updated', [[WLDateTransformer alloc] init], YES]
    ];
}

@end