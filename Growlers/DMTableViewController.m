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
#import "Favorites+Create.h"

@interface DMTableViewController ()
@property (nonatomic, strong) NSArray *beers;
@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, strong) NSMutableArray *highlightedBeers;
@property (nonatomic, strong) NSString *udid;
- (void)loadBeers;
- (void)about:(id)sender;

- (BOOL)setNavigationBarTint;
@end

@implementation DMTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // get my udid for favoriting
    _udid = [[NSUserDefaults standardUserDefaults] objectForKey:kGrowler_UUID];
    
    // Load up my .xib 
    [self.tableView registerNib:[UINib nibWithNibName:@"DMGrowlerTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"growlerCell"];

    // Setup highlighted beers
    _highlightedBeers = [NSMutableArray new];
    
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
            self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:1];
            self.refreshControl.tintColor = [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:1];
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
    
    if ([self isBeerFavorited:beer]) {
        cell.favoriteMarker.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:0.85];
    } else {
        cell.favoriteMarker.backgroundColor = [UIColor clearColor];
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
    NSLog(@"Favorites - %@", _favoriteBeers);
    
    NSDictionary *beer = _beers[indexPath.row];
    
    NSLog(@"Beer - %@", beer);
    
    NSLog(@"in there? %hhd", [_favoriteBeers containsObject:@{@"name": beer[@"name"], @"brewer": beer[@"brewer"]}]);
    
    if ([self isBeerFavorited:beer]) {
        [[DMGrowlerAPI sharedInstance] favoriteBeer:@{@"name": beer[@"name"], @"brewer": beer[@"brewer"], @"udid": _udid, @"fav": @NO} withAction:UNFAVORITE withSuccess:^(id JSON) {
            // CoreData Save
            [self unFavoriteBeer:beer];
            NSLog(@"Beer unfavorited successfully");
            DMGrowlerTableViewCell *cell = (DMGrowlerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.favoriteMarker.backgroundColor = [UIColor clearColor];
        } andFailure:^(id JSON) {
            // Handle failure
            NSLog(@"unfavoriting failed: %@", JSON);
        }];
    }
    else {
        [[DMGrowlerAPI sharedInstance] favoriteBeer:@{@"name": beer[@"name"], @"brewer": beer[@"brewer"], @"udid": _udid, @"fav": @YES} withAction:FAVORITE withSuccess:^(id JSON) {
            // CoreData save
            [self favoriteBeer:beer];
            NSLog(@"Beer favorited successfully");
            DMGrowlerTableViewCell *cell = (DMGrowlerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.favoriteMarker.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:0.85];
            NSLog(@"Cell : %@", cell);
        } andFailure:^(id JSON) {
            // Handle failure
            NSLog(@"Favoriting failed: %@", JSON);
        }];
    }
    // Deselect the row.
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    // reload the data so the favorite marker stays.
    [self.tableView reloadData];
}


#pragma mark - Navigation

- (void)about:(id)sender
{
    DMAboutViewController *aboutView = [self.storyboard instantiateViewControllerWithIdentifier:@"DMAboutViewController"];
    [self.navigationController pushViewController:aboutView animated:YES];
}


#pragma mark - CoreData Methods
- (void)favoriteBeer:(NSDictionary *)newBeerToFavorite {
    Favorites *favorite = [NSEntityDescription insertNewObjectForEntityForName:@"Favorites" inManagedObjectContext:self.managedContext];
    favorite.name   = newBeerToFavorite[@"name"];
    favorite.brewer = newBeerToFavorite[@"brewer"];
    
    NSError *coreDataErr = nil;
    if (![self.managedContext save:&coreDataErr]) {
        // handle error
    }
    NSLog(@"Beer Saved");
}

- (void)unFavoriteBeer:(NSDictionary *)beerToUnfavorite {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Favorites"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@ and brewer = %@", beerToUnfavorite[@"name"], beerToUnfavorite[@"brewer"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [self.managedContext executeFetchRequest:request error:&error];
    
    NSLog(@"Matches - %@", matches);
    NSLog(@"Matches Lastobject - %@", matches.lastObject);
    
    [self.managedContext deleteObject:matches.lastObject];
    if (![self.managedContext save:&error]){
        // handle error
    }
    NSLog(@"Beer Unfavorited");
}

- (BOOL)isBeerFavorited:(NSDictionary *)beer {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Favorites"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@ and brewer = %@", beer[@"name"], beer[@"brewer"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [self.managedContext executeFetchRequest:request error:&error];
    
    return matches.count == 1;
}

@end
