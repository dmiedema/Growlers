//
//  DMAppDelegate.m
//  Growlers
//
//  Created by Daniel Miedema on 7/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMAppDelegate.h"
#import "DMTableViewController.h"
//#import <TestFlightSDK/TestFlight.h>

@interface DMAppDelegate ()
@property (nonatomic, strong) NSString *generatedUDID;
@end

@implementation DMAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //
    _generatedUDID = [NSString string];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _generatedUDID = [defaults objectForKey:kGrowler_UUID];
    if (_generatedUDID == nil) {
        _generatedUDID = [[NSUUID UUID] UUIDString];
        [defaults setObject:_generatedUDID forKey:kGrowler_UUID];
        [defaults synchronize];
    }
    
    /* Testing */
    #if TESTING
    
    // Hockeyapp
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"d48bfa2df88def26d6eb9cf3e0603d66" delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    #endif
    
    /* Push Notifications */
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    
    /* Settings App Bundle */
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [[NSUserDefaults standardUserDefaults] setObject:build forKey:@"build_preferences"];
    
    NSString *verison = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setObject:verison forKey:@"version_preferences"];
    
    /* AFNetworking indicator */
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    
    /* Launch */
//    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
//    DMTableViewController *controller = (DMTableViewController *)navigationController.topViewController;
//    controller.managedContext = self.managedObjectContext;
//    controller.managedModel = self.managedObjectModel;
    
    return YES;
}

- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
#ifndef CONFIGURATION_AppStore
    NSLog(@"CONFIGURATION_AppStore");
    return _generatedUDID;
//    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)]) {
//        NSLog(@"%@", [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)]);
//        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
//    }
#endif
    return nil;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}

#pragma mark CoreData Methods
//- (NSURL *)applicationDocumentsDirectory {
//    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//}
//
//- (NSManagedObjectContext *)managedObjectContext {
//    if (_managedObjectContext) {
//        return _managedObjectContext;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (coordinator) {
//        _managedObjectContext = [[NSManagedObjectContext alloc] init];
//        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
//    }
//    
//    return _managedObjectContext;
//}
//
//- (NSManagedObjectModel *)managedObjectModel {
//    if (_managedObjectModel) {
//        return _managedObjectModel;
//    }
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FavoritesData" withExtension:@"momd"];
//    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    return  _managedObjectModel;
//}
//
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
//    if (_persistentStoreCoordinator) {
//        return _persistentStoreCoordinator;
//    }
//    
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FavoritesData.sqlite"];
//    NSError *error = nil;
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
//    
//    if ([_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
//        NSLog(@"Unresolved Error %@ %@", error, [error userInfo]);
//    }
//    
//    return _persistentStoreCoordinator;
//}
//
//-  (void)saveContext {
//    NSError *error = nil;
//    NSManagedObjectContext *context = self.managedObjectContext;
//    
//    if (context) {
//        if (context.hasChanges && ![context save:&error]) {
//            NSLog(@"Unresolved Error %@ %@", error, [error userInfo]);
//        }
//    }
//}

@end
