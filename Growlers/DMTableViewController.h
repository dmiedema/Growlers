//
//  DMTableViewController.h
//  Growlers
//
//  Created by Daniel Miedema on 7/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMGrowlerAPI.h"

@interface DMTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedContext;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSArray *growlMovementStores;

@end