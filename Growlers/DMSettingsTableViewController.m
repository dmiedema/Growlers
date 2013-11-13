//
//  DMSettingsTableViewController.m
//  Growlers
//
//  Created by Daniel Miedema on 9/22/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMSettingsTableViewController.h"
#import "DMTakeMeActionSheetDelegate.h"
#import "DMAboutViewController.h"
#import "DMGrowlerAPI.h"
#import <MessageUI/MessageUI.h>
#import <MapKit/MapKit.h>

@interface DMSettingsTableViewController () <UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic) BOOL multipleStores;
@property (nonatomic, strong) NSArray *preferredStores;
@property (nonatomic, strong) NSArray *content;
@property (nonatomic, strong) NSString *selectedStoreName;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic) DMTakeMeActionSheetDelegate *takeMeActionSheetDelegate;

- (void)handeStore:(NSInteger)index;
- (void)showStoreNotificationChooser:(BOOL)showDestructiveOption;
// About
- (void)handleAbout:(NSInteger)index;
// Social
- (void)handleSocial:(NSInteger)index;
// Feedback Email
- (void)handleSupport:(NSInteger)index;
// Other
- (void)handleOther:(NSInteger)index;

- (NSString *)suggestionEmailSubject;
- (NSString *)suggestionEmailBody;
- (NSString *)supportEmailSubject;
- (NSString *)supportEmailBody;
//**

- (UIColor *)systemBlueColor;
@end

@implementation DMSettingsTableViewController

typedef enum {
    ABOUT = 0,
    NOTIFICATIONS = 1,
    SUPPORT = 2,
    OTHER = 3
} SETTINGS_TABLE_VIEW_SECTIONS;

#pragma mark View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    
    self.content = @[
          @[@"About Growl Movement", @"Operating Hours", @"Take me there!", @"What does everything mean?!"],
          @[@"Notification Preferrences"],
          @[@"Suggestion", @"Support"],
          @[@"Test Push Notifications", @"Fix Favorites Names/Duplicates", @"Review App"]
      ];

    self.takeMeActionSheetDelegate = [[DMTakeMeActionSheetDelegate alloc] init];
    
    // Setup .xibs
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DMSettingsTableViewCell"];
    
    if ([DMDefaultsInterfaceConstants preferredStores].count < 1)
        [DMDefaultsInterfaceConstants setPreferredStores:[NSArray arrayWithObject:@"All"]];
    
    self.preferredStores = [DMDefaultsInterfaceConstants preferredStores];
    
    self.multipleStores = [DMDefaultsInterfaceConstants multipleStoresEnabled];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"Settings";
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"View disappearing");
    [[DMGrowlerAPI sharedInstance] setPreferredStores:[DMDefaultsInterfaceConstants preferredStores] forUser:[DMDefaultsInterfaceConstants pushID] withSuccess:^(id JSON) {
        NSLog(@"%@", JSON);
        [DMDefaultsInterfaceConstants setPreferredStoresSynced:YES];
    } andFailure:^(id JSON) {
        [DMDefaultsInterfaceConstants setPreferredStoresSynced:NO];
        NSLog(@"%@", JSON);
    }];
    [super viewWillDisappear:animated];
}

#pragma mark TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //** Sections
    // 0 - About
    // 1 - Notifications
    // 2 - Feedback
    // 3 - Other
    // Also that enum...
    switch (indexPath.section) {
        case ABOUT: // About
            [self handleAbout:indexPath.row];
            break;
        case NOTIFICATIONS: // Notifications
            [self handeStore:indexPath.row];
            break;
        case SUPPORT: // Feedback
            [self handleSupport:indexPath.row];
            break;
        case OTHER:
            [self handleOther:indexPath.row];
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
    if (!self.multipleStores && indexPath.section == NOTIFICATIONS) {
        return 0.0f;
    }
    return 44.0f;
}

#pragma mark TableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Make sure notifications section gets right number of rows.
    if (section == NOTIFICATIONS) return self.preferredStores.count + 1;
    return [(NSArray *)[self.content objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.content.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case ABOUT:
            return @"About";
            break;
        case NOTIFICATIONS:
            return @"Notifications";
            break;
        case SUPPORT:
            return @"Support";
            break;
        case OTHER:
            return @"Other";
            break;
        default:
            break;
    }
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != NOTIFICATIONS) {
        NSString *cellIdentifier = @"DMSettingsTableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DMSettingsTableViewCell"];
        }

        cell.textLabel.text = self.content[indexPath.section][indexPath.row];
        
        if (indexPath.section == ABOUT && (indexPath.row == 0 || indexPath.row == 3)) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.textColor = [UIColor blackColor];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
//            cell.textLabel.textColor = self.systemBlueColor;
        }
        return cell;
    }
    else {
        NSString *cellIdentifier = @"DMSettingsNotificationStoreTableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DMSettingsNotificationStoreTableViewCell"];
        }
        
        if (indexPath.row < self.preferredStores.count) {
            cell.textLabel.text = @"Preferred Store";
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.text = self.preferredStores[indexPath.row];
        } else {
            cell.textLabel.text = @"Add Store";
//            cell.textLabel.textColor = self.systemBlueColor;
            cell.detailTextLabel.text = @"";
        }
        return cell;
    }
    return nil;
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
            break;
        case 1:
            break;
        default:
            break;
    }
}

- (void)handeStore:(NSInteger)index
{
    self.selectedStoreName = nil;
    if (index > self.preferredStores.count - 1 || self.preferredStores.count == 1) {
        self.selectedIndexPath = self.tableView.indexPathForSelectedRow;
        if (self.selectedIndexPath.row == 0) {
            self.selectedStoreName = self.preferredStores[index];
        }
        [self showStoreNotificationChooser:NO];
    } else {
        self.selectedStoreName = self.preferredStores[index];
        self.selectedIndexPath = self.tableView.indexPathForSelectedRow;
        [self showStoreNotificationChooser:YES];
    }
}

- (void)handleOther:(NSInteger)index
{
    switch (index) {
        case 0: // 1:  @"Test Push Notifications",
            [[DMGrowlerAPI sharedInstance] testPushNotifictaionsWithSuccess:^(id JSON) {
                NSLog(@"Success - %@", JSON);
            } andFailure:^(id JSON) {
                UIAlertView *failureAlertView = [[UIAlertView alloc] initWithTitle:@"Push Failed!"
                                                                           message:@"Looks like the test failed. Please make sure you're connected to the internet and try again later\nFeel free to contact support about this."
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"Okay"
                                                                 otherButtonTitles:nil];
                [failureAlertView show];
                NSLog(@"Failure - %@", JSON);
            }];
            break;
        case 1: // 2:  @"Fix Favorites Names/Duplicates"
            break;
        case 2:
            [self reviewApp];
            break;
        default:
            break;
    }
}

- (void)reviewApp
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Review the app?"
                                                        message:@"Would you like to write an appstore view of GM Taplist?"
                                                       delegate:self
                                              cancelButtonTitle:@"No Thanks"
                                              otherButtonTitles: @"Yes!", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex == buttonIndex) return;
    else {
        NSString * theUrl = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=707321886&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:theUrl]];
    }
}

- (void)showStoreNotificationChooser:(BOOL)showRemoveOption
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
    if (showRemoveOption) {
        [actionSheet addButtonWithTitle:@"Remove Store"];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    if (showRemoveOption) {
        actionSheet.destructiveButtonIndex = actionSheet.numberOfButtons - 2;
    }

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
            subject = self.suggestionEmailSubject;
            message = self.suggestionEmailBody;
            recipients = [NSArray arrayWithObject:@"fill@growlmovement.com"];
            break;
        case 1:    // 1 support
            subject = self.supportEmailSubject;
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self.takeMeActionSheetDelegate
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];

    for (NSString *store in [DMDefaultsInterfaceConstants stores]) {
        [actionSheet addButtonWithTitle:store];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];

    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    [actionSheet showInView:self.view];
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

- (UIColor *)systemBlueColor
{
    return [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1.0];
}
#pragma mark ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *store;
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    else if (buttonIndex == actionSheet.destructiveButtonIndex) {
        NSLog(@"DESTRUCTIVE!!!");
        [DMDefaultsInterfaceConstants removePreferredStore:self.selectedStoreName];
        self.preferredStores = [DMDefaultsInterfaceConstants preferredStores];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (buttonIndex == 0) {
        store = @"All";
        [DMDefaultsInterfaceConstants setPreferredStores:[NSArray arrayWithObject:store]];
        self.preferredStores = [DMDefaultsInterfaceConstants preferredStores];
        [self.tableView reloadData];
    }
    else {
        store = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([self.preferredStores containsObject:store]) {
            return;
        }
        else if (self.selectedIndexPath && self.selectedStoreName) {
            [DMDefaultsInterfaceConstants removePreferredStore:@"All"];
            [DMDefaultsInterfaceConstants removePreferredStore:self.selectedStoreName];
            [DMDefaultsInterfaceConstants addPreferredStore:store];
            self.preferredStores = [DMDefaultsInterfaceConstants preferredStores];
            [self.tableView reloadData];
        }
        else if (!self.selectedStoreName) {
            [DMDefaultsInterfaceConstants addPreferredStore:store];
            self.preferredStores = [DMDefaultsInterfaceConstants preferredStores];
            NSUInteger previousCount = self.preferredStores.count;
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.preferredStores.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [DMDefaultsInterfaceConstants removePreferredStore:@"All"];
            self.preferredStores = [DMDefaultsInterfaceConstants preferredStores];
            if (previousCount > self.preferredStores.count) {
                [self.tableView reloadData];
            }
        }
        else {
            [DMDefaultsInterfaceConstants removePreferredStore:@"All"];
            [DMDefaultsInterfaceConstants addPreferredStore:store];
            self.preferredStores = [DMDefaultsInterfaceConstants preferredStores];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.preferredStores.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }

    }
    [DMDefaultsInterfaceConstants setPreferredStoresSynced:NO];
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
    return [NSString stringWithFormat:@"[%@] Support", THE_APPS_NAME];
}

- (NSString *)suggestionEmailSubject
{
    return [NSString stringWithFormat:@"[%@] Suggestion", THE_APPS_NAME];
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
