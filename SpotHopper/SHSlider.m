//
//  SHSlider.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHSlider.h"

@interface SHSlider()

- (void)_RS_commonInit;
- (float)xForValue:(float)value;
- (float)valueForX:(float)x;

@end

@implementation SHSlider

//    UIImage *minImage = [[UIImage imageNamed:@"slider_background_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 0)];
//    UIImage *maxImage = [[UIImage imageNamed:@"slider_background_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 25)];
//    UIImage *minImageSelected = [[UIImage imageNamed:@"slider_background_selected_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 0)];
//    UIImage *maxImageSelected = [[UIImage imageNamed:@"slider_background_selected_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 25)];
//    UIImage *thumbImage = [UIImage imageNamed:@"slider_thumb"];
//    UIImage *thumbImageSelected = [UIImage imageNamed:@"slider_thumb_selected"];

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (!self) {
		return nil;
	}
	[self _RS_commonInit];
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (!self) {
		return nil;
	}
	[self _RS_commonInit];
	return self;
}

- (void)_RS_commonInit;
{
	CGRect bounds = [self bounds];
    
	_minThumbOn = false;
	_maxThumbOn = false;
	//_padding = 20.0f;
    
    // Load the track so that we can measure it.
    UIImage *trackImage=[UIImage imageNamed:@"slider_background_min"];
    
    // Assue that the cap ends are semi-circular, so the cap is half of the image height
    trackImage=nil;
    
	_trackBackgroundMin = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"slider_background_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 0)] highlightedImage:[[UIImage imageNamed:@"slider_background_selected_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 0)]];
    _trackBackgroundMax = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"slider_background_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 25)] highlightedImage:[[UIImage imageNamed:@"slider_background_selected_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 25)]];
	
    
    // Load up the handle images so we can measure them
    _minThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_thumb"] highlightedImage:[UIImage imageNamed:@"slider_thumb_selected_with_light"]];
    [_minThumb setContentMode:UIViewContentModeCenter];
    
    // the padding is half of the width of the widest thumb, so that the thumb goes to edge of the subview
    _padding=_minThumb.frame.size.width/2;
    
	_trackBackgroundMin.frame = CGRectMake(_padding,
                                        self.frame.size.height/2-_trackBackgroundMin.frame.size.height/2,
                                        (bounds.size.width / 2.0f) - _padding,
                                        _trackBackgroundMin.frame.size.height);
	_trackBackgroundMin.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _trackBackgroundMax.frame = CGRectMake((bounds.size.width / 2.0f),
                                           self.frame.size.height/2-_trackBackgroundMin.frame.size.height/2,
                                           (bounds.size.width / 2.0f) - _padding,
                                           _trackBackgroundMin.frame.size.height);
	_trackBackgroundMax.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
	[self addSubview:_trackBackgroundMin];
    [self addSubview:_trackBackgroundMax];
    
    CGPoint center = _minThumb.center;
	[self addSubview:_minThumb];
    
    _minThumb.frame = CGRectMake(0, 0, 110.0f, 110.0f);
    _minThumb.center = center;
	_minThumb.contentMode = UIViewContentModeCenter;
    [_minThumb setAutoresizingMask:UIViewAutoresizingNone];
    
	self.minimumValue = 0.0f;
	self.maximumValue = 1.0f;
	self.selectedValue = 0.25f;
    
    [_minThumb setClipsToBounds:NO];
    [self setClipsToBounds:NO];
}


- (void)layoutSubviews
{
	// Set the initial state
	_minThumb.center = CGPointMake([self xForValue:_selectedValue], self.frame.size.height / 2.0);

}

- (void)setSelectedValue:(float)selectedValue {
    _selectedValue = selectedValue;
    _minThumb.center = CGPointMake([self xForValue:selectedValue], self.frame.size.height / 2.0);
}

- (float)xForValue:(float)value
{
	return (self.frame.size.width - (_padding * 2.0)) * ((value - _minimumValue) / (_maximumValue - _minimumValue)) + _padding;
}

- (float)valueForX:(float)x
{
	if (self.valueSnapToInterval) {
		x = roundf(x / self.valueSnapToInterval) * self.valueSnapToInterval;
	}
	return _minimumValue + (x - _padding) / (self.frame.size.width - (_padding * 2.0)) * (_maximumValue - _minimumValue);
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	if(!_minThumbOn && !_maxThumbOn){
		return YES;
	}
    
	CGPoint touchPoint = [touch locationInView:self];
    
	if (_minThumbOn) {
		_minThumb.center = CGPointMake(MAX([self xForValue:_minimumValue], MIN(touchPoint.x - _distanceFromCenter, [self xForValue:_maximumValue])), _minThumb.center.y);
		_selectedValue = [self valueForX:_minThumb.center.x];
	}
    
	[self setNeedsLayout];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
	return YES;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchPoint = [touch locationInView:self];
    
	if (CGRectContainsPoint(_minThumb.frame, touchPoint)){
		_minThumbOn = true;
		_distanceFromCenter = touchPoint.x - _minThumb.center.x;
        [_trackBackgroundMin setHighlighted:YES];
        [_trackBackgroundMax setHighlighted:YES];
        [_minThumb setHighlighted:YES];
	}
    
	return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	_minThumbOn = false;
	_maxThumbOn = false;
    
    [_trackBackgroundMin setHighlighted:NO];
    [_trackBackgroundMax setHighlighted:NO];
    [_minThumb setHighlighted:NO];
}

@end
