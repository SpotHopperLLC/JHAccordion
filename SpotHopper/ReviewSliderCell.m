//
//  ReviewSliderCell.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "ReviewSliderCell.h"

@implementation ReviewSliderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSliderTemplate:(SliderTemplateModel *)sliderTemplate withSlider:(SliderModel *)slider showSliderValue:(BOOL)show {
    
    [_lblSlideToAdjust italic:YES];
    
    [_lblMnimum setText:sliderTemplate.minLabel];
    [_lblMaximum setText:sliderTemplate.maxLabel];
    
    if (slider.value == nil) {
        [_slider setSelectedValue:(sliderTemplate.defaultValue.floatValue / 10.0f)];
        [_slider setUserMoved:NO];
    } else {
        [_slider setSelectedValue:(slider.value.floatValue / 10.0f)];
        [_slider setUserMoved:YES];
    }
    
    [_lblSliderValue setHidden:!show];
    [_lblSliderValue setText:[[NSNumber numberWithInt:ceil(_slider.selectedValue * 10)] stringValue]];
    
    [_slider addTarget:self action:@selector(onValueChangedSlider:) forControlEvents:UIControlEventValueChanged];
}

- (void)setVibeFeel:(BOOL)vibeFeel slider:(SliderModel*)slider {
    [_slider setVibeFeel:vibeFeel];
    
    if (vibeFeel == YES) {
        // Highlight max label orange if slider value is greater than 5 OR if there is no min label
        if (slider.value.floatValue >= 5.0f || slider.sliderTemplate.minLabel.length == 0) {
            [_lblMnimum setTextColor:[UIColor colorWithRed:(64.0f/255.0f) green:(64.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f]];
            [_lblMaximum setTextColor:kColorOrangeDark];
        } else {
            [_lblMnimum setTextColor:kColorOrangeDark];
            [_lblMaximum setTextColor:[UIColor colorWithRed:(64.0f/255.0f) green:(64.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f]];
        }
    }
    
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
