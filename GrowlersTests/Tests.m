//
//  Tests.m
//  Growlers
//
//  Created by Daniel Miedema on 11/9/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <XCTest/XCTest.h>
// Necessary Imports
#import "DMGrowlerAPI.h"
#import "DMCoreDataMethods.h"
#import "DMHelperMethods.h"
#import "DMDefaultsInterfaceConstants.h"
#import "DMAppDelegate.h"

@interface Tests : XCTestCase
@property (nonatomic, strong) DMCoreDataMethods *coreData;
@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testUserDefaults
{
    NSString *lastStore = @"keizer";
    [DMDefaultsInterfaceConstants setLastStore:lastStore];
    XCTAssertEqual([DMDefaultsInterfaceConstants lastStore], lastStore, @"Last Store Failed to be Set correctly");
    
    [DMDefaultsInterfaceConstants setMultipleStoresEnabled:YES];
    XCTAssertTrue([DMDefaultsInterfaceConstants multipleStoresEnabled], @"Failed to set multiple stores enabled");
    
    [DMDefaultsInterfaceConstants setPreferredStore:lastStore];
    XCTAssertEqual([DMDefaultsInterfaceConstants preferredStore], lastStore, @"Preferred store Failed to set");
    
    [DMDefaultsInterfaceConstants setPreferredStore:nil];
    XCTAssertNil([DMDefaultsInterfaceConstants preferredStore], @"Preferred store was set to nil");
    
    [DMDefaultsInterfaceConstants setPreferredStoresSynced:YES];
    XCTAssertTrue([DMDefaultsInterfaceConstants preferredStoresSynced], @"PreferredStoresSynced Failed to set");
    
    [DMDefaultsInterfaceConstants setShowCurrentStoreOnTapList:NO];
    XCTAssertFalse([DMDefaultsInterfaceConstants showCurrentStoreOnTapList], @"showCurrentStoreOnTap Failed to set");
    
    NSString *secondStore = @"south salem";
    [DMDefaultsInterfaceConstants setPreferredStores:@[lastStore, secondStore]];
    XCTAssertEqual([DMDefaultsInterfaceConstants preferredStores].count, 2, @"NOT 2 stores in preferred stores - Instead there are %i", [DMDefaultsInterfaceConstants preferredStores].count);
    XCTAssertTrue([[DMDefaultsInterfaceConstants preferredStores] containsObject:lastStore], @"preferred stores does NOT contain -- %@", lastStore);
}

- (void)testHelperMethods
{
}

- (void)testCoreData
{
}

- (void)testNetwork
{
}

@end
