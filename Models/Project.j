@import <AppKit/CPApplication.j>
@import <Ratatosk/WLRemoteObject.j>
@import <Ratatosk/WLRemoteTransformers.j>

/*
 *  Classes are forward-declared instead of explicitly imported
 *  to avoid problems with circular imports.
 */
@class User
@class Workflow
@class Resource

/*
 *  This class is a reference for other Model objects. Other model objects
 *  will be minimally commented, but you should refer to this model for notes on
 *  how WLRemoteObject models function within Rodan.
 *  
 *  For the class properties, the `@accessors` is necessary to enable key/value observing
 *  of model objects. Properties that are set from the server (e.g., `pk`) should still 
 *  have the full accessor suite since Ratatosk uses `setPROPERTYNAME` methods internally.
 *  
 *  The `route` property, however, is not mirrored in the Rodan server and can be set to 
 *  readonly.
 */

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
    CPArray     resources           @accessors;     // Array<Resource>
    CPArray     workflows           @accessors;     // Array<Workflow>
    CPDate      created             @accessors;
    CPDate      updated             @accessors;

    CPString    route               @accessors(readonly);
}

/*
 *  All model objects should implement an `init` method that sets the `route` parameter.
 *  This is used by the `remotePath` method to automatically detect and set the route from the Rodan server
 *  to the appropriate URL.
 *  
 *  See Categories/WLRemoteObject+RemotePath.j for details on how the `remotePath` method works.
 */

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

/*
 *  Returns an array of arrays mapping the class properties to the remote (JSON-delivered)
 *  parameters from a Rodan server.
 *  
 *  Format:
 *  ['classProperty', 'server_property', [TransformerObject], (BOOL)readonly];
 *  
 *  Using the [WLForeignObjectsTransformer] (note the plural "Objects") will automatically
 *  convert all the objects in a JSON array to a CPArray carrying the corresponding ObjJ Rodan model objects.
 *  
 *  A singular [WLForeignObjectTransformer] will convert the JSON object directly.
 */
+ (CPArray)remoteProperties
{
    return [
        ['uuid', 'uuid', nil, YES],
        ['pk', 'url', nil, YES],
        ['projectName', 'name'],
        ['projectDescription', 'description'],
        ['projectCreator', 'creator', [WLForeignObjectTransformer forObjectClass:User]],
        ['workflows', 'workflows', [WLForeignObjectsTransformer forObjectClass:Workflow]],
        ['resources', 'resources', [WLForeignObjectsTransformer forObjectClass:Resource]],
        ['created', 'created', [[WLDateTransformer alloc] init], YES],
        ['updated', 'updated', [[WLDateTransformer alloc] init], YES]
    ];
}

@end