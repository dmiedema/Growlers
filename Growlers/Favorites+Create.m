//
//  Favorites+Create.m
//  Growlers
//
//  Created by Daniel Miedema on 8/4/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "Favorites+Create.h"

@implementation Favorites (Create)

+ (Favorites *)favoriteWithInfo:(NSDictionary *)info inManagedObjectContext:(NSManagedObjectContext *)context {
    Favorites *favorite = nil;
    
    NSLog(@"Favorites+Create");
    
    NSLog(@"Info: %@", info);
    NSLog(@"Context: %@", context);
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Favorites"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@ and brewer = %@", info[@"name"], info[@"brewer"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    NSLog(@"Matches: %@", matches);
    
    if (!matches || matches.count > 1) {
        // error
    } else if (matches.count == 0) {
        NSLog(@"Creating Entry...");
        favorite = [NSEntityDescription insertNewObjectForEntityForName:@"Favorites" inManagedObjectContext:context];
        favorite.name = info[@"name"];
        favorite.brewer = info[@"brewer"];
    } else {
        favorite = [matches lastObject];
    }
    
    NSLog(@"Entry Created! - %@", favorite);
    
    return favorite;
}

@end
