//
//  MenuItemCell.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SHLabelLatoLight.h"

@class DrinkModel;

@interface MenuItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblSpot;
@property (weak, nonatomic) IBOutlet SHLabelLatoLight *lblInfo;

- (void)setDrink:(DrinkModel*)drink;

@end
