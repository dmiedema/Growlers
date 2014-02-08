//
//  DMGrowlerNetworkModel.m
//  Growlers
//
//  Created by Daniel Miedema on 12/15/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMGrowlerNetworkModel.h"
#import "TSTapstream.h"

@interface DMGrowlerNetworkModel() <NSURLSessionDownloadDelegate>
@end

#if DEV == 1
static NSString *DMGrowlerAPIURLString  = @"http://www.growlmovement.com/_app/GrowlersAppPage-dev.php";
#else
static NSString *DMGrowlerAPIURLString  = @"http://www.growlmovement.com/_app/GrowlersAppPage.php";
#endif

@implementation DMGrowlerNetworkModel

# pragma mark init
+ (instancetype)manager
{
    static DMGrowlerNetworkModel *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *DMGrowlerAPIURL = [NSURL URLWithString:DMGrowlerAPIURLString];
        sharedClient = [[DMGrowlerNetworkModel alloc] initWithBaseURL:DMGrowlerAPIURL];
    });
    return sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [self setDataTaskDidReceiveDataBlock:^(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data) {
            NSLog(@"Total Expected to Receive - %lli", dataTask.countOfBytesExpectedToReceive);
            NSLog(@"Received - %lli", dataTask.countOfBytesReceived);
        }];
    }
    return self;
}

#pragma mark Implementation

- (void)getBeersForStore:(NSString *)store withSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure
{
    NSDictionary *params = @{@"store": [store stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy]};
    [self GET:DMGrowlerAPIURLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // error.code -999 means request was cancelled. Don't need to log cancelled request.
        if (error.code == -999) {
            return;
        }
        failure(error);
    }];
    
    /* Anonymouse Usage */
    if ([DMDefaultsInterfaceConstants anonymousUsage]) {
        TSTapstream *tracker = [TSTapstream instance];
        TSEvent *e = [TSEvent eventWithName:@"getBeers" oneTimeOnly:NO];
        [e addValue:store forKey:@"store"];
        [tracker fireEvent:e];
    }
}

- (void)favoriteBeer:(NSDictionary *)beer withSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure
{
    if (beer[@"fav"] == nil || beer[@"fav"] == [NSNull null]) {
        NSMutableDictionary *mutableBeer = [beer mutableCopy];
        [mutableBeer setValue:@(YES) forKey:@"fav"];
        beer = mutableBeer;
    }
    
    [self POST:DMGrowlerAPIURLString parameters:beer success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
    
    /* Anonymouse Usage */
    if ([DMDefaultsInterfaceConstants anonymousUsage]) {
        TSEvent *e = [TSEvent eventWithName:@"FavoriteBeer" oneTimeOnly:NO];
        [[TSTapstream instance] fireEvent:e];

    }
}

- (void)unFavoriteBeer:(NSDictionary *)beer withSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure
{
    if (beer[@"fav"] == nil || beer[@"fav"] == [NSNull null]) {
        NSMutableDictionary *mutableBeer = [beer mutableCopy];
        [mutableBeer setValue:@(NO) forKey:@"fav"];
        beer = mutableBeer;
    }
    
    [self POST:DMGrowlerAPIURLString parameters:beer success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
    
    /* Anonymouse Usage */
    if ([DMDefaultsInterfaceConstants anonymousUsage]) {
        TSEvent *e = [TSEvent eventWithName:@"UnfavoriteBeer" oneTimeOnly:NO];
        [[TSTapstream instance] fireEvent:e];
    }
}

- (void)testPushNotifictaionsWithSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure
{
    NSString *token = [DMDefaultsInterfaceConstants getValidUniqueID];
    
    NSDictionary *data = @{@"message": @"Test Notification", @"udid": token};
    
    [self POST:DMGrowlerAPIURLString parameters:data success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // Cocoa error -- parsing the response failes because of incorrectly formatted JSON
        // and if that is the case, it's not a failute of the push test.
        if (error.code == 3840) {
            return;
        }
        failure(error);
    }];
    
    /* Anonymouse Usage */
    if ([DMDefaultsInterfaceConstants anonymousUsage]) {
        TSEvent *e = [TSEvent eventWithName:@"Test Push" oneTimeOnly:NO];
        [[TSTapstream instance] fireEvent:e];
    }
}
- (void)setPreferredStores:(NSArray *)stores forUser:(NSString *)token withSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure
{
    if (!token) {
        token = [DMDefaultsInterfaceConstants getValidUniqueID];
    }
    NSDictionary *data = @{@"stores": stores, @"udid": token};
    
    [self POST:DMGrowlerAPIURLString parameters:data success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
    
    /* Anonymoose Usage */
    if ([DMDefaultsInterfaceConstants anonymousUsage]) {
        NSLog(@"Reset stores");
        NSLog(@"%@", stores);
        TSEvent *e = [TSEvent eventWithName:@"Reset Store Notifications" oneTimeOnly:NO];
        [[TSTapstream instance] fireEvent:e];
    }
}

- (void)setSubscribedToSpam
{
    NSString *token = [DMDefaultsInterfaceConstants getValidUniqueID];
    BOOL subscribed = [DMDefaultsInterfaceConstants subscribedToSpam];
    [self POST:DMGrowlerAPIURLString
    parameters:@{@"udid":token, @"subscribe-user-to-spame":@(subscribed)}
       success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    /* Anonymoose Usage */
    if ([DMDefaultsInterfaceConstants anonymousUsage]) {
        NSString *eventName = (subscribed)
            ? @"Subscribe user to spam"
            : @"Unsubscribe user from spam";
        TSEvent *e = [TSEvent eventWithName:eventName oneTimeOnly:NO];
        [[TSTapstream instance] fireEvent:e];
    }
}

- (void)resetBadgeCount
{
    NSString *token = [DMDefaultsInterfaceConstants getValidUniqueID];

        NSLog(@"Tell server to reset badge count for %@", token);
    
    [self POST:DMGrowlerAPIURLString
    parameters:@{@"udid": token, @"key": @"reset-badge-count"}
       success:^(NSURLSessionDataTask *task, id responseObject) {
           NSLog(@"Reset badge count success");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
           NSLog(@"Reset badge count failed");
        NSLog(@"error - %@", error);
    }];
}

- (void)cancelAllGETs
{
    for (NSURLSessionDataTask *task in self.tasks) {
        NSURLRequest *originalRequest = task.originalRequest;
        if ([originalRequest.HTTPMethod isEqualToString:@"GET"]) {
            [task cancel];
        }
    }
}

@end
