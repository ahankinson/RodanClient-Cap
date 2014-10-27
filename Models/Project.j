@import <Ratatosk/WLRemoteObject.j>


@implementation Project : WLRemoteObject
{
    CPString    projectName     @accessors;
    CPString    projectCreator  @accessors;
}

- (id)init
{
    if (self = [super init])
    {
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
        return [[CPBundle mainBundle] objectForInfoDictionaryKey:@"ServerHost"] + @"/projects/";
}

@end