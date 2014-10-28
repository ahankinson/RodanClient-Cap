@import <OJUnit/OJTestCase.j>
@import "../../Models/ApplicationStatus.j"

RodanSetRoutesNotification = @"RodanSetRoutesNotification";
RodanRoutesHaveLoadedNotification = @"RodanRoutesHaveLoadedNotification";

@implementation ApplicationStatusTest : OJTestCase
{
    ApplicationStatus       appStatus;
}

- (void)setUp
{
    appStatus = [[ApplicationStatus alloc] init];
}

- (void)testApplicationStartup
{

}

@end

