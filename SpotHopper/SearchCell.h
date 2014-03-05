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

@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblNotWhatLookingFor;

- (void)setDrink:(DrinkModel*)drink;
- (void)setSpot:(SpotModel*)spot;
- (void)setDrinksSimilar:(NSString *)text;
- (void)setSpotsSimilar:(NSString *)text;
- (void)setNotWhatYoureLookingFor;

@end