//
//  Beer.h
//  Growlers
//
//  Created by Daniel Miedema on 7/23/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Beer : NSManagedObject

@property (nonatomic, retain) NSNumber * abv;
@property (nonatomic, retain) NSDate * added;
@property (nonatomic, retain) NSString * brewer;
@property (nonatomic, retain) NSString * brewerURL;
@property (nonatomic, retain) NSNumber * growlerPrice;
@property (nonatomic, retain) NSNumber * growlettePrice;
@property (nonatomic, retain) NSNumber * ibu;
@property (nonatomic, retain) NSString * name;

@end
