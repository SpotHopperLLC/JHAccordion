//
//  SHRatingView.m
//  SpotHopper
//
//  Created by Brennan Stehling on 9/19/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHRatingStarsView.h"

#import "SHStyleKit+Additions.h"

@implementation SHRatingStarsView

//- (void)drawRect:(CGRect)rect {
//}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//}

- (void)updateStarsImage {
    self.backgroundColor = [UIColor clearColor];
    UIImage *image = [SHStyleKit drawImageForRatingStarsWithPercentage:(_rating * 10) size:self.frame.size];
    self.image = image;
}

#if !TARGET_INTERFACE_BUILDER
- (void)setRating:(CGFloat)rating {
    DebugLog(@"%@, %f", NSStringFromSelector(_cmd), rating);
    _rating = rating;
    [self updateStarsImage];
}
#endif

@end
