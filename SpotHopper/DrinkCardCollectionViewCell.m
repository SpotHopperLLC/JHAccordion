//
//  DrinkCardCollectionViewCell.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "DrinkCardCollectionViewCell.h"

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

- (void)setDrink:(DrinkModel *)drink {
    
    [_imgDrink setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:drink.imageUrl]] placeholderImage:Nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [_imgDrink setImage:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [_imgDrink setImage:nil];
    }];
    
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
