//
//  DMTakeMeActionSheetDelegate.m
//  Growlers
//
//  Created by Daniel Miedema on 9/26/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMTakeMeActionSheetDelegate.h"
#import <MapKit/MapKit.h>

@implementation DMTakeMeActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSDictionary *storeLocations = [DMDefaultsInterfaceConstants storeMapLocations];
        NSString *store = [actionSheet buttonTitleAtIndex:buttonIndex];
        NSDictionary *chosenStore = [storeLocations objectForKey:store];
        
        Class mapItemClass = [MKMapItem class];
        if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
        {
            // Create an MKMapItem to pass to the Maps app
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([chosenStore[@"latitude"] doubleValue], [chosenStore[@"longitude"] doubleValue]);
//            CLLocationCoordinate2D coordinate =
//            CLLocationCoordinate2DMake(44.9995136, -123.026656);
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                           addressDictionary:nil];
            MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            [mapItem setName:@"Growl Movement"];
            
            // Set the directions mode to "Walking"
            // Can use MKLaunchOptionsDirectionsModeDriving instead
            NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
            // Get the "Current User Location" MKMapItem
            MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
            // Pass the current location and destination map items to the Maps app
            // Set the direction mode in the launchOptions dictionary
            [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                           launchOptions:launchOptions];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Whoa! Something went wrong"
                                                                message:@"Looks like I wasn't able to open maps for you. I'm sorry!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles: nil];
            [alertView show];
        }
    }
    return;
}
@end
