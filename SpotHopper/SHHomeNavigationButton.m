//
//  SHHomeNavigationButton.m
//  SpotHopper
//
//  Created by Brennan Stehling on 8/4/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHHomeNavigationButton.h"

#import "Tracker+Events.h"

@implementation SHHomeNavigationButton

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    
    if (CGRectContainsPoint(bounds, point)) {
        return self;
    }
    
    // include the label which is below the button
    bounds.size.height += 25;
    
    if (CGRectContainsPoint(bounds, point)) {
        return self;
    }
    
    return nil;
}

@end
