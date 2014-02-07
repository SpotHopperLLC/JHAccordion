//
//  ReviewSliderCell.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SHSlider.h"

#import "ReviewModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"

@protocol ReviewSliderCellDelegate;

@interface ReviewSliderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblMnimum;
@property (weak, nonatomic) IBOutlet UILabel *lblMaximum;
@property (weak, nonatomic) IBOutlet UILabel *lblSliderValue;
@property (weak, nonatomic) IBOutlet SHSlider *slider;

@property (nonatomic, assign) id<ReviewSliderCellDelegate> delegate;

- (void)setSliderTemplate:(SliderTemplateModel*)sliderTemplate withSlider:(SliderModel*)slider showSliderValue:(BOOL)show;

@end

@protocol ReviewSliderCellDelegate <NSObject>

- (void)reviewSliderCell:(ReviewSliderCell*)cell changedValue:(float)value;

@end
