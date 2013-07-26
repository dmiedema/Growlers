//
//  DMAppDelegate.m
//  Growlers
//
//  Created by Daniel Miedema on 7/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMAppDelegate.h"
#import <TestFlightSDK/TestFlight.h>

@implementation DMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //
    #if TESTING
        //[SparkInspector enableObservation];

    // Testflight
    NSString *id;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id = [defaults objectForKey:@"Growler-UUID"];
    if (id == nil) {
        id = [[NSUUID UUID] UUIDString];
        [defaults setObject:id forKey:@"Growler-UUID"];
        [defaults synchronize];
    }
    [TestFlight setDeviceIdentifier:id];
    [TestFlight takeOff:@"c7dba094-f82f-48fc-ab26-525c33b91dae"];

    // Hockeyapp
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"d48bfa2df88def26d6eb9cf3e0603d66"
                                                           delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    #endif
    
    return YES;
}

/*
- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
#ifndef CONFIGURATION_AppStore
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
        return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
    return nil;
}*/
							
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
}

@end
