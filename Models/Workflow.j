@import <Ratatosk/WLRemoteObject.j>

@class Project
@class User

@implementation Workflow : WLRemoteObject
{
    CPString        uuid        @accessors;
    CPString        pk          @accessors;
    CPString        name        @accessors;
    Project         project     @accessors;
    CPString        description @accessors;
    User            creator     @accessors;
    BOOL            valid       @accessors;

    CPDate          created     @accessors;
    CPDate          updated     @accessors;

    CPString        route       @accessors(readonly);
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
        ['pk', 'url', nil, YES],
        ['uuid', 'uuid', nil, YES],
        ['name', 'name'],
        ['project', 'project', [WLForeignObjectTransformer forObjectClass:Project]],
        ['description', 'description'],
        ['creator', 'creator', [WLForeignObjectTransformer forObjectClass:User]],
        ['valid', 'valid'],
        ['created', 'created', [[WLDateTransformer alloc] init], YES],
        ['updated', 'updated', [[WLDateTransformer alloc] init], YES]
    ];
}

@end