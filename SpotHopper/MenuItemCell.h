//
//  MenuItemCell.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHTableViewCell.h"

#import "SHLabelLatoLight.h"

@class MenuItemModel;

@interface MenuItemCell : SHTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblSpot;
@property (weak, nonatomic) IBOutlet SHLabelLatoLight *lblInfo;
@property (weak, nonatomic) IBOutlet SHLabelLatoLight *lblPrices;

- (void)setMenuItem:(MenuItemModel*)menuItem;

@end
