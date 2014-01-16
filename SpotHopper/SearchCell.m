//
//  SearchCell.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/15/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SearchCell.h"

@implementation SearchCell

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
}

- (void)setDrink:(DrinkModel *)drink {
    [self setup];
    
    [_imgIcon setImage:[UIImage imageNamed:@"icon_search_drink"]];
    [_lblName setText:drink.name];
}

- (void)setSpot:(SpotModel *)spot {
    [self setup];
    
    [_imgIcon setImage:[UIImage imageNamed:@"icon_search_spot"]];
    [_lblName setText:spot.name];
}

#pragma mark - Private

- (void)setup {
    [self setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.5f]];
    [self.contentView setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.5f]];
}

@end
