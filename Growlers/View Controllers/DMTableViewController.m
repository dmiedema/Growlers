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
@property (nonatomic, strong) NSMutableSet *highlightedBeers;
@property (nonatomic, strong) NSString *selectedStore;
@property (nonatomic, strong) DMCoreDataMethods *coreData;

@property (nonatomic, strong) UIImageView *logoImageView;

@property (nonatomic, strong) UISegmentedControl *headerSegmentControl;
@property (nonatomic, strong) UIGestureRecognizer *swipeGesture;

// Private methods
- (void)loadBeers;
- (void)loadFavorites;

- (void)settings:(id)sender;
- (void)showActionSheet:(id)sender;

- (void)resetHighlightedBeers;
- (void)setNavigationBarTint;

- (void)setNavigationBarPrompt;

// Private enums
typedef enum {
    ShowOnTap = 0,
    ShowFavorites = 1,
    ShowFullHistory = 2
} SegmentControlIndex;

@end

@implementation DMTableViewController

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
    self.selectedStore = [DMDefaultsInterfaceConstants lastStore] ?
        [DMDefaultsInterfaceConstants lastStore] : [DMDefaultsInterfaceConstants stores][0];
    
    // Load up my .xib 
    [self.tableView registerNib:[UINib nibWithNibName:@"DMGrowlerTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"growlerCell"];
    // Load up .xib for search results table view
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"DMGrowlerTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"growlerCell"];

    // Static logo image behind table view -- makes things really hard to read.
//    _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"launch-Image"]];
//    self.tableView.backgroundView = _logoImageView;
    
    // Setup Navigation Bar button Items
    UIBarButtonItem *info = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settings:)];
    UIBarButtonItem *storeButton = [[UIBarButtonItem alloc] initWithTitle:@"Store" style:UIBarButtonItemStyleBordered target:self action:@selector(showActionSheet:)];
    
    self.navigationItem.leftBarButtonItem = info;
    // If multiple stores -- show store button
    if([DMDefaultsInterfaceConstants multipleStoresEnabled])
        self.navigationItem.rightBarButtonItem = storeButton;
    
    self.filteredBeers = [NSMutableArray new];
    _highlightedBeers = [NSMutableSet new];
    
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
    // Set the tint color
    [self setNavigationBarTint];
    
    if (![DMDefaultsInterfaceConstants favoritesEverReconciled]) {
        NSLog(@"RECONCILING!!!!");
        [[DMGrowlerNetworkModel manager] getBeersForStore:@"all" withSuccess:^(id JSON) {
            DMCoreDataMethods *coreData = [[DMCoreDataMethods alloc] initWithManagedObjectContext:self.managedContext];
            [coreData reconcileFavoritesWithServer:JSON];
        } andFailure:^(id JSON) {
            NSLog(@"Failure Getting all beers");
        }];
    }
    
    [[DMGrowlerNetworkModel manager] resetBadgeCount];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
//    if (self.refreshControl.refreshing && self.headerSegmentControl.selectedSegmentIndex == ShowOnTap) {
//        [self resetHighlightedBeers];
//    }
    
    // Set the tine when I go to load beers
    [self setNavigationBarTint];
    // if we're spinnin' and refreshin'
    // ... stop it.
    if (self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
        if (self.headerSegmentControl.selectedSegmentIndex == ShowOnTap) [self resetHighlightedBeers];
    }
    
    // if we're on favorites, we shouldn't be here. Bail.
    if (self.headerSegmentControl.selectedSegmentIndex == ShowFavorites) {
        [self loadFavorites];
        return;
    }
    
    // check segment control to see what action I should perform
    NSString *store =
        (self.headerSegmentControl.selectedSegmentIndex == ShowOnTap)
        ? [self.selectedStore lowercaseString]
        : @"all";
    
    /* I could probably abstract self.selected store out and use NSUserDefaults for all of it
        But i don't know if thats bad reliability wise
        And i also would have to implement a delegate methods for for the actionSheet delegate
        to tell my TableViewController that the selected store changed.
        Not sure which I feel is a more elegant solution.
     */
    
    [[DMGrowlerNetworkModel manager] getBeersForStore:store withSuccess:^(id JSON) {
        self.beers = [DMHelperMethods sanitzedBeerInformation:JSON];
        if (self.headerSegmentControl.selectedSegmentIndex == ShowOnTap) {
             // If we're looking at the current tap list, lets see if any are new since we last saw.
            [self checkForNewBeers];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *top = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
            });
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
        // If favorites is empty, show a little message to let
        // the user know to go favorite some beers.
        self.beers = @[@{@"name": @"No Favorites!", @"brewer": @"Go Favorite some Beers!",
                         @"ibu": @"", @"abv": @"",
                         @"city": @"", @"state": @"", @"beer_style": @""}
                       ];
    }
    if ([self.searchDisplayController isActive]) {
        [self updateFilteredContentForSearchString:self.searchDisplayController.searchBar.text];
        [self.searchDisplayController.searchResultsTableView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

// This could just return an array of new beers
// and I could just set _highlightedBeers to that.
// But for now, I'll just do it this way.
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

    // Configure the cell...
    char *beerNameText; // c strings
    char *beerInfoText;
    
    NSString *tapId, *beername, *ibu, *abv, *growlerPrice, *growlettePrice, *style;
    tapId           = (ObjectOrNull(beer[@"tap_id"]))     ?: @" ";
    beername        = (ObjectOrNull(beer[@"name"]))       ?: @" ";
    ibu             = (ObjectOrNull(beer[@"ibu"]))        ?: @" ";
    abv             = (ObjectOrNull(beer[@"abv"]))        ?: @" ";
    growlerPrice    = (ObjectOrNull(beer[@"growler"]))    ?: @" ";
    growlettePrice  = (ObjectOrNull(beer[@"growlette"]))  ?: @" ";
    style           = (ObjectOrNull(beer[@"beer_style"])) ?: @" ";
    
    
    switch (self.headerSegmentControl.selectedSegmentIndex) {
            // If we're showing on tap, show prices.
        case ShowOnTap:
            asprintf(&beerNameText, "%s. %s", [tapId UTF8String], [beername UTF8String]);
            asprintf(&beerInfoText, "IBU: %s  ABV: %s  Growler: $%s  Growlette: $%s", 
                [ibu UTF8String], [abv UTF8String], [growlerPrice UTF8String], [growlettePrice UTF8String]);
            break;
        default:
            asprintf(&beerNameText, "%s", [beername UTF8String]);
            asprintf(&beerInfoText, "IBU: %s  ABV: %s  Style: %s", [ibu UTF8String], [abv UTF8String], [style UTF8String]);
    
            break;
    }
    cell.beerName.text = [NSString stringWithCString:beerNameText encoding:NSUTF8StringEncoding];
    cell.beerInfo.text = [NSString stringWithCString:beerInfoText encoding:NSUTF8StringEncoding];
    free(beerNameText);
    free(beerInfoText);
    // Get city and state as strings for string based operations
    NSString *city = ObjectOrNull(beer[@"city"]) ?: @" ";
    NSString *state = ObjectOrNull(beer[@"state"]) ?: @" ";
    NSString *brewerString = ObjectOrNull(beer[@"brewer"]) ?: @" ";
    // Make sure they exist (length > 0), if they don't
    // Show different text.
    if (city.length > 1 && state.length > 1) {
        // Create inital string that will not be italicized.
        // Need it to be mutableAttributedString so I can append to it though
        NSMutableAttributedString *brewer = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - ", brewerString]];
        // Create city & state string with italic font
        UIFontDescriptor *fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
        fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
        
        NSMutableAttributedString *cityState = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, %@", city, state] attributes:@{NSFontAttributeName: [UIFont fontWithDescriptor:fontDescriptor size:0.0]}];
        // put em together
        [brewer appendAttributedString:cityState];
        // set attribured text.
        cell.brewery.attributedText = brewer;
        
        brewer = nil;
        cityState = nil;
        fontDescriptor = nil;
        cityState = nil;
    } else {
        cell.brewery.text  = brewerString;
    }
    
    // Get ID and check for today == tap.id and highlight
    // Make sure we're looking at Keizer too
    // OR if the last day of month, all tap_ids >= day number
    // are on sale.
    // And that gives us this horrible if statement.
    if (self.headerSegmentControl.selectedSegmentIndex == ShowOnTap &&
        [self.selectedStore isEqualToString:@"Keizer"] && // "Keizer" is only store that gets this perk.
        ([DMHelperMethods checkToday:tapId] ||
         ([DMHelperMethods checkLastDateOfMonth] && [tapId integerValue] >= [DMHelperMethods getToday] )
         )
        )
    { // We're looking at keizer AND this tap is the special today
        cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
        cell.beerName.textColor = [UIColor whiteColor];
        cell.brewery.textColor = [UIColor whiteColor];
        cell.beerInfo.textColor = [UIColor lightTextColor];
    } else if ([_highlightedBeers containsObject:beer]) {
        // Beer is in our 'new beers' list so we should highlight it.
        cell.backgroundColor = [DMHelperMethods growlersYellowColor:AlphaNewBeer];
        cell.beerName.textColor = [UIColor blackColor];
        cell.brewery.textColor = [UIColor blackColor];
        cell.beerInfo.textColor = [UIColor darkGrayColor];
    } else {
        // If I don't set them back explicitly, after scrolling weird stuff happens.
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.80];
        cell.beerName.textColor = [UIColor blackColor];
        cell.brewery.textColor = [UIColor blackColor];
        cell.beerInfo.textColor = [UIColor darkGrayColor];
    }
    
    // check if beer is favorite
    // If it is it layer opacity is set to 1
    if ([_coreData isBeerFavorited:beer]) {
        [cell.favoriteMarker.layer setOpacity:1.0];
    } else {
        [cell.favoriteMarker.layer setOpacity:0.0];
    }
    // Set background to the yellow I want
    cell.favoriteMarker.backgroundColor = [DMHelperMethods growlersYellowColor:AlphaBeerFavorites];
    // square dots aren't dots... they're squares.
    cell.favoriteMarker.layer.masksToBounds = YES;
    cell.favoriteMarker.layer.cornerRadius = cell.favoriteMarker.bounds.size.width / 2.0;

    // finally done.
    beer = nil; city = nil; state = nil;
    return cell;
}

#pragma mark Table View Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 34.0f)];
//    headerView.backgroundColor = [UIColor clearColor];
    self.headerSegmentControl.frame = CGRectInset(headerView.frame, 12, 4);
    headerView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.85];
    [headerView addSubview:self.headerSegmentControl];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // This was necessary apparently. Set it in the story board but it wouldn't
    // actually stick until I set it here.
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
    
    NSString *token = [DMDefaultsInterfaceConstants getValidUniqueID];
    
    NSString *preferredStore = [[DMDefaultsInterfaceConstants preferredStore] lowercaseString];
    NSArray *preferredStores = [DMDefaultsInterfaceConstants preferredStores];
    NSString *style = (beer[@"beer_style"] == [NSNull null]) ? @"" : beer[@"beer_style"];

    NSMutableDictionary *beerToFavorite = [@{@"name": beer[@"name"],
                                            @"brewer": beer[@"brewer"],
                                            @"udid": token,
                                            @"store": preferredStores,
                                            @"beer_style": style}
                                           mutableCopy];

    if ([_coreData isBeerFavorited:beer]) {
        // Selected beer is a favorite so we want to tell the server
        // we want to unfavorite it. So lets put that in our dictionary we send
        [beerToFavorite setValue:@NO forKey:@"fav"];
        [[DMGrowlerNetworkModel manager] unFavoriteBeer:beerToFavorite withSuccess:^(id JSON) {
            NSLog(@"Beer UNFavorited");
            // CoreData save
            NSMutableDictionary *favBeer = [beer mutableCopy];
            favBeer[@"store"] = preferredStore;
            [_coreData unFavoriteBeer:favBeer];
            DMGrowlerTableViewCell *cell = (DMGrowlerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            [DMHelperMethods animateOpacityForLayer:cell.favoriteMarker.layer to:[NSNumber numberWithFloat:0.0] from:[NSNumber numberWithFloat:1.0] duration:[NSNumber numberWithFloat:0.25]];
        } andFailure:^(id JSON) {
            // should handle it but i'll just log for now
            NSLog(@"unfavoriting failed: %@", JSON);
        }];
    }
    else {
        // Beer isn't a favorite so let's tell the server we would like to
        // favorite it.
        [beerToFavorite setValue:@YES forKey:@"fav"];
        [[DMGrowlerNetworkModel manager] favoriteBeer:beerToFavorite withSuccess:^(id JSON) {
            NSLog(@"Beer Favorited");
            // CoreData save
            NSMutableDictionary *favBeer = [beer mutableCopy];
            favBeer[@"store"] = preferredStore;
            [_coreData favoriteBeer:favBeer];
            DMGrowlerTableViewCell *cell = (DMGrowlerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            
            [DMHelperMethods animateOpacityForLayer:cell.favoriteMarker.layer to:[NSNumber numberWithFloat:1.0] from:[NSNumber numberWithFloat:0.0] duration:[NSNumber numberWithFloat:0.25]];
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@ OR %K contains[cd] %@ OR %K contains[cd] %@", @"name", strippedSearch, @"brewer", strippedSearch, @"beer_style", strippedSearch];
    
    // Set my mutableArray to itself applying the filter.
    self.filteredBeers = [[self.filteredBeers filteredArrayUsingPredicate:predicate] mutableCopy];
}

#pragma mark UISearchDisplayDelegate

// allows for live filtering list as user types.
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
    [self loadBeers];
}

#pragma mark UIActionSheet
/*
 This could be abstracted out and the delegate could
 be put into a seperate class and it could send
 out a message to a protocol to this ViewController
 So that it knows to change stuff
 When an index is pressed.
 */
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
    // When I tried to alloc, init this without instantiating from Storyboard
    // it crashed. So I'll just do it this way I guess.
    DMSettingsTableViewController *settingsView = [self.storyboard instantiateViewControllerWithIdentifier:@"DMSettingsTableViewController"];
    settingsView.managedContext = self.managedContext;
    [self.navigationController pushViewController:settingsView animated:YES];
}

- (void)showActionSheet:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:Nil
                                                    otherButtonTitles:nil];
    
    // Dynamically build up my stores list
    for (NSString *store in [DMDefaultsInterfaceConstants stores]) {
        [actionSheet addButtonWithTitle:store];
    }
    // Don't forget the cancel button
    [actionSheet addButtonWithTitle:@"Cancel"];
    // Its like magic, gotta love 0 index
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
    self.navigationItem.prompt =
    ([DMDefaultsInterfaceConstants showCurrentStoreOnTapList])
        ? [DMDefaultsInterfaceConstants lastStore]
        : nil;
}

#pragma mark Segment Control and Gestures Delegate

/* Handle Segmented Control change */
- (void)segmentedControlChanged:(UISegmentedControl *)sender
{
    [self clearNavigationBarPrompt];
    [[DMGrowlerNetworkModel manager] cancelAllGETs];
    switch (sender.selectedSegmentIndex) {
        case ShowOnTap: // on tap
            [self setNavigationBarPrompt];
            [self loadBeers];
            break;
        case ShowFavorites: // favorites
            [self loadFavorites];
            break;
        case ShowFullHistory: // All
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
        if (self.headerSegmentControl.selectedSegmentIndex == ShowOnTap)
            [self setNavigationBarPrompt];
        else
            [self clearNavigationBarPrompt];
    } else if (scrollView.contentOffset.y >= sectionHeaderHeight) {
        [self clearNavigationBarPrompt];
    }
}


@end
