//
//  SpecialsCell.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/26/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHTableViewCell.h"

#import "SpotModel.h"

@protocol SpecialsCellDelegate;

@interface SpecialsCell : SHTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgSpotCover;
@property (weak, nonatomic) IBOutlet UILabel *lblSpotName;
@property (weak, nonatomic) IBOutlet UILabel *lblSpecial;

@property (nonatomic, assign) id<SpecialsCellDelegate> delegate;

- (void)setSpot:(SpotModel*)spot;

@end

@protocol SpecialsCellDelegate <NSObject>

- (void)specialsCellClickedShare:(SpecialsCell*)cell;

@end