//
//  DMGrowlerAPI.h
//  Growlers
//
//  Created by Daniel Miedema on 7/23/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "AFHTTPClient.h"

typedef void (^JSONResponseBlock)(id JSON);

@interface DMGrowlerAPI : AFHTTPClient
+ (DMGrowlerAPI *)sharedInstance;
- (NSMutableURLRequest *)GETRequestForAllBeers;
- (void)getBeersWithSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure;
@end
