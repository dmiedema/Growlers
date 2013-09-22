//
//  DMSettingsTableViewController.m
//  Growlers
//
//  Created by Daniel Miedema on 9/22/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMSettingsTableViewController.h"
#import <MessageUI/MessageUI.h>
#import <MapKit/MapKit.h>

@interface DMSettingsTableViewController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic) BOOL multipleStores;
- (void)showSelectStore;
@end

@implementation DMSettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBar.topItem.title = @"Settings";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.facebookSharing.on = [DMDefaultsInterfaceConstants shareWithFacebookOnFavorite];
    self.twitterSharing.on  = [DMDefaultsInterfaceConstants shareWithTwitterOnFavorite];
    
    self.multipleStores = [DMDefaultsInterfaceConstants multipleStoresEnabled];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected - %@", indexPath);
    //** Sections
    // 0 - About
    // 1 - Social
    // 2 - Notifications
    // 3 - Feedback
    switch (indexPath.section) {
        case 0: // About
            
            break;
        case 1: // Social
            if (indexPath.row == 0) { // facebook
                [self.facebookSharing setOn:!self.facebookSharing.on animated:YES];
            } else {
                [self.twitterSharing setOn:!self.twitterSharing.on animated:YES];
            }
            break;
        case 2: // Notifications
            [self showSelectStore];
            break;
        case 3: // Feedback
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
- (void)showSelectStore
{
    
}
#pragma mark ActionSheet Delegate
#pragma mark MailComposer Delegate

@end
