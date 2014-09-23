//
//  SHRatingView.m
//  SpotHopper
//
//  Created by Brennan Stehling on 9/19/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHRatingView.h"

#import "SHStyleKit+Additions.h"

@implementation SHRatingView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self prepareView];
}

- (void)drawRect:(CGRect)rect {
    [self prepareView];
}

- (void)prepareView {
    self.backgroundColor = [UIColor clearColor];
    UIImage *image = [SHStyleKit drawImageForRatingStarsWithPercentage:(_rating * 10) size:self.frame.size];
    self.image = image;
}

#if !TARGET_INTERFACE_BUILDER
- (void)setRating:(CGFloat)rating {
    _rating = rating;
    self.image = [SHStyleKit drawImageForRatingStarsWithPercentage:(_rating * 10) size:self.frame.size];;
    [self setNeedsDisplay];
}
#endif

@end
