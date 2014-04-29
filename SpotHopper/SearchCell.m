//
//  SearchCell.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/15/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SearchCell.h"

#import "DrinkTypeModel.h"

@implementation SearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setDrink:(DrinkModel *)drink {
    [self setup];
    
    NSString *title = drink.name;
    NSString *subtitle = drink.spot.name;
    
    // Sets image to drink type
    if ([drink isBeer] == YES) {
        [_imgIcon setImage:[UIImage imageNamed:@"icon_search_beer"]];
    } else if ([drink isCocktail] == YES) {
        [_imgIcon setImage:[UIImage imageNamed:@"icon_search_cocktails"]];
    } else if ([drink isWine] == YES) {
        [_imgIcon setImage:[UIImage imageNamed:@"icon_search_wine"]];
    }
    
    // Shows two lines if there is a spot name (brewery or winery)
    if (subtitle.length == 0) {
        [_lblName setText:title];
        [_lblName setHidden:NO];
    } else {
        if ([drink isWine] && drink.vintage && ![drink isKindOfClass:[NSNull class]]) {
            [_lblMainTitle setText:[NSString stringWithFormat:@"%@ (%@)", title, drink.vintage]];
        }
        else {
            [_lblMainTitle setText:title];
        }
        if (!title.length && subtitle.length) {
            [_lblMainTitle setText:subtitle];
        }
        else {
            [_lblSubTitle setText:subtitle];
        }
        
        [_lblMainTitle setHidden:NO];
        [_lblSubTitle setHidden:NO];
    }
}

- (void)setSpot:(SpotModel *)spot {
    [self setup];
    
    [_imgIcon setImage:[UIImage imageNamed:@"icon_search_spot"]];
    [_lblMainTitle setText:spot.name];
    [_lblSubTitle setText:spot.addressCityState];
    
    [_lblMainTitle setHidden:NO];
    [_lblSubTitle setHidden:NO];
}

- (void)setDrinksSimilar:(NSString *)text {
    [self setup];
    
    [_imgIcon setImage:[UIImage imageNamed:@"icon_search_drink_similar"]];
    [_lblName setText:[NSString stringWithFormat:@"Drinks Similar to %@", text]];
    
    [_lblName setHidden:NO];
}

- (void)setSpotsSimilar:(NSString *)text {
    [self setup];
    
    [_imgIcon setImage:[UIImage imageNamed:@"icon_search_spot_similar"]];
    [_lblName setText:[NSString stringWithFormat:@"Spots Similar to %@", text]];
    
    [_lblName setHidden:NO];
}

- (void)setNotWhatYoureLookingFor {
    [self setup];
    
    [_imgIcon setImage:nil];
    [_lblNotWhatLookingFor setHidden:NO];
}

#pragma mark - Private

- (void)setup {
    [self setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.5f]];
    [self.contentView setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.5f]];
    
    [_imgIcon setImage:nil];
    [_lblName setHidden:YES];
    [_lblNotWhatLookingFor setHidden:YES];
    [_lblMainTitle setHidden:YES];
    [_lblSubTitle setHidden:YES];
}

@end
