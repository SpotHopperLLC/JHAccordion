//
//  DrinkCardCollectionViewCell.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "DrinkCardCollectionViewCell.h"

#import "NSNumber+Currency.h"

#import "AverageReviewModel.h"
#import "DrinkTypeModel.h"
#import "ImageModel.h"
#import "PriceModel.h"
#import "SizeModel.h"
#import "SpotModel.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation DrinkCardCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setDrink:(DrinkModel *)drink menuItem:(MenuItemModel*)menuItem {
    
    // Visibles
    [_btnFindIt setHidden:(menuItem != nil)];
    [_lblPrice setHidden:(menuItem == nil)];
    
    // Sets price
    if (menuItem != nil) {
        NSLog(@"Menu item - %@", menuItem);
        NSLog(@"Menu item prices - %@", [menuItem prices]);
        PriceModel *price = [[menuItem prices] firstObject];
        if (price != nil) {
            [_lblPrice setText:[NSString stringWithFormat:@"%@ / %@", [NSNumber numberWithFloat:(price.cents.floatValue / 100.0f)].currencyFormat, price.size.name]];
        } else {
            [_lblPrice setText:@""];
        }
    }
    
    // Sets image
    ImageModel *image = drink.images.firstObject;
    if (image != nil) {
        [_imgDrink setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:drink.placeholderImage];
    } else {
        [_imgDrink setImage:drink.placeholderImage];
    }
    
    [_lblName setText:[NSString stringWithFormat:@"%@ >", drink.name]];
    [_lblSpot setText:drink.spot.name];
    
    // Sets Rating and stuff
    NSString *word = nil;
    if ([drink.drinkType.name isEqual:kDrinkTypeNameBeer] == YES) {
        word = drink.style;
    } else if ([drink.drinkType.name isEqual:kDrinkTypeNameCocktail] == YES) {
        word = [[drink.baseAlochols valueForKey:@"name"] componentsJoinedByString:@" ,"];
    } else if ([drink.drinkType.name isEqual:kDrinkTypeNameWine] == YES) {
        word = drink.varietal;
    }
    
    if (word.length > 0 && drink.averageReview != nil) {
        [_lblInfo setText:[NSString stringWithFormat:@"%@ - %.1f/10", word, drink.averageReview.rating.floatValue]];
    } else if (drink.style.length > 0) {
        [_lblInfo setText:word];
    } else if (drink.averageReview != nil) {
        [_lblInfo setText:[NSString stringWithFormat:@"%.1f/10", drink.averageReview.rating.floatValue]];
    } else {
        [_lblInfo italic:YES];
        [_lblInfo setText:@"No style or rating"];
    }
    
}

#pragma mark - Actions

- (IBAction)onClickFindit:(id)sender {
    if ([_delegate respondsToSelector:@selector(drinkCardCollectionViewCellClickedFindIt:)]) {
        [_delegate drinkCardCollectionViewCellClickedFindIt:self];
    }
}

@end
