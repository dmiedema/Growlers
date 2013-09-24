//
//  DMDefaultsInterfaceConstants.h
//  Growlers
//
//  Created by Daniel Miedema on 9/20/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMDefaultsInterfaceConstants : NSObject
// Getters
+ (BOOL)anonymousUsage;
+ (BOOL)shareWithFacebookOnFavorite;
+ (BOOL)shareWithTwitterOnFavorite;
+ (BOOL)askedAboutSharing;
+ (BOOL)multipleStoresEnabled;
+ (NSString *)lastStore;
+ (NSString *)preferredStore;
+ (NSArray *)stores;
+ (NSString *)pushID;
+ (NSString *)generatedUDID;

// Setters
+ (void)shareWithFacebookOnFavorite:(BOOL)imSocial;
+ (void)shareWithTwitterOnFavorite:(BOOL)imSocial;
+ (void)askedAboutSharing:(BOOL)imSocial;
+ (void)setMultipleStoresEnabled:(BOOL)weBallin;
+ (void)setPushID:(NSString *)pushID;
+ (void)setGeneratedUDID:(NSString *)generatedUDID;
+ (void)setLastStore:(NSString *)lastStore;
+ (void)setPreferredStore:(NSString *)preferredStore;
+ (void)setDefaultPreferredStore;
+ (void)batchUpdate:(NSArray *)updateValues;

@end
