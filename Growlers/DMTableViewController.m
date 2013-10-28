//
//  DMTableViewController.m
//  Growlers
//
//  Created by Daniel Miedema on 7/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMTableViewController.h"
#import "DMGrowlerTableViewCell.h"
#import "DMSettingsTableViewController.h"
#import "DMHelperMethods.h"
#import "DMCoreDataMethods.h"

@interface DMTableViewController () <UIGestureRecognizerDelegate, UIScrollViewDelegate>
// Private variables. Wow there are a lot.
@property (nonatomic, strong) NSArray *beers;
@property (nonatomic, strong) NSMutableArray *filteredBeers;
@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, strong) NSMutableArray *highlightedBeers;
@property (nonatomic, strong) NSString *selectedStore;
@property (nonatomic, strong) DMCoreDataMethods *coreData;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@property (nonatomic, strong) UISegmentedControl *headerSegmentControl;
@property (nonatomic, strong) UIGestureRecognizer *swipeGesture;

// Private methods
- (void)loadBeers;
- (void)loadFavorites;
- (void)settings:(id)sender;
- (void)showActionSheet:(id)sender;

- (void)resetHighlightedBeers;
- (void)setNavigationBarTint;

- (void)clearNavigationBarPrompt;
- (void)setNavigationBarPrompt;

// Private enums
typedef enum {
    SHOW_ON_TAP = 0,
    SHOW_FAVORITES = 1,
    SHOW_FULL_HISTORY = 2
} SEGMNET_CONTROL_INDEX;

typedef enum {
    ALPHA_NEW_BEER,
    ALPHA_BEER_FAVORITES
} GROWLERS_YELLOW_ALPHA;
// Placed after typedef so no build errors.
- (UIColor *)growlersYellowColor:(GROWLERS_YELLOW_ALPHA)alpha;
@end

@implementation DMTableViewController



CGPoint _gestureBeginLocation;
BOOL _performSegmentChange;

#pragma mark View Life Cycle

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ActionSheet and Selected Store
    NSString *lastSelectedStore = [DMDefaultsInterfaceConstants lastStore];
    self.selectedStore = lastSelectedStore ? lastSelectedStore : [DMDefaultsInterfaceConstants stores][0];
    
    // Load up my .xib 
    [self.tableView registerNib:[UINib nibWithNibName:@"DMGrowlerTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"growlerCell"];
    // Load up .xib for search results table view
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"DMGrowlerTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"growlerCell"];
    
    // Setup highlighted beers
    _highlightedBeers = [NSMutableArray new];
    // Setup filtered beers, its just a mutable array
    self.filteredBeers = [NSMutableArray new];
    
    // Setup Navigation Bar button Items
    UIBarButtonItem *info = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settings:)];
    UIBarButtonItem *storeButton = [[UIBarButtonItem alloc] initWithTitle:@"Store" style:UIBarButtonItemStyleBordered target:self action:@selector(showActionSheet:)];
    
    self.navigationItem.leftBarButtonItem = info;
    // If multiple stores -- show store button
    if([DMDefaultsInterfaceConstants multipleStoresEnabled])
        self.navigationItem.rightBarButtonItem = storeButton;
    
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
    // Signup for notification center.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    // Load up the beers
    [self loadBeers];
    [self setNavigationBarPrompt];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Set the tint color
    [self setNavigationBarTint];
    // Set the title, because if user swipes back it can be wonky. Just make sure its right...
    self.navigationController.navigationBar.topItem.title = @"Growl Movement";
    // Create them gesture recognizers.
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    // Set them directions
    leftSwipeGesture.direction = (UISwipeGestureRecognizerDirectionLeft);
    rightSwipeGesture.direction = (UISwipeGestureRecognizerDirectionRight);
    // Just one finger, I'm nice
    leftSwipeGesture.numberOfTouchesRequired = 1;
    rightSwipeGesture.numberOfTouchesRequired = 1;
    // Add them gesture recognizers to the tableView.
    [self.tableView addGestureRecognizer:leftSwipeGesture];
    [self.tableView addGestureRecognizer:rightSwipeGesture];
}


#pragma mark NSNotificationCenter Notification selectors
// Not sure *why* this is necessary, but the segement control
// In the header would NOT resize correctly without reloading
// the data, so, here we are. Listening to the orienation notification.
- (void)orientationChanged:(NSNotification *)notification
{
    if ([self.searchDisplayController isActive]) {
        [self.searchDisplayController.searchResultsTableView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark Implementation

- (void)setNavigationBarTint
{
    // If they're open, navigiation tint gets a different color than if they're closed.
    if ([DMHelperMethods checkIfOpen]) {
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

- (void)loadBeers
{
    // If we're refreshing and we're showing on tap.
    // clear out the highlighted beers that have been marked as 'unseen' or 'new'
    if (self.refreshControl.refreshing && self.headerSegmentControl.selectedSegmentIndex == SHOW_ON_TAP) {
        [self resetHighlightedBeers];
    }
    // if we're spinnin' and refreshin'
    // ... stop it.
    if (self.refreshControl.refreshing) {
        // Setup Title
        NSString *str = [NSString stringWithFormat:@"Last Updated at %@", [_dateFormatter stringFromDate:[NSDate date]]];
        NSAttributedString *attrStr;
        // if iOS7, font color matches tint color.
        // not needed to check anymore, iOS 7 only.
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
    
    /* I could probably abstract self.selected store out and use NSUserDefaults for all of it
        But i don't know if thats bad reliability wise
        And i also would have to implement a delegate methods for for the actionSheet delegate
        to tell my TableViewController that the selected store changed.
        Not sure which I feel is a more elegant solution.
     */
    // forStore is ignored when SERVER_FLAG is set to all, but if its not I need it.
    [[DMGrowlerAPI sharedInstance] getBeersWithFlag:action forStore:self.selectedStore andSuccess:^(id JSON) {
        self.beers = JSON;
        if (action == ON_TAP) {
            // If we're looking at the current tap list, lets see if any are new since we last saw.
            [self checkForNewBeers];
        }
        // Check if we're currently searching the list.
        // Because if we are and I just reload the tableView.
        // It goes boom.
        if ([self.searchDisplayController isActive]) {
            [self updateFilteredContentForSearchString:self.searchDisplayController.searchBar.text];
            [self.searchDisplayController.searchResultsTableView reloadData];
        } else {
            [self.tableView reloadData];
        }
    } andFailure:^(id JSON) {
        // Should probably do some real error handling like an alert or view to say
        // no network or call failed but for now we'll just log it out.
        NSLog(@"Error - %@", JSON);
    }];
}

- (void)loadFavorites
{
    NSArray *favorites = [_coreData getAllFavorites];
    if (favorites.count > 0) {
        self.beers = favorites;
    } else {
        self.beers = @[@{@"name": @"No Favorites!", @"brewer": @"Go Favorite some Beers!",
                         @"ibu": @"", @"abv": @"",
                         @"city": @"", @"state": @""}
                       ];
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

- (void)resetHighlightedBeers
{
    [_highlightedBeers removeAllObjects];
    [_coreData resetBeerDatabase:self.beers];
}

// I'm lazy.
- (UIColor *)growlersYellowColor:(GROWLERS_YELLOW_ALPHA)alpha
{
    if (alpha == ALPHA_NEW_BEER) {
        return [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:0.125];
    } else {
        return [UIColor colorWithRed:238.0/255.0 green:221.0/255.0 blue:68.0/255.0 alpha:0.85];
    }
}

#pragma mark Table View Data Source

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
    cell.beerName.adjustsFontSizeToFitWidth = YES;
    cell.brewery.adjustsFontSizeToFitWidth = YES;
    cell.beerInfo.adjustsFontSizeToFitWidth = YES;
    
    // Get which beer I'm searching for.
    NSDictionary *beer;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        beer = self.filteredBeers[indexPath.row];
    } else {
        beer = self.beers[indexPath.row];
    }
    
    NSLog(@"beer ----- %@", beer);
    
    // Configure the cell...
    switch (self.headerSegmentControl.selectedSegmentIndex) {
            // If we're showing on tap, show prices.
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
    
    cell.brewery.text  = [NSString stringWithFormat:@"%@ in %@, %@", beer[@"brewer"], beer[@"city"], beer[@"state"]];

    // Get ID and check for today == tap.id and highlight
    // OR if the last day of month, all tap_ids >= day number
    // are on sale.
    // And that gives us this horrible if statement.
    if (self.headerSegmentControl.selectedSegmentIndex == SHOW_ON_TAP &&
        ([DMHelperMethods checkToday:beer[@"tap_id"]] ||
         ([DMHelperMethods checkLastDateOfMonth] && [beer[@"tap_id"] intValue] >= [DMHelperMethods getToday] )
         )
        )
    {
        cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
        cell.beerName.textColor = [UIColor whiteColor];
        cell.brewery.textColor = [UIColor whiteColor];
        cell.beerInfo.textColor = [UIColor lightTextColor];
    } else if ([_highlightedBeers containsObject:beer]) {
        // Beer is in our 'new beers' list so we should highlight it.
        cell.backgroundColor = [self growlersYellowColor:ALPHA_NEW_BEER];
        cell.beerName.textColor = [UIColor blackColor];
        cell.brewery.textColor = [UIColor blackColor];
        cell.beerInfo.textColor = [UIColor darkGrayColor];
    } else {
        // If I don't set them back explicitly, after scrolling weird stuff happens.
        cell.backgroundColor = [UIColor whiteColor];
        cell.beerName.textColor = [UIColor blackColor];
        cell.brewery.textColor = [UIColor blackColor];
        cell.beerInfo.textColor = [UIColor darkGrayColor];
    }
    
    // check if beer is favorite
    // If it is it gets a yellow dot.
    if ([_coreData isBeerFavorited:beer]) {
        cell.favoriteMarker.backgroundColor = [self growlersYellowColor:ALPHA_BEER_FAVORITES];
    } else {
        cell.favoriteMarker.backgroundColor = [UIColor clearColor];
    }
    // square dots aren't dots... they're squares.
    cell.favoriteMarker.layer.masksToBounds = YES;
    cell.favoriteMarker.layer.cornerRadius = cell.favoriteMarker.bounds.size.width / 2.0;

    // finally done.
    return cell;
}

#pragma mark Table View Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 34.0f)];
    headerView.backgroundColor = [UIColor clearColor];
    self.headerSegmentControl.frame = CGRectInset(headerView.frame, 12, 4);
    self.headerSegmentControl.backgroundColor = [UIColor colorWithWhite:1 alpha:0.85];
    [headerView addSubview:self.headerSegmentControl];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // This was necessary apparently. Set it in the story board but it wouldn't actually stick
    // until I set it here.
    return 34.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Same reason as the heightForHeaderInSection
    return 64.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // again, get our beer from where ever the user is seeing it.
    NSDictionary *beer;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        beer = self.filteredBeers[indexPath.row];
    } else {
        beer = self.beers[indexPath.row];
    }
    
    // If we're trying to favorite my message to favorite beers
    // No no.
    if ([beer[@"name"] isEqualToString:@"No Favorites!"] && [beer[@"brewer"] isEqualToString:@"Go Favorite some Beers!"]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    NSString *token = [DMDefaultsInterfaceConstants pushID];
    
    NSString *preferredStore = [[DMDefaultsInterfaceConstants preferredStore] lowercaseString];
    
    NSMutableDictionary *beerToFavorite = [@{@"name": beer[@"name"],
                                            @"brewer": beer[@"brewer"],
                                            @"udid": (token ? token : [DMDefaultsInterfaceConstants generatedUDID]),
                                            @"store": preferredStore}
                                           mutableCopy];
    

    if ([_coreData isBeerFavorited:beer]) {
        // Selected beer is a favorite so we want to tell the server
        // we want to unfavorite it. So lets put that in our dictionary we send
        [beerToFavorite setValue:@NO forKey:@"fav"];
        [[DMGrowlerAPI sharedInstance] favoriteBeer:beerToFavorite withAction:UNFAVORITE withSuccess:^(id JSON) {
            // CoreData Save
            NSMutableDictionary *favBeer = [beer mutableCopy];
            favBeer[@"store"] = preferredStore;
            [_coreData unFavoriteBeer:favBeer];
            DMGrowlerTableViewCell *cell = (DMGrowlerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.favoriteMarker.backgroundColor = [UIColor clearColor];
        } andFailure:^(id JSON) {
            // Handle failure
            NSLog(@"unfavoriting failed: %@", JSON);
        }];
    }
    else {
        // Beer isn't a favorite so let's tell the server we would like to
        // favorite it.
        [beerToFavorite setValue:@YES forKey:@"fav"];
        [[DMGrowlerAPI sharedInstance] favoriteBeer:beerToFavorite withAction:FAVORITE withSuccess:^(id JSON) {
            // CoreData save
            NSMutableDictionary *favBeer = [beer mutableCopy];
            favBeer[@"store"] = preferredStore;
            [_coreData favoriteBeer:favBeer];
            DMGrowlerTableViewCell *cell = (DMGrowlerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.favoriteMarker.backgroundColor = [self growlersYellowColor:ALPHA_BEER_FAVORITES];
        } andFailure:^(id JSON) {
            // Handle failure
            // But for now, just log.
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
    // Make a mutable copy of the beer list.
    // I'll just use the one I have
    self.filteredBeers = [self.beers mutableCopy];
    // Trim off whitespace
    NSString *strippedSearch = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    // See if beer name or beer brewer contains the search string via a case insensitive search.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@ OR %K contains[cd] %@", @"name", strippedSearch, @"brewer", strippedSearch];
    
    // Set my mutableArray to itself applying the filter.
    self.filteredBeers = [[self.filteredBeers filteredArrayUsingPredicate:predicate] mutableCopy];
}

#pragma mark UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateFilteredContentForSearchString:searchString];
    return YES;
}

/*
 These are only implemented because for whatever reason in iOS 7
 the header segment control kept disappearing until I reloaded the tableView data
 So this just forces that to happen upon searching or cancelling.
 Only here to be a fix for a weird iOS7 bug.
 */
#pragma mark UISearchBarDelegate
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
        [DMDefaultsInterfaceConstants setLastStore:self.selectedStore];
        [self loadBeers];
        [self setNavigationBarPrompt];
    }
}

#pragma mark Bar Button Items

- (void)settings:(id)sender
{
    DMSettingsTableViewController *settingsView = [self.storyboard instantiateViewControllerWithIdentifier:@"DMSettingsTableViewController"];
    [self.navigationController pushViewController:settingsView animated:YES];
}

- (void)showActionSheet:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:Nil
                                                    otherButtonTitles:nil];
    
    for (NSString *store in [DMDefaultsInterfaceConstants stores]) {
        [actionSheet addButtonWithTitle:store];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = [DMDefaultsInterfaceConstants stores].count;
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

#pragma mark Navigation Bar Stuff
// convenient way to remove the navigatinoBar prompt entirely.
// Purely a convience method
- (void)clearNavigationBarPrompt
{
    self.navigationItem.prompt = nil;
}
// Set the prompt the last selected store.
// Set to nil to remove.
- (void)setNavigationBarPrompt
{
    self.navigationItem.prompt = [DMDefaultsInterfaceConstants lastStore];
}

#pragma mark Segment Control and Gestures Delegate

/* Handle Segmented Control change */
- (void)segmentedControlChanged:(UISegmentedControl *)sender
{
    [self clearNavigationBarPrompt];
    switch (sender.selectedSegmentIndex) {
        case SHOW_ON_TAP: // on tap
            [self setNavigationBarPrompt];
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

- (void)handleSwipe:(UISwipeGestureRecognizer *)recognizer
{
    // Handle left swipe, move selected segement right
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        // Make sure we're not as far right as we can go.
        if (self.headerSegmentControl.selectedSegmentIndex < self.headerSegmentControl.numberOfSegments - 1) {
            self.headerSegmentControl.selectedSegmentIndex++;
            [self segmentedControlChanged:self.headerSegmentControl];
        } else return;
    }
    // Do the opposite of above, move it to the left.
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        // Make sure we can even go to the left.
        if (self.headerSegmentControl.selectedSegmentIndex > 0) {
            self.headerSegmentControl.selectedSegmentIndex--;
            [self segmentedControlChanged:self.headerSegmentControl];
        } else return;
    }
}

# pragma mark UIScrollViewDelegate
// Only implementing this so I can dynamically hide stuff from the top of the
// Table view when i scroll away/back to top.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = self.tableView.sectionHeaderHeight;

    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {
        if (self.headerSegmentControl.selectedSegmentIndex == SHOW_ON_TAP)
            [self setNavigationBarPrompt];
        else
            [self clearNavigationBarPrompt];
    } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
        [self clearNavigationBarPrompt];
    }
}


@end
