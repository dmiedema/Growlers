//
//  DMGrowlerNetworkModel.m
//  Growlers
//
//  Created by Daniel Miedema on 12/15/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMGrowlerNetworkModel.h"

@interface DMGrowlerNetworkModel()
@end

#if DEV
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
    }
    return self;
}

#pragma mark Implementation

- (void)getBeersWithFlag:(SERVER_FLAG)flag forStore:(NSString *)store andSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure
{
    NSDictionary *params;
    if (flag == ALL) {
        params = @{@"store": @"all"};
    }
    else {
        params = @{@"store": [store stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy]};
    }

    [self GET:DMGrowlerAPIURLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSLog(@"response - %@", responseObject);
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // "cancelled" code == -999
        if (error.code == -999) {
            return;
        }
        NSLog(@"failure - %@", error);
        failure(error);
    }];
}
- (void)favoriteBeer:(NSDictionary *)beer withAction:(BEER_ACTION)action withSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure
{
    
}
- (void)testPushNotifictaionsWithSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure
{
    
}
- (void)setPreferredStores:(NSArray *)stores forUser:(NSString *)pushID withSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure
{
    
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
}

- (void)resetBadgeCount
{
    NSString *token = [DMDefaultsInterfaceConstants getValidUniqueID];
    
    [self POST:DMGrowlerAPIURLString
    parameters:@{@"udid": token, @"key": @"reset-badge-count"}
       success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
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
