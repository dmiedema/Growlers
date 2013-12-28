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
+ (BOOL)subscribedToSpam;
+ (NSDictionary *)storeMapLocations;
+ (NSDictionary *)storeHours;
+ (BOOL)showCurrentStoreOnTapList;
// Anonymouse
+ (BOOL)anonymousUsage;
+ (BOOL)badgeCountReset;
// Other
+ (NSString *)getValidUniqueID;


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
+ (void)setSubscribeToSpam:(BOOL)spamMe;
+ (void)setShowCurrentStoreOnTapList:(BOOL)showStore;
// Anonymouse
+ (void)setBadgeCountReset:(BOOL)resetPlease;
// Other
+ (void)batchUpdate:(NSArray *)updateValues;

@end
