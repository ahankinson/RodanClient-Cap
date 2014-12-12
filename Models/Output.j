@import <Ratatosk/WLRemoteObject.j>

@class RunJob
@class Resource

@implementation Output : WLRemoteObject
{
    CPString        uuid            @accessors;
    CPString        pk              @accessors;
    RunJob          runJob          @accessors;
    Resource        resource        @accessors;

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
        ['created', 'created', [[WLDateTransformer alloc] init], true],
        ['updated', 'updated', [[WLDateTransformer alloc] init], true]
    ];
}

@end