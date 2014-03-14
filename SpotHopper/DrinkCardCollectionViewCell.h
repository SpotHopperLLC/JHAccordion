//
//  DrinkCardCollectionViewCell.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SHLabelLatoLight.h"

#import "DrinkModel.h"

@protocol DrinkCardCollectionViewCellDelegate;

@interface DrinkCardCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblSpot;
@property (weak, nonatomic) IBOutlet UIImageView *imgDrink;
@property (weak, nonatomic) IBOutlet SHLabelLatoLight *lblInfo;

@property (nonatomic, assign) id<DrinkCardCollectionViewCellDelegate> delegate;

- (void)setDrink:(DrinkModel*)drink;

@end

@protocol DrinkCardCollectionViewCellDelegate <NSObject>

- (void)drinkCardCollectionViewCellClickedFindIt:(DrinkCardCollectionViewCell*)cell;

@end
