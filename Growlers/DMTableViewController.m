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
#import "Beer.h"
#import "Favorites.h"
#import "DMCoreDataMethods.h"
#import "DRNRealTimeBlurView.h"


@interface DMTableViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSArray *beers;
@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, strong) NSMutableArray *highlightedBeers;
@property (nonatomic, strong) NSString *udid;
@property (nonatomic, strong) DMCoreDataMethods *coreData;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@property (nonatomic, strong) UISegmentedControl *headerSegmentControl;

- (void)loadBeers;
- (void)loadFavorites;
- (void)about:(id)sender;

- (void)resetHighlightedBeers;

- (BOOL)setNavigationBarTint;

- (int)getToday;
- (BOOL)checkToday:(id)tapID;

@property (nonatomic, strong) UIGestureRecognizer *swipeGesture;

@end

@implementation DMTableViewController

typedef enum {
    SHOW_ON_TAP = 0,
    SHOW_FAVORITES = 1,
    SHOW_FULL_HISTORY = 2
} SEGMNET_CONTROL_INDEX;

CGPoint _gestureBeginLocation;
BOOL _performSegmentChange;

#pragma mark View Life Cycle

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [_coreData resetBeerDatabase:_beers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    } else {
        // Get tint based on if they're open.
//        if ([self setNavigationBarTint]) {
//            UIColor *growlYellow = [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:1];
////            UIColor *growlYellow = [UIColor colorWithHue:54.0/360.0 saturation:0.71 brightness:0.91 alpha:1];
//            self.navigationController.navigationBar.tintColor = growlYellow;
//            self.refreshControl.tintColor = growlYellow;
//            _headerSegmentControl.tintColor = growlYellow;
//        } else {
            self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
            self.refreshControl.tintColor = [UIColor darkGrayColor];
            _headerSegmentControl.tintColor = [UIColor darkGrayColor];
//        }
    
        // This helps subliment removing the back text from a pushed view controller.
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    
}

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
    
    // Setup Navigation Bar button Items
    UIBarButtonItem *info = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered target:self action:@selector(about:)];
//    UIBarButtonItem *clearNew = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(resetHighlightedBeers)];
    self.navigationItem.leftBarButtonItem = info;
//    self.navigationItem.rightBarButtonItem = clearNew;

    // Setup Refresh control
    [self.refreshControl addTarget:self action:@selector(loadBeers) forControlEvents:UIControlEventValueChanged];

    // Setup Segment control
    _headerSegmentControl = [[UISegmentedControl alloc] initWithItems:@[@"On Tap", @"Favorites", @"All"]];
    [_headerSegmentControl addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
    _headerSegmentControl.selectedSegmentIndex = 0;
    
    // Setup CoreData stuff
    _coreData = [[DMCoreDataMethods alloc] initWithManagedObjectContext:self.managedContext];

    // Setup DateFormatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"j:m" options:0 locale:[NSLocale currentLocale]];
    _dateFormatter.defaultDate = [NSDate date];
    
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    leftSwipeGesture.direction = (UISwipeGestureRecognizerDirectionLeft);
    rightSwipeGesture.direction = (UISwipeGestureRecognizerDirectionRight);
    leftSwipeGesture.numberOfTouchesRequired = 1;
    rightSwipeGesture.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:leftSwipeGesture];
    [self.tableView addGestureRecognizer:rightSwipeGesture];
    
    // Search contorller


}

#pragma mark - Implementation

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

- (int)getToday
{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *todaysDate = [calendar components:(NSDayCalendarUnit) fromDate:today];
    
    return [todaysDate day];
}

- (BOOL)checkToday:(id)tap_id
{
    return [tap_id integerValue] == [self getToday];
}

- (void)loadBeers
{
    // if we're spinnin' and refreshin'
    // ... stop it.
    if (self.refreshControl.refreshing) {
        // Setup Title
        NSString *str = [NSString stringWithFormat:@"Last Updated at %@", [_dateFormatter stringFromDate:[NSDate date]]];
        NSAttributedString *attrStr;
        // if iOS7, font color matches tint color.
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
             attrStr = [[NSAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName: self.navigationController.navigationBar.tintColor}];
        } else {
            attrStr = [[NSAttributedString alloc] initWithString:str];
        }
        // Set the title with last updated text because its nice to have
        self.refreshControl.attributedTitle = attrStr;
        // Stop refreshing
        [self.refreshControl endRefreshing];
    }
    
    // if we're on favorites, bail.
    if (_headerSegmentControl.selectedSegmentIndex == SHOW_FAVORITES) {
        return;
    }
    
    if (self.refreshControl.bounds.size.height >= 65) {
        [self resetHighlightedBeers];
    }
    
    // check segment control to see what action I should perform
    SERVER_FLAG action = (_headerSegmentControl.selectedSegmentIndex == SHOW_ON_TAP) ? ON_TAP : ALL;
    
    [[DMGrowlerAPI sharedInstance] getBeersWithFlag:action andSuccess:^(id JSON) {
        _beers = JSON;
        if (action == ON_TAP) {
            [self checkForNewBeers];
        }
        [self.tableView reloadData];
    } andFailure:^(id JSON) {
        NSLog(@"Error - %@", JSON);
    }];
}

- (void)loadFavorites
{
    _beers = [_coreData getAllFavorites];
    [self.tableView reloadData];
}

- (void)checkForNewBeers
{
    for (NSDictionary *beer in _beers) {
        if(![_coreData checkForBeerInDatabase:beer]) {
            [_highlightedBeers addObject:beer];
        }
    }
    [_coreData resetBeerDatabase:_beers];
}

#pragma mark Table view data source

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
    
    switch (_headerSegmentControl.selectedSegmentIndex) {
        case SHOW_ON_TAP:
            cell.beerInfo.text = [NSString stringWithFormat:@"IBU: %@  ABV: %@  Growlette: $%@  Growler: $%@",
                                  beer[@"ibu"], beer[@"abv"], beer[@"growlette"], beer[@"growler"]];
            break;
        default:
            cell.beerInfo.text = [NSString stringWithFormat:@"IBU: %@  ABV: %@", beer[@"ibu"], beer[@"abv"]];
            break;
    }

    // Get ID and check for today == tap.id and highlight
    // last day of month, ending ones go on sale
    if ([self checkToday:beer[@"tap_id"]] && _headerSegmentControl.selectedSegmentIndex != SHOW_FULL_HISTORY) {
        cell.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.35];
        cell.beerName.textColor = [UIColor whiteColor];
        cell.brewery.textColor = [UIColor whiteColor];
        cell.beerInfo.textColor = [UIColor lightTextColor];
    } else if ([_highlightedBeers containsObject:beer]) {
        cell.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:0.125];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
        cell.beerName.textColor = [UIColor blackColor];
        cell.brewery.textColor = [UIColor blackColor];
        cell.beerInfo.textColor = [UIColor darkGrayColor];
    }
    
    // check if beer is favorite
    if ([_coreData isBeerFavorited:beer]) {
        cell.favoriteMarker.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:0.85];
    } else {
        cell.favoriteMarker.backgroundColor = [UIColor clearColor];
    }
    
    cell.favoriteMarker.layer.masksToBounds = YES;
    cell.favoriteMarker.layer.cornerRadius = cell.favoriteMarker.bounds.size.width / 2.0;
    

    
    return cell;
}

#pragma mark Table view Other

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    DRNRealTimeBlurView *blurView = [[DRNRealTimeBlurView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 26)];
//    _headerSegmentControl.frame = blurView.frame;
//    [blurView addSubview:_headerSegmentControl];
//    _headerSegmentControl.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.75];
//    return blurView;
    return _headerSegmentControl;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 26.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *beer = _beers[indexPath.row];
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kGrowler_Push_ID];
    
    if ([_coreData isBeerFavorited:beer]) {
        [[DMGrowlerAPI sharedInstance] favoriteBeer:@{@"name": beer[@"name"], @"brewer": beer[@"brewer"], @"udid": (token ? token : _udid), @"fav": @NO} withAction:UNFAVORITE withSuccess:^(id JSON) {
            // CoreData Save
            [_coreData unFavoriteBeer:beer];
            NSLog(@"Beer unfavorited successfully");
            DMGrowlerTableViewCell *cell = (DMGrowlerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.favoriteMarker.backgroundColor = [UIColor clearColor];
        } andFailure:^(id JSON) {
            // Handle failure
            NSLog(@"unfavoriting failed: %@", JSON);
        }];
    }
    else {
        [[DMGrowlerAPI sharedInstance] favoriteBeer:@{@"name": beer[@"name"], @"brewer": beer[@"brewer"], @"udid": (token ? token : _udid), @"fav": @YES} withAction:FAVORITE withSuccess:^(id JSON) {
            // CoreData save
            [_coreData favoriteBeer:beer];
            NSLog(@"Beer favorited successfully");
            DMGrowlerTableViewCell *cell = (DMGrowlerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.favoriteMarker.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:0.85];
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

#pragma mark Navigation/BarButtonItems

- (void)about:(id)sender
{
    DMAboutViewController *aboutView = [self.storyboard instantiateViewControllerWithIdentifier:@"DMAboutViewController"];
    [self.navigationController pushViewController:aboutView animated:YES];
}

- (void)resetHighlightedBeers
{
    [_highlightedBeers removeAllObjects];
    [_coreData resetBeerDatabase:_beers];
}

/* Handle Segmented Control change */
- (void)segmentedControlChanged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case SHOW_ON_TAP: // on tap
            [self loadBeers];
            break;
        case SHOW_FAVORITES: // favorites
            [self loadFavorites];
            break;
        case SHOW_FULL_HISTORY: // All
            [self loadBeers];
            break;
        default: // Whoops
            break;
    }
}

#pragma mark Gestures

- (void)handleSwipe:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        self.headerSegmentControl.selectedSegmentIndex = abs(self.headerSegmentControl.selectedSegmentIndex + 1) % self.headerSegmentControl.numberOfSegments;
        [self segmentedControlChanged:_headerSegmentControl];
    }
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        self.headerSegmentControl.selectedSegmentIndex =
            self.headerSegmentControl.selectedSegmentIndex - 1 >= 0 ?
            self.headerSegmentControl.selectedSegmentIndex - 1 :
            self.headerSegmentControl.numberOfSegments - 1;
        [self segmentedControlChanged:_headerSegmentControl];
    }
}

@end
