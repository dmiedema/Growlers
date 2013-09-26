//
//  DMDefaultsInterfaceConstants.h
//  Growlers
//
//  Created by Daniel Miedema on 9/20/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMDefaultsInterfaceConstants : NSObject
//** Getters
// Social
+ (BOOL)shareWithFacebookOnFavorite;
+ (BOOL)shareWithTwitterOnFavorite;
+ (BOOL)askedAboutSharing;
+ (NSString *)facebookOAuthKey;
+ (NSString *)twitterOAuthKey;
// UDID
+ (NSString *)generatedUDID;
+ (NSString *)pushID;
// Store
+ (BOOL)multipleStoresEnabled;
+ (NSString *)lastStore;
+ (NSString *)preferredStore;
+ (NSArray *)preferredStores;
+ (NSArray *)stores;
+ (BOOL)preferredStoresSynced;
+ (NSDictionary *)storeMapLocations;
// Anonymouse
+ (BOOL)anonymousUsage;
// Other


//** Setters
// Social
+ (void)shareWithFacebookOnFavorite:(BOOL)imSocial;
+ (void)shareWithTwitterOnFavorite:(BOOL)imSocial;
+ (void)askedAboutSharing:(BOOL)imSocial;
+ (void)setFacebookOAuthKey:(NSString *)facebookKey;
+ (void)setTwitterOAuthKey:(NSString *)twitterKey;
// UDID
+ (void)setPushID:(NSString *)pushID;
+ (void)setGeneratedUDID:(NSString *)generatedUDID;
// Store
+ (void)setDefaultPreferredStore;
+ (void)setLastStore:(NSString *)lastStore;
+ (void)setMultipleStoresEnabled:(BOOL)weBallin;
+ (void)setPreferredStore:(NSString *)preferredStore;
+ (void)setPreferredStores:(NSArray *)preferredStores;
+ (void)addPreferredStore:(NSString *)store;
+ (void)removePreferredStore:(NSString *)store;
+ (void)setPreferredStoresSynced:(BOOL)synced;
// Anonymouse
// Other
+ (void)batchUpdate:(NSArray *)updateValues;

@end