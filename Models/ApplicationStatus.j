@import <Foundation/CPObject.j>

@global RodanRoutesHaveLoadedNotification

@implementation ApplicationStatus : CPObject
{
    CPDictionary         startupStages;
}

- (id)init
{
    if (self = [super init])
    {
        startupStages = @{
                            @"loadRoutes": false
                        };

        [[CPNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationStartupStatus:)
                                                     name:RodanStartupStageComplete
                                                   object:nil];
    }

    return self;
}

- (void)applicationStartupStatus:(CPNotification)aNotification
{
}

@end