@import <Ratatosk/WLRemoteObject.j>
@import <Ratatosk/WLRemoteTransformers.j>

@implementation Project : WLRemoteObject
{
    CPString    uuid                @accessors;
    CPString    pk                  @accessors;
    CPString    projectName         @accessors;
    CPString    projectCreator      @accessors;
    CPString    projectDescription  @accessors;
    CPObject    projectOwner        @accessors;
    CPString    resourceURI         @accessors;
    // CPArray     pages               @accessors;
    CPDate      created             @accessors;
    CPDate      updated             @accessors;

    CPString    route               @accessors(readonly);
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

- (id)initWithCreator:(User)aCreator
{
    if (self = [self init])
    {
        projectCreator = aCreator;
    }

    return self;
}

+ (CPArray)remoteProperties
{
    return [
        ['uuid', 'uuid'],
        ['pk', 'url'],
        ['projectName', 'name'],
        ['projectDescription', 'description'],
        ['projectCreator', 'creator'],
        // ['pages', 'pages', [WLForeignObjectsTransformer forObjectClass:Page]],
        ['created', 'created', [[WLDateTransformer alloc] init], true],
        ['updated', 'updated', [[WLDateTransformer alloc] init], true]
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