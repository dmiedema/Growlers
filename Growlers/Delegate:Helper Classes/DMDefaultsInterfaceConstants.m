//
//  DMDefaultsInterfaceConstants.m
//  Growlers
//
//  Created by Daniel Miedema on 9/20/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMDefaultsInterfaceConstants.h"

@interface DMDefaultsInterfaceConstants()

@end



@implementation DMDefaultsInterfaceConstants
#pragma mark Static NSStrings for UserDefaults Keys
// Social
static NSString *shareWithFacebook = @"Growlers_Share_With_Facebook";
static NSString *shareWithTwitter = @"Growlers_Share_With_Twitter";
static NSString *askedAboutSharing = @"Growlers_Asked_About_Sharing";
static NSString *facebookOAuthDefaultsKey = @"Growlers-Facebook-OAuth-Key";
static NSString *twitterOAuthDefaultsKey = @"Growlers-Twitter-OAuth-Key";
// UDID
static NSString *generatedUDID = @"Growler-UUID";
static NSString *pushID = @"Growlers-Push-ID";
// Store
static NSString *lastSelectedStore = @"Growlers-Last-Selected-Location";
static NSString *preferredStore = @"Growlers_Preferred_Store";
static NSString *preferredStores = @"Growlers_Preferred_Stores";
static NSString *multipleStoresKey = @"Growlers_Multiple_Stores";
static NSString *availableStores = @"Growlers_Available_Stores";
static NSString *syncedStores = @"Growlers_Preferred_Stores_Synced";
static NSString *spamMeKey = @"Growlers_Subscribe_To_Mass_Messages";
static NSString *mapsOfStores = @"Growlers_Dictionary_Of_Store_Locations";
static NSString *storeHours = @"Growlers_Dictionary_Of_Store_Hours";
static NSString *showCurrentStore = @"Growlers_Show_Current_Store_As_Prompt";
// Anonymouse
static NSString *anonymousUsage = @"anonymous_usage";
static NSString *badgeCountResetKey = @"Grolwers_Badge_Count_Reset";
// Other
static NSString *favoritesEverReconciledKey = @"Grolwers_Favorites_Ever_Reconciled";

#define SI static inline

SI NSUserDefaults *defaults()
{
    return [NSUserDefaults standardUserDefaults];
}

SI void __defaults_save()
{
    [defaults() synchronize];
}

#undef SI

#pragma mark Getters
// Anonymouse Usage
+ (BOOL)anonymousUsage
{
    return [defaults() boolForKey:anonymousUsage];
}
+ (BOOL)badgeCountReset
{
    return [defaults() boolForKey:badgeCountResetKey];
}
// Social stuff
+ (BOOL)shareWithFacebookOnFavorite
{
    return [defaults() boolForKey:shareWithFacebook];
}
+ (BOOL)shareWithTwitterOnFavorite
{
    return [defaults() boolForKey:shareWithTwitter];
}
+ (BOOL)askedAboutSharing
{
    return [defaults() boolForKey:askedAboutSharing];
}
+ (NSString *)facebookOAuthKey
{
    return [defaults() stringForKey:facebookOAuthDefaultsKey];
}
+ (NSString *)twitterOAuthKey
{
    return [defaults() stringForKey:twitterOAuthDefaultsKey];
}
// Store
+ (BOOL)multipleStoresEnabled
{
    return [defaults() boolForKey:multipleStoresKey];
}
+ (NSString *)lastStore
{
    NSString *lastStore = [defaults() stringForKey:lastSelectedStore];
    if (lastStore)
        return lastStore;
    else
        return @"Keizer";
}
+ (NSString *)preferredStore
{
    return [defaults() stringForKey:preferredStore];
}
+ (NSArray *)preferredStores
{
    NSArray *preferred = [defaults() objectForKey:preferredStores];
    if (preferred)
        return preferred;
    else
        return [NSArray arrayWithObject:@"all"];
}
+ (NSArray *)stores
{
    NSArray *stores = [defaults() objectForKey:availableStores];
    if (stores)
        return stores;
    else
        return [NSArray arrayWithObject:@"Keizer"];
}
+ (BOOL)subscribedToSpam
{
    return [defaults() boolForKey:spamMeKey];
}
+ (NSDictionary *)storeMapLocations
{
    return [defaults() dictionaryForKey:mapsOfStores];
}
+ (NSDictionary *)storeHours
{
    return [defaults() dictionaryForKey:storeHours];
}
+ (BOOL)showCurrentStoreOnTapList
{
    if ([defaults() objectForKey:showCurrentStore] == nil) {
        return YES;
    } else {
        return [defaults() boolForKey:showCurrentStore];
    }
}
// Push/UDID
+ (NSString *)pushID
{
    return [defaults() stringForKey:pushID];
}
+ (NSString *)generatedUDID
{
    return [defaults() stringForKey:generatedUDID];
}
+ (BOOL)preferredStoresSynced
{
    return [defaults() boolForKey:syncedStores];
}
+ (NSString *)getValidUniqueID
{
    return [DMDefaultsInterfaceConstants pushID]
    ? [DMDefaultsInterfaceConstants pushID]
    : [DMDefaultsInterfaceConstants generatedUDID];
}

// Other
+ (BOOL)favoritesEverReconciled {
    return ([defaults() objectForKey:favoritesEverReconciledKey] == nil) ? NO : [defaults() boolForKey:favoritesEverReconciledKey];
}


#pragma mark Setters

// Social stuff
+ (void)shareWithFacebookOnFavorite:(BOOL)imSocial
{
    [defaults() setBool:imSocial forKey:shareWithFacebook];
    __defaults_save();
}
+ (void)shareWithTwitterOnFavorite:(BOOL)imSocial
{
    [defaults() setBool:imSocial forKey:shareWithTwitter];
    __defaults_save();
}
+ (void)askedAboutSharing:(BOOL)imSocial
{
    [defaults() setBool:imSocial forKey:askedAboutSharing];
    __defaults_save();
}
+ (void)setFacebookOAuthKey:(NSString *)facebookKey
{
    [defaults() setValue:facebookKey forKey:facebookOAuthDefaultsKey];
    __defaults_save();
}
+ (void)setTwitterOAuthKey:(NSString *)twitterKey
{
    [defaults() setValue:twitterKey forKey:twitterOAuthDefaultsKey];
    __defaults_save();
}
// Store
+ (void)setMultipleStoresEnabled:(BOOL)weBallin
{
    [defaults() setBool:weBallin forKey:multipleStoresKey];
    __defaults_save();
}
+ (void)setLastStore:(NSString *)lastStore
{
    [defaults() setValue:lastStore forKey:lastSelectedStore];
    __defaults_save();
}
+ (void)setPreferredStore:(NSString *)preferred
{
    [defaults() setValue:preferred forKey:preferredStore];
    __defaults_save();
}
+ (void)setPreferredStores:(NSArray *)stores
{
    [defaults() setObject:stores forKey:preferredStores];
    __defaults_save();
}
+ (void)addPreferredStore:(NSString *)store
{
    NSMutableArray *array = [[DMDefaultsInterfaceConstants preferredStores] mutableCopy];
    [array addObject:store];
    [DMDefaultsInterfaceConstants setPreferredStores:array];
}
+ (void)removePreferredStore:(NSString *)store
{
    NSMutableArray *array = [[DMDefaultsInterfaceConstants preferredStores] mutableCopy];
    [array removeObject:store];
    [DMDefaultsInterfaceConstants setPreferredStores:array];
}
+ (void)setDefaultPreferredStore
{
    [DMDefaultsInterfaceConstants setPreferredStore:@"All"];
}
+ (void)setPreferredStoresSynced:(BOOL)synced
{
    [defaults() setBool:synced forKey:syncedStores];
    __defaults_save();
}
+ (void)setSubscribeToSpam:(BOOL)spamMe
{
    [defaults() setBool:spamMe forKey:spamMeKey];
    __defaults_save();
}
+ (void)setShowCurrentStoreOnTapList:(BOOL)showStore
{
    [defaults() setBool:showStore forKey:showCurrentStore];
    __defaults_save();
}
// Push/UDID
+ (void)setPushID:(NSString *)push
{
    [defaults() setValue:push forKey:pushID];
    __defaults_save();
}
+ (void)setGeneratedUDID:(NSString *)generated
{
    [defaults() setValue:generated forKey:generatedUDID];
    __defaults_save();
}
// Anonymouse
+ (void)setBadgeCountReset:(BOOL)resetPlease
{
    [defaults() setBool:resetPlease forKey:badgeCountResetKey];
    __defaults_save();
}
// Other
+ (void)setFavoritesEverReconciled:(BOOL)reconciled {
    [defaults() setBool:reconciled forKey:favoritesEverReconciledKey];
    __defaults_save();
}

#pragma mark Batch
+ (void)batchUpdate:(NSArray *)updateValues
{
    for (NSDictionary *dict in updateValues) {
        [defaults() setValue:dict.allValues.lastObject forKey:dict.allKeys.lastObject];
    }
    __defaults_save();
}
@end
