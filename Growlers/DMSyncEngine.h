//
//  DMSyncEngine.h
//  Growlers
//
//  Created by Daniel Miedema on 7/23/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMSyncEngine : NSObject
- (void)registerNSManagedObjectClassToSync:(Class)aClass;
@end
