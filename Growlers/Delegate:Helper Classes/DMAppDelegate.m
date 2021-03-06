//
//  DMAppDelegate.m
//  Growlers
//
//  Created by Daniel Miedema on 7/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMAppDelegate.h"
#import "DMTableViewController.h"
// Remote config
#import "NSUserDefaults+GroundControl.h"
#import "AFNetworkActivityIndicatorManager.h"
// analytics
#import "TSTapstream.h"
#import <NewRelicAgent/NewRelic.h>
#import <Crashlytics/Crashlytics.h>
// #import "GAI.h"
// CoreDataMethods for URL handling
#import "DMCoreDataMethods.h"
#import "DMGrowlerNetworkModel.h"

#import "DMAPIKeys.h"

#if TAKE_SCREENSHOTS == 1
#import <SDScreenshotCapture/SDScreenshotCapture.h>
#import <SparkInspector/SparkInspector.h>
#endif


@interface DMAppDelegate ()
@property (nonatomic, strong) NSString *generatedUDID;

- (void)setupTracking;

@end

@implementation DMAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark Implementation

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _generatedUDID = [NSString string];
    _generatedUDID = [DMDefaultsInterfaceConstants generatedUDID];
    if (!_generatedUDID) {
        _generatedUDID = [[NSUUID UUID] UUIDString];
        [DMDefaultsInterfaceConstants setGeneratedUDID:_generatedUDID];
    }
    
    /* If we're sending anonymous usage reports */
    if ([DMDefaultsInterfaceConstants anonymousUsage]) {
        [self setupTracking];
    }
    
    if(![DMDefaultsInterfaceConstants preferredStore])
        [DMDefaultsInterfaceConstants setDefaultPreferredStore];
    
    /* Hockey Testing */
    NSString *hockeyIdentifier = nil;
#if DEBUG
     hockeyIdentifier = @"c4e28d986734b9f0c8b5716244112805";
#else
    hockeyIdentifier = kGrowlers_HockeyApp_Production_API_Key;
#endif
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:hockeyIdentifier delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    /* Crashlytics */
    [Crashlytics startWithAPIKey:kGrowlers_Crashlytics_API_Key];
    
    /* Push Notifications */
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    
    /* Background stuff */
//    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    /* StatusMagic screen shot stuff */
#if TAKE_SCREENSHOTS == 1
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    tapGesture.numberOfTouchesRequired = 4;
    [self.window addGestureRecognizer:tapGesture];
#endif
    
    /* Settings App Bundle */
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [[NSUserDefaults standardUserDefaults] setObject:build forKey:@"build_preferences"];
    
    NSString *verison = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setObject:verison forKey:@"version_preferences"];
    
    NSString *madeBy = @"";
    [[NSUserDefaults standardUserDefaults] setObject:madeBy forKey:@"made_by"];
    
    /* AFNetworking indicator */
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    /* Multiple Stores */
    [DMDefaultsInterfaceConstants setMultipleStoresEnabled:YES];
    
    /* Launch */
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    DMTableViewController *controller = (DMTableViewController *)navigationController.topViewController;
    controller.managedContext = self.managedObjectContext;
    controller.searchDisplayController.searchBar.showsScopeBar = NO;
    
    return YES;
}

#if TAKE_SCREENSHOTS == 1
- (void)tapGestureRecognized:(UITapGestureRecognizer *)tapGesture
{
    [SDScreenshotCapture takeScreenshotToActivityViewController];
}
#endif

#pragma mark - BITUpdateManagerDelegate
- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
    return _generatedUDID;
}

#pragma mark Statistics
- (void)setupTracking
{
    /* NewRelic */
#if DEBUG
//    [NRLogger setLogLevels:NRLogLevelALL];
    [NewRelicAgent startWithApplicationToken:@"AAbd1c55627f8053291cf5ed818186d742c337ac42"];
#else
    [NRLogger setLogLevels:NRLogLevelWarning];
    [NewRelicAgent startWithApplicationToken:kGrowlers_NewRelic_Production_API_Key];
#endif
    
    
    /* Auto submit crash reports to hockey */
    [BITHockeyManager sharedHockeyManager].crashManager.crashManagerStatus = BITCrashManagerStatusAutoSend;
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    /* Tapstream */
    TSConfig *config = [TSConfig configWithDefaults];
    config.collectWifiMac = NO;
    config.idfa = _generatedUDID;
    [TSTapstream createWithAccountName:@"dmiedema" developerSecret:@"fjOF0VDGQ8iLcfFqnTyhlw" config:config];
    
    /* Google Anayltics */
//    [GAI sharedInstance].dispatchInterval = 20;
//    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
//    [[GAI sharedInstance] trackerWithTrackingId:@"UA-43859185-1"];

}

#pragma mark - Push Notifications
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token = [deviceToken.description stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [DMDefaultsInterfaceConstants setPushID:token];
//	NSLog(@"My token is: %@", token);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
//	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    NSLog(@"Remote Notification Received");
//    NSLog(@"User Info - %@", userInfo);
    if ([userInfo[@"aps"][@"alert"] isEqualToString:@"Test Notification"]) {
//        NSLog(@"Alert was equal to 'Test Notification'");
        if (application.applicationState == UIApplicationStateActive ) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Push Test"
                                                                message:@"Was successful!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Awesome!"
                                                      otherButtonTitles: nil];
            [alertView show];
        }
        else {
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertBody = @"GM Taplist Push Notifications are working!";
            localNotification.applicationIconBadgeNumber = [userInfo[@"badge"] integerValue];
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    } // not a test notification
}

#pragma mark - Handling URL Request
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // Make sure we have a valid URL scheme
    if ([url.scheme isEqualToString:@"gmtaplist"]) {
        NSArray *queryParameters = [url.query componentsSeparatedByString:@"&"];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:queryParameters.count];
        for (NSString *param in queryParameters) {
            NSArray *args = [param componentsSeparatedByString:@"="];
            [parameters setValue:[args[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:args[0]];
        }
//        NSLog(@"parameters %@", parameters);
//        NSLog(@"Parameters keys %@", parameters.allKeys);
//        NSLog(@"contains name - %d", [parameters.allKeys containsObject:@"name"]);
//        NSLog(@"contains brewer - %d", [parameters.allKeys containsObject:@"brewer"]);        
        // make sure beer & brewer are set
        if([parameters.allKeys containsObject:@"name"] && [parameters.allKeys containsObject:@"brewer"]) {
            DMCoreDataMethods *coreData = [[DMCoreDataMethods alloc] initWithManagedObjectContext:self.managedObjectContext];
            if (parameters[@"store"] == [NSNull null]) {
                [parameters setValue:[DMDefaultsInterfaceConstants preferredStore] forKey:@"store"];
//                NSLog(@"Store param set");
            }
            if (parameters[@"ibu"] == [NSNull null]) {
                [parameters setValue:@"-" forKey:@"ibu"];
//                NSLog(@"ibu param set");
            }
            if (parameters[@"abv"] == [NSNull null]) {
                [parameters setValue:@"-" forKey:@"abv"];
//                NSLog(@"abv param set");
            }
            [parameters setValue:@(YES) forKey:@"fav"];
            
//            NSLog(@"%@", parameters);
            if(![coreData isBeerFavorited:parameters]) {
                [[DMGrowlerNetworkModel manager] favoriteBeer:parameters
                                                withSuccess:^(id JSON) {
//                                                    NSLog(@"favorited! %@", parameters);
                                                    [coreData favoriteBeer:parameters];
                }
                                                 andFailure:nil
                 ];
            }
            return YES;
        }
        return YES;
    }
    // url.scheme isn't gmtaplist
    return NO;
}

#pragma mark Background Fetch

//- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    NSLog(@"Running background fetch");
//    
//    [[DMGrowlerAPI sharedInstance] getBeersWithFlag:ON_TAP forStore:[DMDefaultsInterfaceConstants lastStore] andSuccess:^(id JSON) {
//        NSLog(@"%@", JSON);
//    } andFailure:^(id JSON) {
//        NSLog(@"%@", JSON);
//    }];
//    
//
//}

#pragma mark Application Life cycle

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    // Tell server we want to reset badge count.
    [[DMGrowlerNetworkModel manager] resetBadgeCount];
    [self initializeGroundControl];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if (![DMDefaultsInterfaceConstants preferredStoresSynced]) {
        [[DMGrowlerNetworkModel manager] setPreferredStores:[DMDefaultsInterfaceConstants preferredStores] forUser:[DMDefaultsInterfaceConstants getValidUniqueID] withSuccess:^(id JSON) {
            [DMDefaultsInterfaceConstants setPreferredStoresSynced:YES];
        } andFailure:^(id JSON) {
            [DMDefaultsInterfaceConstants setPreferredStoresSynced:NO];
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}

#pragma mark GroundControl
- (void)initializeGroundControl
{
#if DEBUG
    NSURL *url = [NSURL URLWithString:@"http://www.growlmovement.com/_app/GrowlersStoreList-dev.php"];
#else
    NSURL *url = [NSURL URLWithString:@"http://www.growlmovement.com/_app/GrowlersStoreList.php"];
#endif
    [[NSUserDefaults standardUserDefaults] registerDefaultsWithURL:url];
}

#pragma mark CoreData
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoa! Something went wrong"
                                                                message:@"Don't worry it's not your fault! I messed up and I'm sorry. But if you could email\nappsupport@growlmovement.com\nand reference\nError Code: cats-meow\nThat'd be great! Thanks! I'm going to close now :("
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles: nil];
            [alertView show];
            abort();
        }
    }
}

#pragma mark - CoreData stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GrowlerModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GrowlerModel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // Migration
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    // Setup persistent store with options for migrating.
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoa! Something went wrong"
                                                            message:@"Don't worry it's not your fault! I messed up and I'm sorry. But if you could email\nappsupport@growlmovement.com\nand reference\nError Code: dog-bark\nThat'd be great! Thanks! I'm going to close now :("
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles: nil];
        [alertView show];
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
