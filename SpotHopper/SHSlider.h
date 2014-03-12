//
//  SHSlider.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHSlider : UIControl {
//	float minimumValue;
//	float maximumValue;
//	float selectedValue;
//	float distanceFromCenter;
//    
//	float _padding;
//    
//	BOOL _maxThumbOn;
//	BOOL _minThumbOn;
//    
//	UIImageView * _minThumb;
//	UIImageView * _trackBackgroundMin;
//    UIImageView * _trackBackgroundMax;
}

@property (nonatomic, assign) BOOL vibeFeel;
@property (nonatomic, assign) BOOL userMoved;

@property (nonatomic, assign) float minimumValue;
@property (nonatomic, assign) float maximumValue;
@property (nonatomic, assign) float selectedValue;
@property (nonatomic, assign) float distanceFromCenter;

@property (nonatomic, assign) float padding;

@property (nonatomic, assign) BOOL maxThumbOn;
@property (nonatomic, assign) BOOL minThumbOn;

@property (nonatomic, strong) UIImageView *minThumb;
@property (nonatomic, strong) UIImageView *trackBackgroundMin;
@property (nonatomic, strong) UIImageView *trackBackgroundMax;

@property (nonatomic) CGFloat valueSnapToInterval;

@end