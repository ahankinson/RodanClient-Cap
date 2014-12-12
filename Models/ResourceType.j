@import <Ratatosk/WLRemoteObject.j>


@implementation ResourceType : WLRemoteObject
{
    CPString        uuid            @accessors;
    CPString        pk              @accessors;
    CPString        mimeType        @accessors;
    CPString        description     @accessors;
    CPString        extension       @accessors;

    CPDate          created         @accessors;
    CPDate          updated         @accessors;

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
        ['uuid', 'uuid', nil, YES],
        ['pk', 'url', nil, YES],
        ['mimeType', 'mimetype'],
        ['description', 'description'],
        ['extension', 'extension'],
        ['created', 'created', [[WLDateTransformer alloc] init], YES],
        ['updated', 'updated', [[WLDateTransformer alloc] init], YES]
    ];
}

@end