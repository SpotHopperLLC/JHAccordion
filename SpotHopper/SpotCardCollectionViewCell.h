//
//  SpotCardCollectionViewCell.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/5/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SpotModel.h"

@interface SpotCardCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblMatch;

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblType;
@property (weak, nonatomic) IBOutlet UIImageView *imgSpot;
@property (weak, nonatomic) IBOutlet UILabel *lblWhere;
@property (weak, nonatomic) IBOutlet UILabel *lblHowFar;

- (void)setSpot:(SpotModel*)spot;

@end
