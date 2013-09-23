//
//  DMSettingsTableViewController.m
//  Growlers
//
//  Created by Daniel Miedema on 9/22/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMSettingsTableViewController.h"
#import "DMAboutViewController.h"
#import <MessageUI/MessageUI.h>
#import <MapKit/MapKit.h>

@interface DMSettingsTableViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic) BOOL multipleStores;
- (void)handeStore;
// About
- (void)handleAbout:(NSInteger)index;
// Social
- (void)handleSocial:(NSInteger)index;
// Feedback Email
- (void)handleSupport:(NSInteger)index;
- (NSString *)suggestionEmailSubject;
- (NSString *)suggestionEmailBody;
- (NSString *)supportEmailSubject;
- (NSString *)supportEmailBody;

//**
@end

@implementation DMSettingsTableViewController

#pragma mark View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    self.navigationController.navigationBar.topItem.title = @"Settings";
    
    self.facebookSharing.on = [DMDefaultsInterfaceConstants shareWithFacebookOnFavorite];
    self.twitterSharing.on  = [DMDefaultsInterfaceConstants shareWithTwitterOnFavorite];
    
    self.preferredStore.text = [DMDefaultsInterfaceConstants preferredStore];
    
    self.multipleStores = [DMDefaultsInterfaceConstants multipleStoresEnabled];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"Settings";
}

#pragma mark TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //** Sections
    // 0 - About
    // 1 - Social
    // 2 - Notifications
    // 3 - Feedback
    switch (indexPath.section) {
        case 0: // About
            [self handleAbout:indexPath.row];
            break;
        case 1: // Social
            [self handleSocial:indexPath.row];
            break;
        case 2: // Notifications
            [self handeStore];
            break;
        case 3: // Feedback
            [self handleSupport:indexPath.row];
            break;
        default:
            // derp
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.multipleStores && indexPath.section == 2) {
        return 0.0f;
    }
    return 44.0f;
}

#pragma mark Implementation
- (void)handleAbout:(NSInteger)index
{
    switch (index) {
        case 0: // about
            [self showAbout];
            break;
        case 1: // hours
            [self showHours];
            break;
        case 2: // take me
            [self takeMe];
            break;
        case 3: // tutorial
            [self showTutorial];
            break;
        default:
            break;
    }
}

- (void)handleSocial:(NSInteger)index
{
    switch (index) {
        case 0:
            [DMDefaultsInterfaceConstants shareWithFacebookOnFavorite:!self.facebookSharing.on];
            [self.facebookSharing setOn:!self.facebookSharing.on animated:YES];
            break;
        case 1:
            [DMDefaultsInterfaceConstants shareWithTwitterOnFavorite:!self.twitterSharing.on];
            [self.twitterSharing setOn:!self.twitterSharing.on animated:YES];
            break;
        default:
            break;
    }
}

- (void)handeStore
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    [actionSheet addButtonWithTitle:@"All Stores"];
    for (NSString *store in [DMDefaultsInterfaceConstants stores]) {
        [actionSheet addButtonWithTitle:store];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    [actionSheet showInView:self.view];
}

- (void)handleSupport:(NSInteger)index
{
    NSString *subject;
    NSString *message;
    NSArray *recipients;
    switch (index) {
        case 0:    // 0 suggestion
            subject = self.supportEmailSubject;
            message = self.suggestionEmailBody;
            recipients = [NSArray arrayWithObject:@"fill@growlmovement.com"];
            break;
        case 1:    // 1 support
            subject = self.suggestionEmailSubject;
            message = self.supportEmailBody;
            recipients = [NSArray arrayWithObject:@"appsupport@growlmovement.com"];
            break;
        default:
            message = @"";
            recipients = [NSArray arrayWithObject:@"appsupport@growlmovement.com"];
            break;
    }
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        [mailer setMailComposeDelegate:self];
        [mailer setToRecipients:recipients];
        [mailer setSubject:subject];
        [mailer setMessageBody:message isHTML:YES];
        [self presentViewController:mailer animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops" message:@"Looks like you can't send an email this way." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
}

- (void)showAbout
{
    DMAboutViewController *aboutView = [self.storyboard instantiateViewControllerWithIdentifier:@"DMAboutViewController"];
    [self.navigationController pushViewController:aboutView animated:YES];
}

- (void)showHours
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hours"
                                                        message:@"Sunday - Thurdsay: 12PM - 8PM\nFriday & Saturday: 11AM - 11PM"
                                                       delegate:nil
                                              cancelButtonTitle:@"Cool"
                                              otherButtonTitles: nil];
    [alertView show];
}

- (void)takeMe
{
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
- (void)showTutorial
{
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

#pragma mark ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *store;
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    if (buttonIndex == 0)
        store = @"All";
    else
        store = [actionSheet buttonTitleAtIndex:buttonIndex];
    [DMDefaultsInterfaceConstants setPreferredStore:store];
    self.preferredStore.text = store;
}


#pragma mark MailComposer Delegate
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

#pragma mark Email Body/Subjet
- (NSString *)supportEmailSubject
{
    
    return @"[Growlers] Support";
}

- (NSString *)suggestionEmailSubject
{
    return @"[Growlers] Suggestion";
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
    return @"Any new beers you'd love to see us have?<br/><br/>How can we make the app better?<br/><br/>Just want to say hi?<br/><br/>Anything you want to tell us, please do!<br/><br/><br/>";
}
@end
