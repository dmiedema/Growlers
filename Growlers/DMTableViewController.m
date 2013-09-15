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

@interface DMTableViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) NSArray *beers;
@property (nonatomic, strong) NSMutableArray *filteredBeers;
@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, strong) NSMutableArray *highlightedBeers;
@property (nonatomic, strong) NSString *udid;
@property (nonatomic, strong) NSString *selectedStore;
@property (nonatomic, strong) DMCoreDataMethods *coreData;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@property (nonatomic, strong) UISegmentedControl *headerSegmentControl;

- (void)loadBeers;
- (void)loadFavorites;
- (void)about:(id)sender;
- (void)showActionSheet:(id)sender;

- (void)resetHighlightedBeers;
- (BOOL)checkIfOpen;
- (void)setNavigationBarTint;

- (int)getToday;
- (BOOL)checkToday:(id)tapID;
- (BOOL)checkLastDateOfMonth;

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
//    [_coreData resetBeerDatabase:self.beers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // get my udid for favoriting
    _udid = [[NSUserDefaults standardUserDefaults] objectForKey:kGrowler_UUID];
    
    // ActionSheet and Selected Store
    _growlMovementStores = kGrowler_Stores;
    NSString *lastSelectedStore = [[NSUserDefaults standardUserDefaults] objectForKey:kGrowler_Last_Selected_Store];
    self.selectedStore = lastSelectedStore ? lastSelectedStore : _growlMovementStores[0];
    
    // Load up my .xib 
    [self.tableView registerNib:[UINib nibWithNibName:@"DMGrowlerTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"growlerCell"];
    // Load up .xib for search results table view
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"DMGrowlerTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"growlerCell"];
    
    // Setup highlighted beers
    _highlightedBeers = [NSMutableArray new];
    // Setup filtered beers
    self.filteredBeers = [NSMutableArray arrayWithCapacity:32]; // max number of beers on tap at any given time
    
    // Load up the beers
    [self loadBeers];
    
    // Setup Navigation Bar button Items
    UIBarButtonItem *info = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStyleBordered target:self action:@selector(about:)];
//    UIBarButtonItem *storeButton = [[UIBarButtonItem alloc] initWithTitle:@"Store" style:UIBarButtonItemStyleBordered target:self action:@selector(showActionSheet:)];
    self.navigationItem.leftBarButtonItem = info;
//    self.navigationItem.rightBarButtonItem = storeButton;
    
    // Modify Search Controller
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchBar.delegate = self;
    self.searchDisplayController.searchBar.showsScopeBar = NO;

    // Setup Refresh control
    [self.refreshControl addTarget:self action:@selector(loadBeers) forControlEvents:UIControlEventValueChanged];

    // Setup Segment control
    self.headerSegmentControl = [[UISegmentedControl alloc] initWithItems:@[@"On Tap", @"Favorites", @"All"]];
    [self.headerSegmentControl addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
    self.headerSegmentControl.selectedSegmentIndex = 0;
    
    // Setup CoreData stuff
    _coreData = [[DMCoreDataMethods alloc] initWithManagedObjectContext:self.managedContext];

    // Setup DateFormatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"j:m" options:0 locale:[NSLocale currentLocale]];
    _dateFormatter.defaultDate = [NSDate date];
    
    
    // Orientation
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"Growl Movement";
    [self setNavigationBarTint];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    leftSwipeGesture.direction = (UISwipeGestureRecognizerDirectionLeft);
    rightSwipeGesture.direction = (UISwipeGestureRecognizerDirectionRight);
    leftSwipeGesture.numberOfTouchesRequired = 1;
    rightSwipeGesture.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:leftSwipeGesture];
    [self.tableView addGestureRecognizer:rightSwipeGesture];
}

- (void)orientationChanged:(NSNotification *)notification
{
    if ([self.searchDisplayController isActive]) {
        [self.searchDisplayController.searchResultsTableView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark Implementation
- (BOOL)checkIfOpen
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

- (void)setNavigationBarTint
{
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        //        self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
        self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
        self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
        self.headerSegmentControl.tintColor = [UIColor darkGrayColor];
    } else {
        if ([self checkIfOpen]) {
            //            UIColor *growlYellow = [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:1];
            UIColor *growlYellow = [UIColor colorWithHue:54.0/360.0 saturation:0.71 brightness:0.91 alpha:1];
            self.navigationController.navigationBar.tintColor = growlYellow;
            self.refreshControl.tintColor = growlYellow;
            self.headerSegmentControl.tintColor = growlYellow;
        } else {
            self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
            self.refreshControl.tintColor = [UIColor darkGrayColor];
            self.headerSegmentControl.tintColor = [UIColor darkGrayColor];
        }
        // This helps subliment removing the back text from a pushed view controller.
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
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

- (BOOL)checkLastDateOfMonth
{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *todaysDate = [calendar components:(NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    
    int month = todaysDate.month;
    int day   = todaysDate.day;
    
    switch (month) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            return day == 31;
            break;
        case 2:
            return day == 28;
            break;
        case 4:
        case 6:
        case 9:
        case 11:
            return day == 30;
            break;
        default:
            return NO;
            break;
    }
    return NO;
}

- (void)loadBeers
{
    // if we're spinnin' and refreshin'
    // ... stop it.
    
    if (self.refreshControl.bounds.size.height >= 65 && self.refreshControl.refreshing && self.headerSegmentControl.selectedSegmentIndex == SHOW_ON_TAP) {
        [self resetHighlightedBeers];
    }
    
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
    
    // if we're on favorites, we shouldn't be here. Bail.
    if (self.headerSegmentControl.selectedSegmentIndex == SHOW_FAVORITES) {
        return;
    }
    
    // check segment control to see what action I should perform
    SERVER_FLAG action = (self.headerSegmentControl.selectedSegmentIndex == SHOW_ON_TAP) ? ON_TAP : ALL;
    
    [[DMGrowlerAPI sharedInstance] getBeersWithFlag:action forStore:self.selectedStore andSuccess:^(id JSON) {
        self.beers = JSON;
        if (action == ON_TAP) {
            [self checkForNewBeers];
        }
        if ([self.searchDisplayController isActive]) {
            [self updateFilteredContentForSearchString:self.searchDisplayController.searchBar.text];
            [self.searchDisplayController.searchResultsTableView reloadData];
        } else {
            [self.tableView reloadData];
        }
    } andFailure:^(id JSON) {
        NSLog(@"Error - %@", JSON);
    }];
}

- (void)loadFavorites
{
    NSArray *favorites = [_coreData getAllFavorites];
    if (favorites.count > 0) {
        self.beers = favorites;
    } else {
        self.beers = @[@{@"name": @"No Favorites!", @"brewer": @"Go Favorite some Beers!", @"ibu": @"", @"abv": @""}];
    }
    if ([self.searchDisplayController isActive]) {
        [self updateFilteredContentForSearchString:self.searchDisplayController.searchBar.text];
        [self.searchDisplayController.searchResultsTableView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

- (void)checkForNewBeers
{
    for (NSDictionary *beer in self.beers) {
        if(![_coreData checkForBeerInDatabase:beer]) {
            [_highlightedBeers addObject:beer];
        }
    }
    [_coreData resetBeerDatabase:self.beers];
}

#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    // Based on which I'm showing, filtered results or full list
    if ([self.searchDisplayController isActive]) {
        return self.filteredBeers.count;
    } else {
        return self.beers.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"growlerCell";
    DMGrowlerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // try my best to make everything fit.
    cell.beerName.adjustsLetterSpacingToFitWidth = YES;
    cell.beerName.adjustsFontSizeToFitWidth = YES;
    
    cell.brewery.adjustsLetterSpacingToFitWidth = YES;
    cell.brewery.adjustsFontSizeToFitWidth = YES;
    
    cell.beerInfo.adjustsLetterSpacingToFitWidth = YES;
    cell.beerInfo.adjustsFontSizeToFitWidth = YES;
    
    NSDictionary *beer;
//    if ([self.searchDisplayController isActive]) {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        beer = self.filteredBeers[indexPath.row];
    } else {
        beer = self.beers[indexPath.row];
    }
    // Configure the cell...
    switch (self.headerSegmentControl.selectedSegmentIndex) {
        case SHOW_ON_TAP:
            cell.beerName.text = [NSString stringWithFormat:@"%@. %@", beer[@"tap_id"], beer[@"name"]];
            cell.beerInfo.text = [NSString stringWithFormat:@"IBU: %@  ABV: %@  Growler: $%@  Growlette: $%@",
                                  beer[@"ibu"], beer[@"abv"], beer[@"growler"], beer[@"growlette"]];
            break;
        default:
            cell.beerName.text = beer[@"name"];
            cell.beerInfo.text = [NSString stringWithFormat:@"IBU: %@  ABV: %@", beer[@"ibu"], beer[@"abv"]];
            break;
    }
    
    cell.brewery.text  = beer[@"brewer"];

    // Get ID and check for today == tap.id and highlight
    // last day of month, ending ones go on sale
    if (self.headerSegmentControl.selectedSegmentIndex == SHOW_ON_TAP &&
        ([self checkToday:beer[@"tap_id"]] || ([self checkLastDateOfMonth] && [beer[@"tap_id"] intValue] >= self.getToday ))
        )
    {
        cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
        cell.beerName.textColor = [UIColor whiteColor];
        cell.brewery.textColor = [UIColor whiteColor];
        cell.beerInfo.textColor = [UIColor lightTextColor];
    } else if ([_highlightedBeers containsObject:beer]) {
        cell.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:0.125];
        cell.beerName.textColor = [UIColor blackColor];
        cell.brewery.textColor = [UIColor blackColor];
        cell.beerInfo.textColor = [UIColor darkGrayColor];
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

#pragma mark Table View Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 34.0f)];
    headerView.backgroundColor = [UIColor whiteColor];
    self.headerSegmentControl.frame = CGRectInset(headerView.frame, 12, 4);
    [headerView addSubview:self.headerSegmentControl];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *beer;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        beer = self.filteredBeers[indexPath.row];
    } else {
        beer = self.beers[indexPath.row];
    }
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kGrowler_Push_ID];
    
    if ([_coreData isBeerFavorited:beer]) {
        [[DMGrowlerAPI sharedInstance] favoriteBeer:@{@"name": beer[@"name"], @"brewer": beer[@"brewer"], @"udid": (token ? token : _udid), @"store": [self.selectedStore lowercaseString], @"fav": @NO} withAction:UNFAVORITE withSuccess:^(id JSON) {
            // CoreData Save
            NSMutableDictionary *favBeer = [beer mutableCopy];
            favBeer[@"store"] = self.selectedStore;
            [_coreData unFavoriteBeer:favBeer];
            DMGrowlerTableViewCell *cell = (DMGrowlerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.favoriteMarker.backgroundColor = [UIColor clearColor];
        } andFailure:^(id JSON) {
            // Handle failure
            NSLog(@"unfavoriting failed: %@", JSON);
        }];
    }
    else {
        [[DMGrowlerAPI sharedInstance] favoriteBeer:@{@"name": beer[@"name"], @"brewer": beer[@"brewer"], @"udid": (token ? token : _udid), @"store": [self.selectedStore lowercaseString], @"fav": @YES} withAction:FAVORITE withSuccess:^(id JSON) {
            // CoreData save
            NSMutableDictionary *favBeer = [beer mutableCopy];
            favBeer[@"store"] = self.selectedStore;
            [_coreData favoriteBeer:favBeer];
            DMGrowlerTableViewCell *cell = (DMGrowlerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.favoriteMarker.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:0.85];
        } andFailure:^(id JSON) {
            // Handle failure
            NSLog(@"Favoriting failed: %@", JSON);
        }];
    }
    

    // Deselect the row.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // reload the data so the favorite marker stays.
    [tableView reloadData];
}

#pragma mark UISearchController

- (void)updateFilteredContentForSearchString:(NSString *)searchString
{
    // Make a mutable copy
    self.filteredBeers = [self.beers mutableCopy];
    // Trim off whitespace
    NSString *strippedSearch = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@ OR %K contains[cd] %@", @"name", strippedSearch, @"brewer", strippedSearch];
    
    self.filteredBeers = [[self.filteredBeers filteredArrayUsingPredicate:predicate] mutableCopy];
}

#pragma mark UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateFilteredContentForSearchString:searchString];
    return YES;
}

#pragma mark UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsScopeBar = NO;
    [searchBar sizeToFit];
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsScopeBar = NO;
    [searchBar sizeToFit];
    if (searchBar.text.length > 0) {
        [self.searchDisplayController.searchResultsTableView reloadData];
    } else {
        [self.tableView reloadData];
    }
    return YES;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.tableView reloadData];
}

#pragma mark UIActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex != buttonIndex) {
        self.selectedStore = [actionSheet buttonTitleAtIndex:buttonIndex];
        [[NSUserDefaults standardUserDefaults] setObject:self.selectedStore forKey:kGrowler_Last_Selected_Store];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark Navigation/BarButtonItems

- (void)about:(id)sender
{
    DMAboutViewController *aboutView = [self.storyboard instantiateViewControllerWithIdentifier:@"DMAboutViewController"];
    [self.navigationController pushViewController:aboutView animated:YES];
}

- (void)showActionSheet:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:Nil
                                                    otherButtonTitles:@"Keizer", nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)resetHighlightedBeers
{
    [_highlightedBeers removeAllObjects];
    [_coreData resetBeerDatabase:self.beers];
}

/* Handle Segmented Control change */
- (void)segmentedControlChanged:(UISegmentedControl *)sender
{
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    [self.tableView setContentOffset:CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height) animated:YES];
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
        if (self.headerSegmentControl.selectedSegmentIndex < self.headerSegmentControl.numberOfSegments - 1) {
            self.headerSegmentControl.selectedSegmentIndex++;
            [self segmentedControlChanged:self.headerSegmentControl];
        } else return;
    }
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        if (self.headerSegmentControl.selectedSegmentIndex > 0) {
            self.headerSegmentControl.selectedSegmentIndex--;
            [self segmentedControlChanged:self.headerSegmentControl];
        } else return;
    }
}

# pragma mark UIScrollViewDelegate
/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = self.tableView.sectionHeaderHeight;

    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y + self.searchDisplayController.searchBar.frame.size.height+22, 0, 0, 0);
        self.navigationController.navigationBar.topItem.title = @"Growl Movement";
//        UIEdgeInsetsMake(<#CGFloat top#>, <#CGFloat left#>, <#CGFloat bottom#>, <#CGFloat right#>)
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y >= sectionHeaderHeight){
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        self.navigationController.navigationBar.topItem.title = [self.headerSegmentControl titleForSegmentAtIndex:self.headerSegmentControl.selectedSegmentIndex];
    }
}
*/

@end
