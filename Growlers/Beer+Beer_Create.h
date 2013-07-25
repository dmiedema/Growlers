//
//  Beer+Beer_Create.h
//  Growlers
//
//  Created by Daniel Miedema on 7/23/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "Beer.h"

@interface Beer (Beer_Create)
+ (Beer *)beerWithInfo:(NSDictionary *)info inManagedObjectContext:(NSManagedObjectContext *)context;
@end
