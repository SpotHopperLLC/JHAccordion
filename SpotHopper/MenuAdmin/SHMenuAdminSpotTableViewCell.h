//
//  SpotTableViewCell.h
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 7/23/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotModel.h"

@interface SHMenuAdminSpotTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblSpotName;
@property (weak, nonatomic) IBOutlet UILabel *lblSpotType;
@property (weak, nonatomic) IBOutlet UILabel *lblSpotAddress;

- (void)setSpot:(SpotModel *)spot;

@end
