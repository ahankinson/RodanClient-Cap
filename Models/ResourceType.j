

@implementation ResourceType : WLRemoteObject
{
    CPString        route       @accessors;
}

- (id)init
{
    if (self = [super init])
    {
        route = @"resourcetypes";
    }

    return self;
}

+ (CPArray)remoteProperties
{
    return [
        ['created', 'created', [[WLDateTransformer alloc] init], true],
        ['updated', 'updated', [[WLDateTransformer alloc] init], true]
    ];
}

@end