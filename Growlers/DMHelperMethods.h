//
//  DMHelperMethods.h
//  Growlers
//
//  Created by Daniel Miedema on 9/23/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMHelperMethods : NSObject
+ (BOOL)checkIfOpen;
+ (BOOL)checkLastDateOfMonth;
+ (BOOL)checkToday:(id)tapID;
+ (NSInteger)getToday;
@end
