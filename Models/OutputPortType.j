@import <Ratatosk/WLRemoteObject.j>

@class Job
@class ResourceType

@implementation OutputPortType : WLRemoteObject
{
    CPString        uuid            @accessors;
    CPString        pk              @accessors;
    CPString        name            @accessors;
    Job             job             @accessors;
    CPArray         resourceTypes   @accessors;     // Array<ResourceType>
    CPInteger       minimum         @accessors;
    CPInteger       maximum         @accessors;

    CPDate          created         @accessors;
    CPDate          updated         @accessors;

    CPString        route           @accessors(readonly);
}

- (id)init
{
    if (self = [super init])
    {
        route = @"outputporttypes";
    }

    return self;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url', nil, YES],
        ['uuid', 'uuid', nil, YES],
        ['job', 'job', [WLForeignObjectTransformer forObjectClass:Job]],
        ['name', 'name'],
        ['resourceTypes', 'resource_types', [WLForeignObjectsTransformer forObjectClass:ResourceType]],
        ['minimum', 'minimum'],
        ['maximum', 'maximum'],
        ['created', 'created', [[WLDateTransformer alloc] init], YES],
        ['updated', 'updated', [[WLDateTransformer alloc] init], YES]
    ];
}

@end