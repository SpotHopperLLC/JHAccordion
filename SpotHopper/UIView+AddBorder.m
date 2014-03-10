//
//  UIView+AddBorder.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/5/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "UIView+AddBorder.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIView (AddBorder)

- (void)addTopBorder:(UIColor*)color {
    CAGradientLayer *border = [CAGradientLayer layer];
    border.frame = CGRectMake(0, 0, self.bounds.size.width, 1);
    border.backgroundColor = [color CGColor];
    [self.layer addSublayer:border];
}

- (void)addBottomBorder:(UIColor*)color {
    CAGradientLayer *border = [CAGradientLayer layer];
    border.frame = CGRectMake(0, self.bounds.size.height-1, self.bounds.size.width, 1);
    border.backgroundColor = [color CGColor];
    [self.layer addSublayer:border];
}

@end
