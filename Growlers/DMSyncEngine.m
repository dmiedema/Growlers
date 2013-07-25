//
//  DMSyncEngine.m
//  Growlers
//
//  Created by Daniel Miedema on 7/23/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMSyncEngine.h"

@interface DMSyncEngine ()
@property (nonatomic, strong) NSMutableArray *registeredClassesToSync;
@end

@implementation DMSyncEngine

+ (DMSyncEngine *)sharedInstance {
    static DMSyncEngine *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[DMSyncEngine alloc] init];
    });
    return sharedClient;
}

- (void)registerNSManagedObjectClassToSync:(Class)aClass {
    if (!_registeredClassesToSync) {
        _registeredClassesToSync = [NSMutableArray array];
    }
    
    if ([aClass isSubclassOfClass:[NSManagedObject class]]) {
        if (![_registeredClassesToSync containsObject:NSStringFromClass(aClass)]) {
            [_registeredClassesToSync addObject:NSStringFromClass(aClass)];
        } else {
            NSLog(@"Unable to register %@. It is already registered", NSStringFromClass(aClass));
        }
    } else {
        NSLog(@"Unable to register %@, it is not a subclass of NSManagedObject", NSStringFromClass(aClass));
    }
}

@end
