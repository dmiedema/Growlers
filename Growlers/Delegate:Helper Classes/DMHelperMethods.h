//
//  DMHelperMethods.h
//  Growlers
//
//  Created by Daniel Miedema on 9/23/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    AlphaNewBeer,
    AlphaBeerFavorites
} GrowlersYellowAlpha;

id ObjectOrNull(id obj);

@interface DMHelperMethods : NSObject
+ (BOOL)checkIfOpen;
+ (BOOL)checkLastDateOfMonth;
+ (BOOL)checkToday:(id)tapID;
+ (NSInteger)getToday;

+ (UIColor *)growlersYellowColor:(GrowlersYellowAlpha)alpha;
+ (UIColor *)systemBlueColor;
+ (void)animateOpacityForLayer:(CALayer *)layer to:(NSNumber *)to from:(NSNumber *)from duration:(NSNumber *)duration;

+ (NSArray *)sanitzedBeerInformation:(NSArray *)array;
@end
