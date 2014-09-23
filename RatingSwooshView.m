//
//  RatingSwooshView.m
//  SpotHopper
//
//  Created by Brennan Stehling on 9/22/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "RatingSwooshView.h"

#import "SHStyleKit+Additions.h"

@implementation RatingSwooshView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self prepareView];
}

- (void)drawRect:(CGRect)rect {
    [self prepareView];
}

- (void)prepareView {
    self.contentMode = UIViewContentModeCenter;
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGSize size = CGSizeMake(width, width); // ensure the scale is square
    
    self.image = [SHStyleKit drawImage:SHStyleKitDrawingRatingSwoosh color:SHStyleKitColorMyTintColor size:size percentage:_percentage];
}

#if !TARGET_INTERFACE_BUILDER
- (void)setPercentage:(CGFloat)percentage {
    _percentage = percentage;
    [self prepareView];
}
#endif

@end
