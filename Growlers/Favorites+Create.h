//
//  Favorites+Create.h
//  Growlers
//
//  Created by Daniel Miedema on 8/4/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "Favorites.h"

@interface Favorites (Create)
+ (Favorites *)favoriteWithInfo:(NSDictionary *)info inManagedObjectContext:(NSManagedObjectContext *)context;
@end
