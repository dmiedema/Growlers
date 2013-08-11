//
//  Favorites.h
//  Growlers
//
//  Created by Daniel Miedema on 8/10/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Favorites : NSManagedObject

@property (nonatomic, retain) NSString * brewer;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * tap_id;
@property (nonatomic, retain) NSString * abv;
@property (nonatomic, retain) NSString * ibu;
@property (nonatomic, retain) NSString * brewerURL;

@end
