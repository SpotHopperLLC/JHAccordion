//
//  MenuItemCell.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "MenuItemCell.h"

#import "NSNumber+Currency.h"

#import "BaseAlcoholModel.h"
#import "DrinkModel.h"
#import "MenuItemModel.h"
#import "PriceModel.h"
#import "SizeModel.h"
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

- (void)setMenuItem:(MenuItemModel*)menuItem {
    
    DrinkModel *drink = menuItem.drink;
    
    // Names
    [_lblName setText:drink.name];
    if ([drink isCocktail] == YES) {
        BaseAlcoholModel *baseAlcohol = [[drink baseAlochols] firstObject];
        [_lblSpot setText:baseAlcohol.name];
    } else {
        [_lblSpot setText:drink.spot.name];
    }
    
    // Sort prices high to low
    NSArray *sortedPrices = [menuItem.prices sortedArrayUsingComparator:^NSComparisonResult(PriceModel *obj1, PriceModel *obj2) {
        return [obj2.cents compare:obj1.cents];
    }];
    
    // Prices
    NSMutableArray *priceStrs = [NSMutableArray array];
    for (PriceModel *price in sortedPrices) {
        [priceStrs addObject:[price priceAndSize]];
    }
    [_lblPrices setText:[priceStrs componentsJoinedByString:@"\n"]];
    
    // Sets ABV and stuff
    if ([drink isWine]) {
        [_lblInfo setText:[NSString stringWithFormat:@"%@", drink.vintage ? drink.vintage : @""]];
    }
    else if ([drink isBeer]) {
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
    } else {
        [_lblInfo setText:@""];
    }
    
}

@end
