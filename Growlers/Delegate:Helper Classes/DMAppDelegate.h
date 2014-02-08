//
//  DMAppDelegate.h
//  Growlers
//
//  Created by Daniel Miedema on 7/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>

//@interface DMAppDelegate : UIResponder <UIApplicationDelegate, BITHockeyManagerDelegate, BITCrashManagerDelegate, BITFeedbackComposeViewControllerDelegate>
@interface DMAppDelegate : UIResponder <UIApplicationDelegate, BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITFeedbackComposeViewControllerDelegate>
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
