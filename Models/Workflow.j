

@implementation Workflow : WLRemoteObject
{

    CPString    route       @accessors(readonly);
}

- (id)init
{
    if (self = [super init])
    {
        route = @"workflows";
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