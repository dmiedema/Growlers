//
//  DMGrowlerTableViewCell.h
//  Growlers
//
//  Created by Daniel Miedema on 7/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMGrowlerTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *beerName;
@property (nonatomic, strong) IBOutlet UILabel *brewery;
@property (nonatomic, strong) IBOutlet UILabel *beerInfo;
@property (nonatomic, strong) IBOutlet UIView *favoriteMarker;
@end
