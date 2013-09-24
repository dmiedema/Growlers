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
static NSString *multipleStoresKey =@"Growlers_Multiple_Stores";
// Anonymouse
static NSString *anonymousUsage = @"anonymous_usage";

#pragma mark Getters
// Anonymouse Usage
+ (BOOL)anonymousUsage
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:anonymousUsage];
}
// Social stuff
+ (BOOL)shareWithFacebookOnFavorite
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:shareWithFacebook];
}
+ (BOOL)shareWithTwitterOnFavorite
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:shareWithTwitter];
}
+ (BOOL)askedAboutSharing
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:askedAboutSharing];
}
+ (NSString *)facebookOAuthKey
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:facebookOAuthDefaultsKey];
}
+ (NSString *)twitterOAuthKey
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:twitterOAuthDefaultsKey];
}
// Store
+ (BOOL)multipleStoresEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:multipleStoresKey];
}
+ (NSString *)lastStore
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:lastSelectedStore];
}
+ (NSString *)preferredStore
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:preferredStore];
}
+ (NSArray *)stores
{
    NSArray *stores = [NSArray arrayWithObjects:@"Keizer", nil];
    return stores;
}
// Push/UDID
+ (NSString *)pushID
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:pushID];
}
+ (NSString *)generatedUDID
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:generatedUDID];
}

#pragma mark Setters
// Anonymouse Usage
// Social stuff
+ (void)shareWithFacebookOnFavorite:(BOOL)imSocial
{
    [[NSUserDefaults standardUserDefaults] setBool:imSocial forKey:shareWithFacebook];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)shareWithTwitterOnFavorite:(BOOL)imSocial
{
    [[NSUserDefaults standardUserDefaults] setBool:imSocial forKey:shareWithTwitter];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)askedAboutSharing:(BOOL)imSocial
{
    [[NSUserDefaults standardUserDefaults] setBool:imSocial forKey:askedAboutSharing];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)setFacebookOAuthKey:(NSString *)facebookKey
{
    [[NSUserDefaults standardUserDefaults] setValue:facebookKey forKey:facebookOAuthDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)setTwitterOAuthKey:(NSString *)twitterKey
{
    [[NSUserDefaults standardUserDefaults] setValue:twitterKey forKey:twitterOAuthDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
// Store
+ (void)setMultipleStoresEnabled:(BOOL)weBallin
{
    [[NSUserDefaults standardUserDefaults] setBool:weBallin forKey:multipleStoresKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)setLastStore:(NSString *)lastStore
{
    [[NSUserDefaults standardUserDefaults] setValue:lastStore forKey:lastSelectedStore];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)setPreferredStore:(NSString *)preferred
{
    [[NSUserDefaults standardUserDefaults] setValue:preferred forKey:preferredStore];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)setDefaultPreferredStore
{
    [DMDefaultsInterfaceConstants setPreferredStore:@"All"];
}
// Push/UDID
+ (void)setPushID:(NSString *)push
{
    [[NSUserDefaults standardUserDefaults] setValue:push forKey:pushID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)setGeneratedUDID:(NSString *)generated
{
    [[NSUserDefaults standardUserDefaults] setValue:generated forKey:generatedUDID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Batch
+ (void)batchUpdate:(NSArray *)updateValues
{
    for (NSDictionary *dict in updateValues) {
        [[NSUserDefaults standardUserDefaults] setValue:dict.allValues.lastObject forKey:dict.allKeys.lastObject];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
