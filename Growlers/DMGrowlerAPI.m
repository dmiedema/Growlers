//
//  DMGrowlerAPI.m
//  Growlers
//
//  Created by Daniel Miedema on 7/23/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMGrowlerAPI.h"

//static NSString *DMGrowlerAPIURLString  = @"http://76.115.252.132:8000";
static NSString *DMGrowlerAPIURLString  = @"http://192.168.1.107:8000";
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

- (NSMutableURLRequest *)GETRequestForAllBeers {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:DMGrowlerAPIURLString]];
    return request;
}

- (void)getBeersWithSuccess:(JSONResponseBlock)success andFailure:(JSONResponseBlock)failure {
    // [NSURLRequest requestWithURL:[NSURL URLWithString:DMGrowlerAPIURLString]]
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:[self GETRequestForAllBeers] success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(JSON);
    }];
    [operation start];
}

@end