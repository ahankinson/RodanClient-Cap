@import <Ratatosk/WLRemoteObject.j>

@implementation User : WLRemoteObject
{
    CPString    pk                  @accessors;
    CPString    username            @accessors;
    CPString    firstName           @accessors;
    CPString    lastName            @accessors;
    CPArray     groups              @accessors;
    BOOL        isActive            @accessors;
    BOOL        isStaff             @accessors;
    BOOL        isSuperuser         @accessors;
    CPString    email               @accessors;
    CPString    authenticationToken @accessors;

    CPString    route               @accessors(readonly);
}

- (id)init
{
    if (self = [super init])
    {
        route = @"users";
    }

    return self;
}

+ (CPArray)remoteProperties
{
    return [
        ['pk', 'url', nil, YES],
        ['username', 'username'],
        ['firstName', 'first_name'],
        ['lastName', 'last_name'],
        ['isActive', 'is_active'],
        ['isStaff', 'is_staff'],
        ['isSuperuser', 'is_superuser'],
        ['email', 'email'],
        ['groups', 'groups'],
        ['authenticationToken', 'token', nil, YES]
    ];
}

@end