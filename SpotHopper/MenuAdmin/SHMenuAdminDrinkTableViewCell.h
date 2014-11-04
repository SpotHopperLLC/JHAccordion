//
//  DrinkCellTableViewCell.h
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 7/23/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrinkModel.h"

@interface SHMenuAdminDrinkTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblDrinkName;
@property (weak, nonatomic) IBOutlet UILabel *lblSpotName;
@property (weak, nonatomic) IBOutlet UILabel *lblDrinkSpecifics;

- (void)setDrink:(DrinkModel*)drink;

@end
