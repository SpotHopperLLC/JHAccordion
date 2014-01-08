//
//  SHSlider.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHSlider : UIControl {
	float minimumValue;
	float maximumValue;
	float selectedValue;
	float distanceFromCenter;
    
	float _padding;
    
	BOOL _maxThumbOn;
	BOOL _minThumbOn;
    
	UIImageView * _minThumb;
	UIImageView * _trackBackgroundMin;
    UIImageView * _trackBackgroundMax;
}

@property(nonatomic) float minimumValue;
@property(nonatomic) float maximumValue;
@property(nonatomic) float selectedValue;

@property (nonatomic) CGFloat valueSnapToInterval;

@end