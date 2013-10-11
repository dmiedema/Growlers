//
//  DMGrowlerAPI.m
//  Growlers
//
//  Created by Daniel Miedema on 7/23/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMGrowlerAPI.h"
#import "TSTapstream.h"
#import <AFNetworking/AFJSONRequestOperation.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
//#import "GAI.h"
//#import "GAIDictionaryBuilder.h"

static NSString *DMGrowlerAPIURLString  = @"http://www.growlmovement.com/_app/GrowlersAppPage.php";

static NSString *contentTypeValue = @"application/json";
static NSString *contentTypeHeaderPOST = @"Content-Type";
static NSString *contentTypeHeaderGET = @"Accept";

@implementation DMGrowlerAPI

+ (DMGrowlerAPI *)sharedInstance {
    static DMGrowlerAPI *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[DMGrowlerAPI alloc] init];
    });
    return sharedClient;
}

- (void)getBeersWithFlag:(SERVER_FLAG)serverAction forStore:(NSString *)store andSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure
{
    NSString *requestUrlString = nil;
    if (serverAction == ALL) {
        requestUrlString = [NSString stringWithFormat:@"%@?store=all", DMGrowlerAPIURLString];
    }
    else {
        requestUrlString = [NSString stringWithFormat:@"%@?store=%@", DMGrowlerAPIURLString, [[store lowercaseString] stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy]];
    }
    
    NSLog(@"request url = %@", requestUrlString);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrlString]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(JSON);
    }];
    
    [AFNetworkActivityIndicatorManager sharedManager];
    [operation start];
    
    if ([DMDefaultsInterfaceConstants anonymousUsage]) {
        TSTapstream *tracker = [TSTapstream instance];
        TSEvent *e = [TSEvent eventWithName:@"getBeers" oneTimeOnly:NO];
        [e addValue:(serverAction == ALL) ? @"all" : store forKey:@"store"];
        [tracker fireEvent:e];
    }
}

- (void)favoriteBeer:(NSDictionary *)beer withAction:(BEER_ACTION)action withSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure
{
    NSLog(@"GrowlersAPI Model --  Favorite beer - %@", beer);
    NSError *error = nil;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:DMGrowlerAPIURLString]];
    request.HTTPMethod = @"POST";
    [request setValue:contentTypeValue forHTTPHeaderField:contentTypeHeaderPOST];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:beer options:kNilOptions error:&error];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error favoritng - %@", error);
        failure(JSON);
    }];
    [AFNetworkActivityIndicatorManager sharedManager];
    [operation start];
    
    // What am i doing with this?
    
    if ([DMDefaultsInterfaceConstants anonymousUsage]) {
//        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        if (action == FAVORITE) {
            NSLog(@"Favorite Beer");
            NSLog(@"%@", beer);
            TSEvent *e = [TSEvent eventWithName:@"FavoriteBeer" oneTimeOnly:NO];
            [[TSTapstream instance] fireEvent:e];
//            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Beer Action"
//                                                                  action:@"favorite"
//                                                                   label:@""
//                                                                   value:nil] build]];
        } else {
            NSLog(@"Unfavorite Beer");
            NSLog(@"%@", beer);
            TSEvent *e = [TSEvent eventWithName:@"UnfavoriteBeer" oneTimeOnly:NO];
            [[TSTapstream instance] fireEvent:e];
//            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Beer Action"
//                                                                  action:@"unfavorite"
//                                                                   label:@""
//                                                                   value:nil] build]];
        }
    }
}

- (void)testPushNotifictaionsWithSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:DMGrowlerAPIURLString]];
    
    NSDictionary *data = @{@"message": @"Test Notification", @"udid": [DMDefaultsInterfaceConstants pushID]};
    NSError *error = nil;
    
    request.HTTPMethod = @"POST";
    [request setValue:contentTypeValue forHTTPHeaderField:contentTypeHeaderPOST];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(JSON);
    }];
    [operation start];
    
    if ([DMDefaultsInterfaceConstants anonymousUsage]) {
        TSEvent *e = [TSEvent eventWithName:@"Test Push" oneTimeOnly:NO];
        [[TSTapstream instance] fireEvent:e];
        //            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Notifications"
        //                                                                  action:@"Store Set"
        //                                                                   label:@""
        //                                                                   value:nil] build]];
    }
}

- (void)setPreferredStores:(NSArray *)stores forUser:(NSString *)pushID withSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure
{
    NSLog(@"Setting preferred stores for user");
    NSError *error = nil;
    if (!pushID) {
        pushID = [DMDefaultsInterfaceConstants generatedUDID];
    }
    NSDictionary *data = @{@"stores": stores, @"udid": pushID};
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:DMGrowlerAPIURLString]];
    request.HTTPMethod = @"POST";
    [request setValue:contentTypeValue forHTTPHeaderField:contentTypeHeaderPOST];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:&error];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        success(JSON);
        NSLog(@"reponse - %@", response);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(JSON);
        NSLog(@"reponse - %@", response);
        NSLog(@"error %@ -- message: %@", error, error.userInfo);
    }];
    [operation start];
    
    if ([DMDefaultsInterfaceConstants anonymousUsage]) {
        NSLog(@"Reset stores");
        NSLog(@"%@", stores);
        TSEvent *e = [TSEvent eventWithName:@"Reset Store Notifications" oneTimeOnly:NO];
        [[TSTapstream instance] fireEvent:e];
        //            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Notifications"
        //                                                                  action:@"Store Set"
        //                                                                   label:@""
        //                                                                   value:nil] build]];
    }
}

@end
