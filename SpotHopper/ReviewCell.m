//
//  ReviewCell.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/15/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "ReviewCell.h"

#import "DrinkModel.h"
#import "SpotModel.h"
#import "UserModel.h"

@implementation ReviewCell

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

- (void)setReview:(ReviewModel *)review {
    // Sets review name
    if (review.spot != nil) {
        [_lblName setText:review.spot.name];
    } else if (review.drink != nil) {
        [_lblName setText:review.drink.name];
    } else {
        [_lblName setText:@""];
    }
    
    // Sets review rating
    if (review.spot != nil) {
        [_lblRating setText:[review.spot cityState]];
    } else {
        [_lblRating setText:[NSString stringWithFormat:@"%d/10", (int)ceilf(review.rating.floatValue)]];
    }
}

@end
