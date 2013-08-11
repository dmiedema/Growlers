//
//  DMCoreDataMethods.h
//  Growlers
//
//  Created by Daniel Miedema on 8/10/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Beer.h"
#import "Favorites.h"

@interface DMCoreDataMethods : NSObject
@property (nonatomic, strong) NSManagedObjectContext *managedContext;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)context;

- (BOOL)checkForBeerInDatabase:(NSDictionary *)beer;
- (NSArray *)getAllBeersInDatabase;
- (void)resetBeerDatabase:(NSArray *)newDatabaseContents;

- (void)favoriteBeer:(NSDictionary *)newBeerToFavorite;
- (void)unFavoriteBeer:(NSDictionary *)beerToUnfavorite;
- (BOOL)isBeerFavorited:(NSDictionary *)beer;
- (NSArray *)getAllFavorites;
@end
