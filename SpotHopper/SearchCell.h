//
//  SearchCell.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/15/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrinkModel.h"
#import "SpotModel.h"

@interface SearchCell : UITableViewCell

- (void)setDrink:(DrinkModel*)drink;
- (void)setSpot:(SpotModel*)spot;

@end
