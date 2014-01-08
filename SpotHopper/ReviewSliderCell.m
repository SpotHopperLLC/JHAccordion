//
//  ReviewSliderCell.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "ReviewSliderCell.h"

@implementation ReviewSliderCell

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
    [_slider addTarget:self action:@selector(onValueChangedSlider:) forControlEvents:UIControlEventValueChanged];
}

- (void)dealloc {
    [_slider removeTarget:self action:@selector(onValueChangedSlider:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Actions

- (void)onValueChangedSlider:(id)sender {
    if ([_delegate respondsToSelector:@selector(reviewSliderCell:changedValue:)]) {
        [_delegate reviewSliderCell:self changedValue:_slider.selectedValue];
    }
}

@end
