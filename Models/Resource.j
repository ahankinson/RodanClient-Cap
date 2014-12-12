@import <Ratatosk/WLRemoteObject.j>

// forward declare these models to avoid circular imports
@class Project
@class User
@class ResourceType
@class Output

@implementation Resource : WLRemoteObject
{
    CPString        pk               @accessors;
    CPString        uuid             @accessors;
    Project         project          @accessors;
    User            creator          @accessors;
    CPString        resourceName     @accessors;
    ResourceType    resourceType     @accessors;
    CPString        resourceFile     @accessors;
    CPString        compatFile       @accessors;
    CPArray         processingStatus @accessors;
    CPString        errorSummary     @accessors;
    CPString        errorDetails     @accessors;
    Output          origin           @accessors;
    BOOL            hasThumb         @accessors;
    CPString        smallThumb       @accessors;
    CPString        mediumThumb      @accessors;
    CPString        largeThumb       @accessors;

    CPDate          created          @accessors;
    CPDate          updated          @accessors;

    CPString        route            @accessors(readonly)
}

- (id)init
{
    if (self = [super init])
    {
        route = @"resources"
    }

    return self;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url', nil, YES],
        ['uuid', 'uuid', nil, YES],
        ['project', 'project', [WLForeignObjectTransformer forObjectClass:Project]],
        ['creator', 'creator', [WLForeignObjectTransformer forObjectClass:User]],
        ['resourceName', 'name'],
        ['resourceType', 'resource_type'],
        ['resourceFile', 'resource_file'],
        ['compatFile', 'compat_resource_file'],
        ['processingStatus', 'processing_status'],
        ['errorSummary', 'error_summary'],
        ['errorDetails', 'error_details'],
        ['origin', 'origin', [WLForeignObjectTransformer forObjectClass:Output]],
        ['created', 'created', [[WLDateTransformer alloc] init], YES],
        ['updated', 'updated', [[WLDateTransformer alloc] init], YES],
        ['hasThumb', 'has_thumb'],
        ['smallThumb', 'small_thumb'],
        ['mediumThumb', 'medium_thumb'],
        ['largeThumb', 'large_thumb']
    ];
}

@end