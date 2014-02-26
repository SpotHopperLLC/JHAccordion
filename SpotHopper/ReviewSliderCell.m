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

- (void)setSliderTemplate:(SliderTemplateModel *)sliderTemplate withSlider:(SliderModel *)slider showSliderValue:(BOOL)show {
    
    [_lblSlideToAdjust italic:YES];
    
    [_lblMnimum setText:sliderTemplate.minLabel];
    [_lblMaximum setText:sliderTemplate.maxLabel];
    
    if (slider == nil) {
        [_slider setSelectedValue:(sliderTemplate.defaultValue.floatValue / 10.0f)];
    } else {
        [_slider setSelectedValue:(slider.value.floatValue / 10.0f)];
    }
    
    [_lblSliderValue setHidden:!show];
    [_lblSliderValue setText:[[NSNumber numberWithInt:ceil(_slider.selectedValue * 10)] stringValue]];
    
    [_slider addTarget:self action:@selector(onValueChangedSlider:) forControlEvents:UIControlEventValueChanged];
}

- (void)dealloc {
    [_slider removeTarget:self action:@selector(onValueChangedSlider:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Actions

- (void)onValueChangedSlider:(id)sender {
    [_lblSliderValue setText:[[NSNumber numberWithInt:ceil(_slider.selectedValue * 10)] stringValue]];
    if ([_delegate respondsToSelector:@selector(reviewSliderCell:changedValue:)]) {
        [_delegate reviewSliderCell:self changedValue:_slider.selectedValue];
    }
}

@end
