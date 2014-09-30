//
//  RatingSwooshView.m
//  SpotHopper
//
//  Created by Brennan Stehling on 9/22/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHRatingSwooshView.h"

#import "SHStyleKit+Additions.h"

@implementation SHRatingSwooshView

//- (void)drawRect:(CGRect)rect {
//    [self updateSwooshImage];
//}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//}

- (void)updateSwooshImage {
    self.contentMode = UIViewContentModeCenter;
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGSize size = CGSizeMake(width, width); // ensure the scale is square
    self.image = [SHStyleKit drawImage:SHStyleKitDrawingRatingSwoosh color:SHStyleKitColorMyTintColor size:size percentage:_percentage];
}

#if !TARGET_INTERFACE_BUILDER
- (void)setPercentage:(CGFloat)percentage {
    _percentage = percentage;
    [self updateSwooshImage];
}
#endif

@end
