//
//  ReviewSliderCell.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHTableViewCell.h"

#import "SHSlider.h"

#import "SHLabelLatoLight.h"

#import "ReviewModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"

@protocol ReviewSliderCellDelegate;

@interface ReviewSliderCell : SHTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblMnimum;
@property (weak, nonatomic) IBOutlet UILabel *lblMaximum;
@property (weak, nonatomic) IBOutlet UILabel *lblSliderValue;
@property (weak, nonatomic) IBOutlet SHLabelLatoLight *lblSlideToAdjust;
@property (weak, nonatomic) IBOutlet SHSlider *slider;

@property (nonatomic, assign) id<ReviewSliderCellDelegate> delegate;

- (void)setSliderTemplate:(SliderTemplateModel*)sliderTemplate withSlider:(SliderModel*)slider showSliderValue:(BOOL)show;
- (void)setVibeFeel:(BOOL)vibeFeel slider:(SliderModel*)slider;

@end

@protocol ReviewSliderCellDelegate <NSObject>

- (void)reviewSliderCell:(ReviewSliderCell*)cell changedValue:(float)value;

@end
