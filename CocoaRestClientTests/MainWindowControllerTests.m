//
//  MainWindowControllerTests.m
//  CocoaRestClientTests
//
//  Created by Mike Mattozzi on 4/21/19.
//

#import <XCTest/XCTest.h>
#import "MainWindowController.h"

@interface MainWindowControllerTests : XCTestCase {
    MainWindowController *mainWindowController;
}

@end

@implementation MainWindowControllerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    mainWindowController = [[MainWindowController alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEnvVariableOneSubstitution {
    NSDictionary *environmentVariables = [[NSProcessInfo processInfo] environment];
    NSString *user = [environmentVariables objectForKey:@"USER"];
    NSString *expected = [NSString stringWithFormat:@"User has %@ username", user];
    
    NSString *result = [mainWindowController substituteEnvVariables:@"User has ${USER} username"];
    
    XCTAssertEqualObjects(expected, result);
}

@end
