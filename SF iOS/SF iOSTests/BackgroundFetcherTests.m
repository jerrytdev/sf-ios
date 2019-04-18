//
//  BackgroundFetcherTests.m
//  SF iOSTests
//
//  Created by Jerry Tung on 4/17/19.
//

#import <XCTest/XCTest.h>
#import "BackgroundFetcher.h"

@interface BackgroundFetcherTests : XCTestCase
@property (nonatomic) BackgroundFetcher *bgFetcher;
@end

@implementation BackgroundFetcherTests

- (void)performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    self.bgFetcher = [[BackgroundFetcher alloc] initWithCompletionHandler:^(UIBackgroundFetchResult result) {
        
    }];
}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
//    - (instancetype)initWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSource {
    [self performFetchWithCompletionHandler:^(UIBackgroundFetchResult result) {

    }];
    XCTAssertNotNil(self.bgFetcher);
}


@end
