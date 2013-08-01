//
//  DMTableViewController.m
//  Growlers
//
//  Created by Daniel Miedema on 7/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMTableViewController.h"
#import "DMGrowlerTableViewCell.h"
#import "DMAboutViewController.h"
#import "Beer+Beer_Create.h"

@interface DMTableViewController ()
@property (nonatomic, strong) NSArray *beers;
@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, strong) NSMutableArray *highlightedBeers;
@property (nonatomic, strong) NSMutableArray *favoriteBeers;
@property (nonatomic, strong) NSString *udid;
- (void)loadBeers;
- (void)about:(id)sender;

- (void)favoriteBeer:(NSDictionary *)newBeerToFavorite;
- (BOOL)setNavigationBarTint;
@end

@implementation DMTableViewController

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    if (!_beerDatabase) {
//        NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//        documentsURL = [documentsURL URLByAppendingPathComponent:@"Default Beers Database"];
//        _beerDatabase = [[UIManagedDocument alloc] initWithFileURL:documentsURL];
//        
//    }
//}
//
//- (void)useDocument {
//    if (![[NSFileManager defaultManager] fileExistsAtPath:_beerDatabase.fileURL.path]) {
//        [_beerDatabase saveToURL:_beerDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
//            [self loadBeersIntoDatabase:_beerDatabase];
//        }];
//    } else if (_beerDatabase.documentState == UIDocumentStateClosed) {
//        [_beerDatabase openWithCompletionHandler:^(BOOL success) {
//            [self loadBeersIntoDatabase:_beerDatabase];
//        }];
//    } else if (_beerDatabase.documentState == UIDocumentStateNormal) {
//        [self loadBeersIntoDatabase:_beerDatabase];
//    }
//}
//
//- (void)loadBeersIntoDatabase:(UIManagedDocument *)document {
//    [document.managedObjectContext performBlock:^{
//        for (NSDictionary *beer in _beers) {
//            [Beer beerWithInfo:beer inManagedObjectContext:document.managedObjectContext];
//        }
//    }];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // get my udid for favoriting
    _udid = [[NSUserDefaults standardUserDefaults] objectForKey:kGrowler_UUID];
    
    // Load up my .xib 
    [self.tableView registerNib:[UINib nibWithNibName:@"DMGrowlerTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"growlerCell"];

    // Setup highlighted beers
    _highlightedBeers = [NSMutableArray new];
    
    // Get favorites, if there aren't any, I'll make it.
    _favoriteBeers = [[NSUserDefaults standardUserDefaults] objectForKey:kGrowler_Favorites];
    if (!_favoriteBeers) { _favoriteBeers = [NSMutableArray new]; }
    
    // Load up the beers
    [self loadBeers];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    UIBarButtonItem *info = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered target:self action:@selector(about:)];
    self.navigationItem.leftBarButtonItem = info;
    
    // TODO: add text of last updated time
    [self.refreshControl addTarget:self action:@selector(loadBeers) forControlEvents:UIControlEventValueChanged];
    

    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    } else {
        // Get tint based on if they're open.
        if ([self setNavigationBarTint]) {
            self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:0.125];
            self.refreshControl.tintColor = [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:0.125];
        } else {
            self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
            self.refreshControl.tintColor = [UIColor darkGrayColor];
        }
        
        // This helps subliment removing the back text from a pushed view controller.
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
}

- (BOOL)setNavigationBarTint
{
    // Get today
    NSDate *today = [NSDate date];
    // Get users calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // Get date compontents
    NSDateComponents *weekdayComponents = [calendar components:(NSWeekdayCalendarUnit | NSHourCalendarUnit) fromDate:today];
    // Get the values out.
    NSInteger hour = [weekdayComponents hour];
    NSInteger weekday = [weekdayComponents weekday];

    if (weekday < 5) { // If we're before Friday, noon - 8
        return hour > 11 && hour < 20;
    } else { // Friday and Saturday, 11 to 11
        return hour > 10 && hour < 23;
    }
}

- (void)favoriteBeer:(NSDictionary *)newBeerToFavorite {
    
}

- (void)loadBeers
{
    // if we're spinnin' and refreshin'
    // ... stop it.
    if (self.refreshControl.refreshing) {
        // dylan wanted this, then he didn't.
        // how undecisive can you be
//        [_highlightedBeers removeAllObjects];
        [self.refreshControl endRefreshing];
    }
    
    [[DMGrowlerAPI sharedInstance] getBeersWithSuccess:^(id JSON) {
        _beers = JSON;
        [self checkForNewBeers];
        [self.tableView reloadData];
    } andFailure:^(id JSON) {
        // Error
        NSLog(@"Error - %@", JSON);
    }];
}

- (void)checkForNewBeers
{
    NSArray *existingBeers = [[NSUserDefaults standardUserDefaults] objectForKey:@"beers"];
    for (NSDictionary *beer in _beers) {
        if (![existingBeers containsObject:beer]) {
            [_highlightedBeers addObject:beer[@"name"]];
        }
    }
    // ugly hack, should be using CoreData.
    [[NSUserDefaults standardUserDefaults] setObject:_beers forKey:@"beers"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _beers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"growlerCell";
    DMGrowlerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSDictionary *beer = _beers[indexPath.row];
    // Configure the cell...
    
    cell.beerName.text = beer[@"name"];
    cell.brewery.text  = beer[@"brewer"];
    cell.beerInfo.text = [NSString stringWithFormat:@"IBU: %@  ABV: %@  Growlette: $%@  Growler: $%@",
                                 beer[@"ibu"], beer[@"abv"], beer[@"growlette"], beer[@"growler"]];
    
    if ([_highlightedBeers containsObject:beer[@"name"]]) {
        cell.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:0.125];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    if ([_favoriteBeers containsObject:@{@"name": beer[@"name"], @"brewer": beer[@"brewer"]}]) {
        cell.favoriteMarker.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:0.85];
    } else {
        cell.favoriteMarker.backgroundColor = [UIColor whiteColor];
    }
    
    cell.favoriteMarker.layer.masksToBounds = YES;
    cell.favoriteMarker.layer.cornerRadius = cell.favoriteMarker.bounds.size.width / 2.0;

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *beer = _beers[indexPath.row];
    if ([_favoriteBeers containsObject:@{@"name": beer[@"name"], @"brewer": beer[@"brewer"]}]) {
        [[DMGrowlerAPI sharedInstance] favoriteBeer:@{@"name": beer[@"name"], @"brewer": beer[@"brewer"], @"udid": _udid, @"fav": @"false"} withAction:UNFAVORITE withSuccess:^(id JSON) {
            [_favoriteBeers removeObject:@{@"name": beer[@"name"], @"brewer": beer[@"brewer"]}];
            DMGrowlerTableViewCell *cell = (DMGrowlerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.favoriteMarker.backgroundColor = [UIColor whiteColor];
        } andFailure:^(id JSON) {
            // Handle failure
        }];
    } else {
        [[DMGrowlerAPI sharedInstance] favoriteBeer:@{@"name": beer[@"name"], @"brewer": beer[@"brewer"], @"udid": _udid, @"fav": @"true"} withAction:FAVORITE withSuccess:^(id JSON) {
            [_favoriteBeers addObject:@{@"name": beer[@"name"], @"brewer": beer[@"brewer"]}];
            DMGrowlerTableViewCell *cell = (DMGrowlerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.favoriteMarker.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:0.85];
            NSLog(@"Cell : %@", cell);
        } andFailure:^(id JSON) {
            // Handle failure
        }];
    }
    // Save to defaults.
    [[NSUserDefaults standardUserDefaults] setObject:_favoriteBeers forKey:kGrowler_Favorites];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Deselect the row.
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

- (void)about:(id)sender
{
    DMAboutViewController *aboutView = [self.storyboard instantiateViewControllerWithIdentifier:@"DMAboutViewController"];
    [self.navigationController pushViewController:aboutView animated:YES];
}

@end
