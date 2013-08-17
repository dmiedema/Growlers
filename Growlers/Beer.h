//
//  Beer.h
//  Growlers
//
//  Created by Daniel Miedema on 8/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Beer : NSManagedObject

@property (nonatomic, retain) NSString * abv;
@property (nonatomic, retain) NSString * brewer;
@property (nonatomic, retain) NSString * brewerURL;
@property (nonatomic, retain) NSString * growlerPrice;
@property (nonatomic, retain) NSString * growlettePrice;
@property (nonatomic, retain) NSString * ibu;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * store;
@property (nonatomic, retain) NSString * style;
@property (nonatomic, retain) NSNumber * tap_id;

@end
