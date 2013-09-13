//
//  DMAboutViewController.m
//  Growlers
//
//  Created by Daniel Miedema on 7/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMAboutViewController.h"
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>

@interface DMAboutViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation DMAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Removes the title from the back button when this view is pushed.
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Feedback" style:UIBarButtonItemStylePlain target:self action:@selector(contactSupport:)];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"About";
}

- (IBAction)checkUsOut:(UIButton *)sender {
    // Check for iOS 6
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        // Create an MKMapItem to pass to the Maps app
        CLLocationCoordinate2D coordinate =
        CLLocationCoordinate2DMake(44.9995136, -123.026656);
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

- (void)contactSupport:(UIButton *)sender {
    BITFeedbackListViewController *feedbackListViewController = [[BITFeedbackListViewController alloc] init];
    [self.navigationController pushViewController:feedbackListViewController animated:YES];
    
//    if ([MFMailComposeViewController canSendMail]) {
//        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
//        [mailer setMailComposeDelegate:self];
//        NSArray *recipients = [NSArray arrayWithObject:@"appsupport@growlmovement.com"];
//        [mailer setToRecipients:recipients];
//        [self presentViewController:mailer animated:YES completion:nil];
//    } else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Looks like you can't send an email this way." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
//    }
}

- (IBAction)showTutorial:(UIButton *)sender {
    UIViewController *viewController = [[UIViewController alloc] init];
    
    UIImageView *tutorialImage;
    
    if (IS_IPHONE_5) {
        tutorialImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Tutorial-4.png"]];
    } else {
        tutorialImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Tutorial-3_5.png"]];
    }

    viewController.view = tutorialImage;
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark MFMailComposeViewController Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved for later");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}
@end
