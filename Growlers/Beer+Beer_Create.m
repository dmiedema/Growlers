//
//  Beer+Beer_Create.m
//  Growlers
//
//  Created by Daniel Miedema on 7/23/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "Beer+Beer_Create.h"

@implementation Beer (Beer_Create)
+ (Beer *)beerWithInfo:(NSDictionary *)info inManagedObjectContext:(NSManagedObjectContext *)context {
    Beer *beer = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Beer"];
    request.predicate       = [NSPredicate predicateWithFormat:@"name = %@", info[@"name"]];
    
    NSError *err = nil;
    NSArray *matches = [context executeFetchRequest:request error:&err];
    
    if (!matches || matches.count > 1) {
        // error
    } else if (matches.count == 0) {
        beer = [NSEntityDescription insertNewObjectForEntityForName:@"Beer" inManagedObjectContext:context];
        beer.name           = info[@"name"];
        beer.brewer         = info[@"brewer"];
        beer.brewerURL      = info[@"brewerURL"];
        beer.abv            = info[@"abv"];
        beer.ibu            = info[@"ibu"];
        beer.growlerPrice   = info[@"growler"];
        beer.growlettePrice = info[@"growlette"];
        beer.added          = [NSDate date];
    } else {
        beer = matches.lastObject;
    }
    
    return beer;
}
@end
