//
//  DMStoreHoursActionSheetDelegate.m
//  Growlers
//
//  Created by Daniel Miedema on 12/28/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMStoreHoursActionSheetDelegate.h"

@interface DMStoreHoursActionSheetDelegate()
@property (nonatomic, strong) NSDictionary *numberToDayMap;
@end

@implementation DMStoreHoursActionSheetDelegate

- (id)init
{
    self = [super init];
    if (self) {
        self.numberToDayMap = @{
                             @"1" : @"Sunday",
                             @"2" : @"Monday",
                             @"3" : @"Tuesday",
                             @"4" : @"Wednesday",
                             @"5" : @"Thursday",
                             @"6" : @"Friday",
                             @"7" : @"Saturday"
                             };
    }
    return self;
}

- (NSString *)formatOperatingHoursAsString:(NSDictionary *)hours withKey:(NSString *)key
{
    NSInteger open = [hours[@"open"] integerValue] + 1;
    NSInteger close = [hours[@"close"] integerValue];
    
    return [NSString stringWithFormat:@"%@: %ld%@ - %ld%@", [self.numberToDayMap objectForKey:key], (long)open, [self getAMorPMModfierForTime:open], ((long)close % 12), [self getAMorPMModfierForTime:close]];
}

- (NSString *)getAMorPMModfierForTime:(NSInteger)time
{
    return (time < 12 && time > 0) ? @"am" : @"pm";
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSDictionary *hours = [[DMDefaultsInterfaceConstants storeHours] objectForKey:[actionSheet buttonTitleAtIndex:buttonIndex]];
        NSMutableArray *hoursAsStrings = [NSMutableArray new];
        NSArray *allKeys = [[hours allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

        for (NSString *key in allKeys) {
            NSDictionary *daysHours = [hours objectForKey:key];
            [hoursAsStrings addObject:[self formatOperatingHoursAsString:daysHours withKey:key]];
        }
        
        NSString *title = [NSString stringWithFormat:@"Hours for %@", [actionSheet buttonTitleAtIndex:buttonIndex]];
        NSMutableString *message = [NSMutableString new];
        
        for (NSString *str in hoursAsStrings) {
            [message appendString:[NSString stringWithFormat:@"%@\n", str]];
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"Cool"
                                                  otherButtonTitles: nil];
        [alertView show];
    }
    return;
}
@end
