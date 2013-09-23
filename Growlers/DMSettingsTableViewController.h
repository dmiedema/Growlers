//
//  DMSettingsTableViewController.h
//  Growlers
//
//  Created by Daniel Miedema on 9/22/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMSettingsTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UISwitch *facebookSharing;
@property (strong, nonatomic) IBOutlet UISwitch *twitterSharing;
@property (strong, nonatomic) IBOutlet UILabel *preferredStore;

@end
