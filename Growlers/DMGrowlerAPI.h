//
//  DMGrowlerAPI.h
//  Growlers
//
//  Created by Daniel Miedema on 7/23/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "AFHTTPClient.h"
//#import "AFHTTPClient+Rocket.h"

typedef void (^JSONResponseBlock)(id JSON);

typedef enum {
  FAVORITE,
  UNFAVORITE
} BEER_ACTION;

typedef enum {
    ALL,
    ON_TAP
} SERVER_FLAG;

@interface DMGrowlerAPI : AFHTTPClient
+ (DMGrowlerAPI *)sharedInstance;
- (void)getBeersWithFlag:(SERVER_FLAG)flag forStore:(NSString *)store andSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure;
- (void)favoriteBeer:(NSDictionary *)beer withAction:(BEER_ACTION)action withSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure;
- (void)testPushNotifictaionsWithSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure;
@end
