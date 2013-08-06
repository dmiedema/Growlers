//
//  Favorites.h
//  Growlers
//
//  Created by Daniel Miedema on 8/4/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Favorites : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * brewer;

@end
