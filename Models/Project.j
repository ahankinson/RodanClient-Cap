@import <AppKit/CPApplication.j>
@import <Ratatosk/WLRemoteObject.j>
@import <Ratatosk/WLRemoteTransformers.j>

@class User

@implementation Project : WLRemoteObject
{
    CPString    uuid                @accessors;
    CPString    pk                  @accessors;
    CPString    projectName         @accessors;
    User        projectCreator      @accessors;
    CPString    projectDescription  @accessors;
    CPObject    projectOwner        @accessors;
    CPInteger   workflow_count      @accessors;
    CPInteger   resource_count      @accessors;
    CPArray     resources           @accessors;
    CPArray     workflows           @accessors;
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
        ['projectCreator', 'creator', [WLForeignObjectTransformer forObjectClass:User]],
        ['workflows', 'workflows', [WLForeignObjectsTransformer forObjectClass:Workflow]],
        ['resources', 'resources', [WLForeignObjectsTransformer forObjectClass:Resource]],
        ['created', 'created', [[WLDateTransformer alloc] init], true],
        ['updated', 'updated', [[WLDateTransformer alloc] init], true]
    ];
}

@end