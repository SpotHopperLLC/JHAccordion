//
//  MenuItemCell.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "MenuItemCell.h"

#import "DrinkModel.h"
#import "SpotModel.h"

@implementation MenuItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDrink:(DrinkModel *)drink {
    
    [_lblName setText:drink.name];
    [_lblSpot setText:drink.spot.name];
    
    // Sets ABV and stuff
    if (drink.style.length > 0 && drink.abv.floatValue > 0) {
        [_lblInfo setText:[NSString stringWithFormat:@"%@ - %@ ABV", drink.style, drink.abvPercentString]];
    } else if (drink.style.length > 0) {
        [_lblInfo setText:drink.style];
    } else if (drink.abv.floatValue > 0) {
        [_lblInfo setText:[NSString stringWithFormat:@"%@ ABV", drink.abvPercentString]];
    } else {
        [_lblInfo italic:YES];
        [_lblInfo setText:@"No style or ABV"];
    }
    
}

@end
