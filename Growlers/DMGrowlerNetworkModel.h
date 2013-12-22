//
//  DMGrowlerNetworkModel.h
//  Growlers
//
//  Created by Daniel Miedema on 12/15/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "DMGrowlerAPI.h"

@interface DMGrowlerNetworkModel : AFHTTPSessionManager

typedef void (^JSONResponseBlock)(id JSON);

//typedef enum {
//    FAVORITE,
//    UNFAVORITE
//} BEER_ACTION;
//
//typedef enum {
//    ALL,
//    ON_TAP
//} SERVER_FLAG;

//+ (DMGrowlerAPI *)sharedInstance;
- (void)getBeersWithFlag:(SERVER_FLAG)flag forStore:(NSString *)store andSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure;
- (void)favoriteBeer:(NSDictionary *)beer withAction:(BEER_ACTION)action withSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure;
- (void)testPushNotifictaionsWithSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure;
- (void)setPreferredStores:(NSArray *)stores forUser:(NSString *)pushID withSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure;
- (void)setSubscribedToSpam;
- (void)resetBadgeCount;

@end
