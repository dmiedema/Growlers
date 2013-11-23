//
//  DMCoreDataMethods.m
//  Growlers
//
//  Created by Daniel Miedema on 8/10/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMCoreDataMethods.h"

@interface DMCoreDataMethods ()
- (id)applyDefaultValuesToEntityObject:(id)entityObject withParameters:(NSDictionary *)params;
@end

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

    if (allCurrentBeers.count > 0) {
        for (NSManagedObject *beer in allCurrentBeers) {
            [self.managedContext deleteObject:beer];
        }
        if(![self.managedContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    
    for (NSDictionary *beer in newDatabaseContents) {
        Beer *newBeer = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:self.managedContext];

        newBeer = [self applyDefaultValuesToEntityObject:newBeer withParameters:beer];
    }
    if (![self.managedContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}


#pragma mark Favoriting
- (void)favoriteBeer:(NSDictionary *)newBeerToFavorite
{
    Favorites *favorite = [NSEntityDescription insertNewObjectForEntityForName:@"Favorites" inManagedObjectContext:self.managedContext];
    favorite = [self applyDefaultValuesToEntityObject:favorite withParameters:newBeerToFavorite];
    
    NSError *coreDataErr = nil;
    if (![self.managedContext save:&coreDataErr]) {
        // handle error
    }
}

- (void)unFavoriteBeer:(NSDictionary *)beerToUnfavorite
{
    NSLog(@"unfavorite - %@", beerToUnfavorite);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Favorites"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@ and brewer = %@", beerToUnfavorite[@"name"], beerToUnfavorite[@"brewer"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [self.managedContext executeFetchRequest:request error:&error];
    
    [self.managedContext deleteObject:matches.lastObject];
    if (![self.managedContext save:&error]){
        // handle error
    }
}

- (BOOL)isBeerFavorited:(NSDictionary *)beer
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Favorites"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@ and brewer = %@", beer[@"name"], beer[@"brewer"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [self.managedContext executeFetchRequest:request error:&error];
    if (matches) {
        return matches.count >= 1;
    } else
        return NO;
}

- (NSArray *)getAllFavorites
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Favorites"];
    request.includesPropertyValues = YES;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.resultType = NSDictionaryResultType;
    
    NSError *error = nil;
    NSArray *allFavorites = [self.managedContext executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"Error - %@", error);
        return nil;
    }
    return allFavorites;
}

- (void)reconcileFavoritesWithServer:(NSArray *)allBeers
{
    NSLog(@"Reconsiling...");
    NSArray *allFavorites = [self getAllFavorites];
    NSLog(@"All favorites - %@", allFavorites);
    for (NSDictionary *beer in allFavorites) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@ and brewer contains[cd] %@", beer[@"name"], beer[@"brewer"]];
        NSArray *filteredAllBeers = [allBeers filteredArrayUsingPredicate:predicate];
        NSLog(@"Results after predicate search\n%@", filteredAllBeers);
        if (filteredAllBeers.count == 1) {
            NSLog(@"Count of results was 1\nUnfavoriting & Favoriting");
            [self unFavoriteBeer:beer];
            [self favoriteBeer:[filteredAllBeers lastObject]];
        } else {
            NSLog(@"Count was not == 1");
            NSLog(@"Results -\n%@", filteredAllBeers);
        }
        //[self unFavoriteBeer:beer];
        // remove the default -- pretend beer
        [self unFavoriteBeer:@{@"name": @"No Favorites!", @"brewer": @"Go Favorite some Beers!"}];
    } // end for
}

#pragma mark Private Methods

- (id)applyDefaultValuesToEntityObject:(id)entityObject withParameters:(NSDictionary *)params
{
    NSNumber *tapID = (params[@"tap_id"] == [NSNull null]) ? 0 : [NSNumber numberWithInt:[params[@"tap_id"] intValue]];
    NSString *abv = (params[@"abv"] == [NSNull null]) ? @"" : params[@"abv"];
    NSString *ibu = (params[@"ibu"] == [NSNull null]) ? @"" : params[@"ibu"];
    NSString *brewerURL = (params[@"brew_url"]  == [NSNull null]) ? @"" : params[@"brew_url"];
    NSString *city = (params[@"city"] == [NSNull null]) ? @"" : params[@"city"];
    NSString *state = (params[@"state"] == [NSNull null]) ? @"" : params[@"state"];
    NSString *style = (params[@"beer_style"] == [NSNull null]) ? @"" : params[@"beer_style"];
    
    [entityObject setTap_id:tapID];
    [entityObject setName:params[@"name"]];
    [entityObject setBrewer:params[@"brewer"]];
    [entityObject setAbv:abv];
    [entityObject setIbu:ibu];
    [entityObject setBrewerURL:brewerURL];
    [entityObject setStore:params[@"store"]];
    [entityObject setCity:city];
    [entityObject setState:state];
    [entityObject setBeer_style:style];
 
    if ([entityObject isKindOfClass:[Beer class]]) {
        [entityObject setGrowlerPrice:params[@"growler"]];
        [entityObject setGrowlettePrice:params[@"growlette"]];
    }
    
    return entityObject;
}

@end
