//
//  DMCoreDataMethods.m
//  Growlers
//
//  Created by Daniel Miedema on 8/10/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMCoreDataMethods.h"

@implementation DMCoreDataMethods

#pragma mark Custom Init
- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (!self) { return nil; }
    
    self.managedContext = context;
    return self;
}

#pragma mark On Tap
- (BOOL)checkForBeerInDatabase:(NSDictionary *)beer
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Beer"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@ and brewer = %@", beer[@"name"], beer[@"brewer"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [self.managedContext executeFetchRequest:request error:&error];
    
    return matches.count == 1;
}

- (NSArray *)getAllBeersInDatabase
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Beer"];
    request.includesPropertyValues = YES;
    
    NSError *error = nil;
    NSArray *results = [self.managedContext executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return nil;
    }
    return results;
}

- (void)resetBeerDatabase:(NSArray *)newDatabaseContents
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Beer"];
    request.includesPropertyValues = NO;
    
    NSError *error = nil;
    NSArray *allCurrentBeers = [self.managedContext executeFetchRequest:request error:&error];
    
    NSLog(@"Removing Beer Database...");
    NSLog(@"AllBeers - %@", allCurrentBeers);
    if (allCurrentBeers.count > 0) {
        for (NSManagedObject *beer in allCurrentBeers) {
            [self.managedContext deleteObject:beer];
        }
        if(![self.managedContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    
    NSLog(@"All Current Beers removed");
    
    for (NSDictionary *beer in newDatabaseContents) {
        NSLog(@"Creating new entry - %@", beer);
        Beer *newBeer = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:self.managedContext];

        newBeer.tap_id          = [NSNumber numberWithInt:[beer[@"tap_id"] intValue]];
        newBeer.abv             = beer[@"abv"];
        newBeer.brewer          = beer[@"brewer"];
        newBeer.brewerURL       = beer[@"brew_url"];
        newBeer.growlerPrice    = beer[@"growler"];
        newBeer.growlettePrice  = beer[@"growlette"];
        newBeer.ibu             = beer[@"ibu"];
        newBeer.name            = beer[@"name"];
        newBeer.style           = beer[@"style"];
        newBeer.store           = beer[@"store"];
        
        NSLog(@"New Beer - %@", newBeer);
    }
    
    NSLog(@"Saving New Database...");
    if (![self.managedContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    NSLog(@"New Database saved.");
}


#pragma mark Favoriting
- (void)favoriteBeer:(NSDictionary *)newBeerToFavorite
{
    Favorites *favorite = [NSEntityDescription insertNewObjectForEntityForName:@"Favorites" inManagedObjectContext:self.managedContext];
    favorite.tap_id     = [NSNumber numberWithInt:[newBeerToFavorite[@"tap_id"] intValue]];
    favorite.name       = newBeerToFavorite[@"name"];
    favorite.brewer     = newBeerToFavorite[@"brewer"];
    favorite.abv        = (newBeerToFavorite[@"abv"] == [NSNull null]) ? @"" : newBeerToFavorite[@"abv"];
    favorite.ibu        = (newBeerToFavorite[@"ibu"] == [NSNull null]) ? @"" : newBeerToFavorite[@"ibu"];
    favorite.brewerURL  = (newBeerToFavorite[@"brew_url"]  == [NSNull null]) ? @"" : newBeerToFavorite[@"brew_url"];
    favorite.store      = newBeerToFavorite[@"store"];
    
    NSError *coreDataErr = nil;
    if (![self.managedContext save:&coreDataErr]) {
        // handle error
    }
    NSLog(@"Beer Saved");
}

- (void)unFavoriteBeer:(NSDictionary *)beerToUnfavorite
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Favorites"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@ and brewer = %@ and store = %@", beerToUnfavorite[@"name"], beerToUnfavorite[@"brewer"], beerToUnfavorite[@"store"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [self.managedContext executeFetchRequest:request error:&error];
    
//    NSLog(@"Matches - %@", matches);
//    NSLog(@"Matches Lastobject - %@", matches.lastObject);
    
    [self.managedContext deleteObject:matches.lastObject];
    if (![self.managedContext save:&error]){
        // handle error
    }
    NSLog(@"Beer Unfavorited");
}

- (BOOL)isBeerFavorited:(NSDictionary *)beer
{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Favorites"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@ and brewer = %@ and store = %@", beer[@"name"], beer[@"brewer"], beer[@"store"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [self.managedContext executeFetchRequest:request error:&error];
    
    return matches.count == 1;
}
- (NSArray *)getAllFavorites
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Favorites"];
    request.includesPropertyValues = YES;
    
    NSError *error = nil;
    NSArray *allFavorites = [self.managedContext executeFetchRequest:request error:&error];
    
    NSMutableArray *favoritesAsDictionarys = [NSMutableArray new];
    
    for (Favorites *favorite in allFavorites) {
        [favoritesAsDictionarys addObject:
         @{@"tap_id": favorite.tap_id,
           @"name": favorite.name,
           @"brewer": favorite.brewer,
           @"brew_url": favorite.brewerURL,
           @"abv": favorite.abv,
           @"ibu": favorite.ibu,
           @"store": favorite.store
           }];
    }
//    NSLog(@"Favorites as dictionaries %@", favoritesAsDictionarys);
    
    return favoritesAsDictionarys;
}

@end
