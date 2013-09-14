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

@interface DMAboutViewController () <MFMailComposeViewControllerDelegate, UIActionSheetDelegate>

- (NSString *)supportEmailSubject;
- (NSString *)suggestionEmailSubject;

- (NSString *)supportEmailBody;
- (NSString *)suggestionEmailBody;

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
//    BITFeedbackListViewController *feedbackListViewController = [[BITFeedbackListViewController alloc] init];
//    [self.navigationController pushViewController:feedbackListViewController animated:YES];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:Nil
                                                    otherButtonTitles:@"Support", @"Suggestion", nil];
    [actionSheet showInView:self.view];
    
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

#pragma mark UIAlertView Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"action sheet selected -- %@", [actionSheet buttonTitleAtIndex:buttonIndex]);
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        // do shit
        NSString *message;
        NSArray *recipients;
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Support"]) {
            message = self.supportEmailBody;
            recipients = [NSArray arrayWithObject:@"appsupport@growlmovement.com"];
        } else {
            message = self.suggestionEmailBody;
            recipients = [NSArray arrayWithObject:@"fill@growlmovement.com"];
        }
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
            [mailer setMailComposeDelegate:self];
            [mailer setToRecipients:recipients];
            [mailer setSubject:[actionSheet buttonTitleAtIndex:buttonIndex]];
            [mailer setMessageBody:message isHTML:YES];
            [self presentViewController:mailer animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Looks like you can't send an email this way." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }
}

#pragma mark Email Body/Subjet
- (NSString *)supportEmailSubject
{
    
    return @"Support";
}

- (NSString *)suggestionEmailSubject
{
    return @"Suggestion";
}

- (NSString *)supportEmailBody
{
    NSString *deviceModel = [[UIDevice currentDevice] model];
    NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
    NSString *appBuild = [[NSUserDefaults standardUserDefaults] stringForKey:@"build_preferences"];
    NSString *appVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"version_preferences"];
    return [NSString stringWithFormat:@"<strong>Please Describe what happened:</strong><br/><br/><br/><br/><strong>What was going on when it happened? Please be as detailed as you can:</strong><br/><br/><br/><br/>Below this line is just diagnostic stuff for me. Please leave there, it helps me a lot.<br/>Thanks!<br/><hr><br/><br/>Device: <em>%@</em><br/>iOS Version: <em>%@</em> <br/>Version: <em>%@</em><br/>Build: <em>%@</em>", deviceModel, iOSVersion, appVersion, appBuild];
}

- (NSString *)suggestionEmailBody
{
    return @"Any new beers you'd love to see us have?<br/>How can we make the app better?<br/>Just want to say hi?<br/>Anything you want to tell us, please do!<br/><br/><br/>";
}

@end
