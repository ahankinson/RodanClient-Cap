@import <Ratatosk/WLRemoteObject.j>

@implementation Job : WLRemoteObject
{
    CPString    uuid            @accessors;
    CPString    pk              @accessors;
    CPString    jobName         @accessors;
    CPString    author          @accessors;
    CPString    category        @accessors;
    CPString    description     @accessors;
    JSObject    settings        @accessors;
    BOOL        enabled         @accessors;
    BOOL        interactive     @accessors;

    CPString    route           @accessors(readonly);
}

- (id)init
{
    if (self = [super init])
    {
        route = @"jobs";
    }

    return self;
}

/*
 *  Job properties are read-only (cannot be changed on the client).
 */
+ (CPArray)remoteProperties
{
    return [
        ['uuid', 'uuid', nil, YES],
        ['pk', 'url', nil, YES],
        ['jobName', 'job_name', nil, YES],
        ['author', 'author', nil, YES],
        ['category', 'category', nil, YES],
        ['description', 'description', nil, YES],
        ['settings', 'settings', nil, YES],
        ['enabled', 'enabled', nil, YES],
        ['interactive', 'interactive', nil, YES]
    ];
}

@end