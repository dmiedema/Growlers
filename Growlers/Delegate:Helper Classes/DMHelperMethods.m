//
//  DMHelperMethods.m
//  Growlers
//
//  Created by Daniel Miedema on 9/23/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMHelperMethods.h"

@interface DMHelperMethods()

@end

id ObjectOrNull(id obj) {
    if (obj == [NSNull null] || !obj) {
        return nil;
    }
    return obj;
}


@implementation DMHelperMethods

+ (BOOL)checkIfOpen
{
    // Get today
    NSDate *today = [NSDate date];
    // Get users calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // Get date compontents
    NSDateComponents *weekdayComponents = [calendar components:(NSWeekdayCalendarUnit | NSHourCalendarUnit) fromDate:today];
    // Get the values out.
    NSInteger hour = [weekdayComponents hour];
    NSInteger weekday = [weekdayComponents weekday];
    
    NSDictionary *allStoreHours = [DMDefaultsInterfaceConstants storeHours];
    NSDictionary *lastStoresHours = [allStoreHours objectForKey:[DMDefaultsInterfaceConstants lastStore]];
    NSDictionary *currentDaysHours = [lastStoresHours objectForKey:[NSString stringWithFormat:@"%li", (long)weekday]];
    
    return hour >= [[currentDaysHours valueForKey:@"open"] integerValue] && hour < [[currentDaysHours valueForKey:@"close"] integerValue];

}

+ (BOOL)checkLastDateOfMonth
{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *todaysDate = [calendar components:(NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    
    int month = (int)todaysDate.month;
    int day   = (int)todaysDate.day;
    
    switch (month) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            return day == 31;
            break;
        case 2:
            return day == 28;
            break;
        case 4:
        case 6:
        case 9:
        case 11:
            return day == 30;
            break;
        default:
            return NO;
            break;
    }
    return NO;
}

+ (BOOL)checkToday:(id)tapID
{
    return [tapID integerValue] == [DMHelperMethods getToday];
}

+ (NSInteger)getToday
{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *todaysDate = [calendar components:(NSDayCalendarUnit) fromDate:today];
    
    return todaysDate.day;
}

// Centralize color-getting.
+ (UIColor *)growlersYellowColor:(GrowlersYellowAlpha)alpha
{
    if (alpha == AlphaNewBeer) {
        return [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:0.125];
    } else {
        return [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:0.85];
    }
}

+ (UIColor *)systemBlueColor
{
    return [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
}

+ (void)animateOpacityForLayer:(CALayer *)layer to:(NSNumber *)to from:(NSNumber *)from duration:(NSNumber *)duration
{
    /*
     [cell.favoriteMarker.layer setOpacity:0.0];
     cell.favoriteMarker.backgroundColor = [DMHelperMethods growlersYellowColor:AlphaBeerFavorites];
     
     CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
     basicAnimation.fromValue = [NSNumber numberWithFloat:0.0];
     basicAnimation.toValue = [NSNumber numberWithFloat:1.0];
     basicAnimation.duration = 0.25;
     
     [cell.favoriteMarker.layer addAnimation:basicAnimation forKey:@"opacity"];
     [cell.favoriteMarker.layer setOpacity:1.0];
     */
    // Make sure we're on the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        [layer setOpacity:from.floatValue];
        
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        basicAnimation.fromValue = from;
        basicAnimation.toValue = to;
        basicAnimation.duration = duration.doubleValue;
        
        [layer addAnimation:basicAnimation forKey:@"opacity"];
        
        [layer setOpacity:to.floatValue];
    });
}

+ (NSArray *)sanitzedBeerInformation:(NSArray *)array {
    NSMutableArray *sanitzed = [NSMutableArray array];
    
    for (NSDictionary *unsafe in array) {
        NSMutableDictionary *safe = [NSMutableDictionary dictionaryWithDictionary:unsafe];
        
        for (id value in [safe allKeys]) {
            if (!safe[value] || safe[value] == [NSNull null]) {
                safe[value] = @"";
            }
        }
        
        [sanitzed addObject:safe];
    }
    
    return sanitzed;
}
@end
