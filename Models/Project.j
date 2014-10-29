@import <Ratatosk/WLRemoteObject.j>

@implementation Project : WLRemoteObject
{
    CPString    projectName     @accessors;
    CPString    projectCreator  @accessors;

    CPString    route           @accessors(readonly);
}

- (id)init
{
    if (self = [super init])
    {
        route = @"projects";

        projectName = @"Untitled Project";
    }

    return self;
}

+ (CPArray)remoteProperties
{
    return [
        ['uuid', 'uuid'],
        ['pk', 'url'],
        ['projectName', 'name'],
        ['projectCreator', 'creator']
    ];
}

- (CPString)remotePath
{
    if ([self pk])
        return [self pk];
    else
        return [[[CPApp delegate] serverController] routeForRouteName:[self route]];
}
@end