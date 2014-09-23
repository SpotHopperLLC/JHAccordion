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
    
    self.image = [SHStyleKit drawImage:SHStyleKitDrawingRatingSwoosh color:SHStyleKitColorMyTintColor size:self.frame.size percentage:_percentage];
}

#if !TARGET_INTERFACE_BUILDER
- (void)setPercentage:(CGFloat)percentage {
    _percentage = percentage;
    //self.image = [SHStyleKit drawImage:SHStyleKitDrawingRatingSwoosh color:SHStyleKitColorMyTintColor size:self.frame.size percentage:_percentage];
    [self setNeedsDisplay];
}
#endif

@end
