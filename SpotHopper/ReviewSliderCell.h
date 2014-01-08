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

@interface ReviewSliderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblMnimum;
@property (weak, nonatomic) IBOutlet UILabel *lblMaximum;
@property (weak, nonatomic) IBOutlet SHSlider *slider;

- (void)setReview:(ReviewModel*)review;

@end
