//
//  DMGrowlerAPI.m
//  Growlers
//
//  Created by Daniel Miedema on 7/23/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMGrowlerAPI.h"
#import "TSTapstream.h"
//#import "GAI.h"
//#import "GAIDictionaryBuilder.h"

//static NSString *DMGrowlerAPIURLString  = @"http://76.115.252.132:8000";
//static NSString *DMGrowlerAPIURLString  = @"http://shittie.st:8000";
static NSString *DMGrowlerAPIURLString  = @"http://www.growlmovement.com/_app/GrowlersAppPage.php";
//static NSString *DMGrowlerAPIURLString  = @"http://192.168.1.107:8000";
//static NSString *DMGrowlerAPIURLString = @"http://localhost:8000";
@implementation DMGrowlerAPI

+ (DMGrowlerAPI *)sharedInstance {
    static DMGrowlerAPI *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[DMGrowlerAPI alloc] initWithBaseURL:[NSURL URLWithString:DMGrowlerAPIURLString]];
    });
    return sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setParameterEncoding:AFJSONParameterEncoding];
        [self setDefaultHeader:@"application/json" value:@"Accept"];
    }
    return self;
}

- (void)getBeersWithFlag:(SERVER_FLAG)serverAction forStore:(NSString *)store andSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure
{
    NSString *requestUrlString = nil;
    if (serverAction == ALL) {
        requestUrlString = [NSString stringWithFormat:@"%@?store=all", DMGrowlerAPIURLString];
    }
    else {
        requestUrlString = [NSString stringWithFormat:@"%@?store=%@", DMGrowlerAPIURLString, [store lowercaseString]];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrlString]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(JSON);
    }];
    
    [AFNetworkActivityIndicatorManager sharedManager];
    [operation start];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kGrowler_Anonymous_Usage]) {
        TSTapstream *tracker = [TSTapstream instance];
        TSEvent *e = [TSEvent eventWithName:@"getBeers" oneTimeOnly:NO];
        [e addValue:(serverAction == ALL) ? @"all" : store forKey:@"store"];
        [tracker fireEvent:e];
    }
}

- (void)favoriteBeer:(NSDictionary *)beer withAction:(BEER_ACTION)action withSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure
{  
    NSError *error = nil;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:DMGrowlerAPIURLString]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
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
    if (([[NSUserDefaults standardUserDefaults] boolForKey:kGrowler_Anonymous_Usage])) {
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
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

@end
