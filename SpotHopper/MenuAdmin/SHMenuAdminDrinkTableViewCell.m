//
//  DrinkCellTableViewCell.m
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 7/23/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import "SHMenuAdminDrinkTableViewCell.h"

#import "SpotModel.h"
#import "DrinkTypeModel.h"
#import "BaseAlcoholModel.h"

#import "SHMenuAdminStyleSupport.h"

@implementation SHMenuAdminDrinkTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self styleCell];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDrink:(DrinkModel*)drink {
    
    self.lblDrinkName.text = drink.name;
    self.lblSpotName.text = drink.spot.name;
    
    NSString *specifics = nil;
    if ([drink.drinkType.name isEqualToString:kDrinkTypeNameBeer]) {
        specifics = drink.style;
    }
    else if ([drink.drinkType.name isEqualToString:kDrinkTypeNameWine]) {
        specifics = [drink.vintage stringValue];
    }
    else if ([drink.drinkType.name isEqualToString:kDrinkTypeNameCocktail]) {
        BaseAlcoholModel *baseAlcohol = [drink.baseAlochols firstObject];
        if (baseAlcohol) {
            specifics = baseAlcohol.name;
        }
    }
    
    if (specifics) {
        self.lblDrinkSpecifics.text = specifics;
    }
    
}

#pragma mark - Style
#pragma mark -

- (void)styleCell {
    self.lblDrinkName.font = [UIFont fontWithName:@"Lato-Bold" size:18.0f];
    self.lblDrinkName.textColor = [SHMenuAdminStyleSupport sharedInstance].ORANGE;
    
    self.lblSpotName.font = [UIFont fontWithName:@"Lato-Regular" size:14.0f];
    self.lblDrinkSpecifics.font = [UIFont fontWithName:@"Lato-Regular" size:14.0f];
}

@end
