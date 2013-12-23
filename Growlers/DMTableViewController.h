//
//  DMTableViewController.h
//  Growlers
//
//  Created by Daniel Miedema on 7/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMGrowlerAPI.h"

@interface DMTableViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate, UIActionSheetDelegate>

// Pass my context so I can intanciate my coreData methods object
@property (nonatomic, strong) NSManagedObjectContext *managedContext;

@end