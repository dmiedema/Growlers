//
//  Favorites.h
//  Growlers
//
//  Created by Daniel Miedema on 11/19/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Favorites : NSManagedObject

@property (nonatomic, retain) NSString * abv;
@property (nonatomic, retain) NSString * brewer;
@property (nonatomic, retain) NSString * brewerURL;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * ibu;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * store;
@property (nonatomic, retain) NSNumber * tap_id;
@property (nonatomic, retain) NSString * beer_style;

@end
