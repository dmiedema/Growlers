//
//  DMGrowlerNetworkModel.h
//  Growlers
//
//  Created by Daniel Miedema on 12/15/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface DMGrowlerNetworkModel : AFHTTPSessionManager

typedef void (^JSONResponseBlock)(id JSON);

- (void)getBeersForStore:(NSString *)store withSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure;
- (void)favoriteBeer:(NSDictionary *)beer withSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure;
- (void)unFavoriteBeer:(NSDictionary *)beer withSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure;

- (void)testPushNotifictaionsWithSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure;
- (void)setPreferredStores:(NSArray *)stores forUser:(NSString *)pushID withSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure;

- (void)setSubscribedToSpam;
- (void)resetBadgeCount;
- (void)cancelAllGETs;

@end
