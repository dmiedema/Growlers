//
//  DMTableViewController.h
//  Growlers
//
//  Created by Daniel Miedema on 7/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMGrowlerAPI.h"
#import "CoreDataTableViewController.h"

@interface DMTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>
//@property (nonatomic, strong) UIManagedDocument *favoritesDatabase;
//@property (nonatomic, strong) UIManagedDocument *beerDatabase;

//@property (nonatomic, strong) NSFetchedResultsController *favoritesFetchedResultsController;
//@property (nonatomic, strong) NSFetchedResultsController *beerFetchedResultsController;

@property (nonatomic, strong) NSManagedObjectContext *managedContext;
//@property (nonatomic, strong) NSManagedObjectModel *managedModel;

- (void)favoriteBeer:(NSDictionary *)newBeerToFavorite;
- (void)unFavoriteBeer:(NSDictionary *)beerToUnfavorite;
@end
