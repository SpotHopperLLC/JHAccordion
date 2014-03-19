//
//  SHSlider.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define DISABLE_TOUCH_EVENTS 1

#import "SHSlider.h"

@interface SHSlider() <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGFloat minimumValue;
@property (nonatomic, assign) CGFloat maximumValue;
@property (nonatomic, assign) CGFloat distanceFromCenter;

@property (nonatomic, assign) CGFloat padding;

@property (nonatomic, assign) BOOL maxThumbOn;
@property (nonatomic, assign) BOOL minThumbOn;

@property (nonatomic, strong) UIImageView *minThumb;
@property (nonatomic, strong) UIImageView *trackBackgroundMin;
@property (nonatomic, strong) UIImageView *trackBackgroundMax;

@property (nonatomic) CGFloat valueSnapToInterval;

@property (nonatomic, weak) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, weak) UIPanGestureRecognizer *panGestureRecognizer;

- (void)_RS_commonInit;
- (CGFloat)xForValue:(CGFloat)value;
- (CGFloat)valueForX:(CGFloat)x;

@end

@implementation SHSlider

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (!self) {
		return nil;
	}
	[self _RS_commonInit];
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (!self) {
		return nil;
	}
	[self _RS_commonInit];
	return self;
}

- (void)_RS_commonInit {
	CGRect bounds = [self bounds];
    
	_minThumbOn = FALSE;
	_maxThumbOn = FALSE;
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
    [self updateVibeFeel];
    
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
    self.valueSnapToInterval = 0.1;
    
    [_minThumb setClipsToBounds:NO];
    [self setClipsToBounds:NO];
    
    [self modifyControl:self];
}

- (void)setSelectedValue:(CGFloat)selectedValue {
    [self setSelectedValue:selectedValue animated:FALSE];
}

- (void)setSelectedValue:(CGFloat)selectedValue animated:(BOOL)animated {
    _selectedValue = selectedValue;
    
    CGFloat duration = animated ? 0.25 : 0.0;
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        _minThumb.center = CGPointMake([self xForValue:selectedValue], self.frame.size.height / 2.0);
    } completion:^(BOOL finished) {
    }];
    
    if (self.sliderDelegate) {
        [self.sliderDelegate slider:self valueDidChange:self.selectedValue];
    }
}

- (CGFloat)xForValue:(CGFloat)value {
	return (self.frame.size.width - (_padding * 2.0)) * ((value - _minimumValue) / (_maximumValue - _minimumValue)) + _padding;
}

- (CGFloat)valueForX:(CGFloat)x {
	return _minimumValue + (x - _padding) / (self.frame.size.width - (_padding * 2.0)) * (_maximumValue - _minimumValue);
}

#pragma mark - Gestures

- (void)modifyControl:(UIControl *)control {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognized:)];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognized:)];
    control.gestureRecognizers = @[tapGestureRecognizer, panGestureRecognizer];
    
    [control addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.tapGestureRecognizer = tapGestureRecognizer;
    self.panGestureRecognizer = panGestureRecognizer;
}

- (IBAction)gestureRecognized:(id)sender {
    [self handleSliderGestureRecognizer:(UIGestureRecognizer *)sender];
}

- (void)valueChanged:(id)sender {
    if (self.sliderDelegate) {
        [self.sliderDelegate slider:self valueDidChange:self.selectedValue];
    }
}

- (void)handleSliderGestureRecognizer:(UIGestureRecognizer *)recognizer {
    if (_vibeFeel == YES) return;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [_minThumb setHighlighted:YES];
            break;
        case UIGestureRecognizerStateChanged:
            // do nothing
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [_minThumb setHighlighted:NO];
            break;
            
        default:
            // do nothing
            break;
    }
    
    if ([recognizer.view isKindOfClass:[SHSlider class]]) {
        SHSlider *slider = (SHSlider *)recognizer.view;
        CGPoint point = [recognizer locationInView:recognizer.view];
        CGFloat width = CGRectGetWidth(slider.frame);
        CGFloat percentage = MAX(0.0, MIN(1.0, point.x / width)); // bound to 0.0 to 1.0
        
        // new value is based on the slider's min and max values which
        // could be different with each slider
        CGFloat newValue = ((slider.maximumValue - slider.minimumValue) * percentage) + slider.minimumValue;
        
        [slider setSelectedValue:newValue]; // ensures thumb control is opaque after value is set from the default
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // ensure the pan gesture does not handle vertical movement
    if (gestureRecognizer == self.panGestureRecognizer) {
        UIView *view = [gestureRecognizer view];
        CGPoint translation = [gestureRecognizer translationInView:[view superview]];
        // Check for horizontal gesture
        return fabsf(translation.x) > fabsf(translation.y);
    }
    
    return YES;
}

#ifndef DISABLE_TOUCH_EVENTS

#pragma mark - UIControl Touch Events

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_vibeFeel == YES) return NO;
    
	if(!_minThumbOn && !_maxThumbOn){
		return YES;
	}
    
	CGPoint touchPoint = [touch locationInView:self];
    
	if (_minThumbOn) {
        CGFloat x = MAX([self xForValue:_minimumValue], MIN(touchPoint.x - _distanceFromCenter, [self xForValue:_maximumValue]));
		_minThumb.center = CGPointMake(x, _minThumb.center.y);
		_selectedValue = [self valueForX:_minThumb.center.x];
	}
    
	[self setNeedsLayout];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
	return YES;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_vibeFeel == YES) return NO;
    
	CGPoint touchPoint = [touch locationInView:self];
    
	if (CGRectContainsPoint(_minThumb.frame, touchPoint)){
		_minThumbOn = TRUE;
		_distanceFromCenter = touchPoint.x - _minThumb.center.x;
        [_trackBackgroundMin setHighlighted:YES];
        [_trackBackgroundMax setHighlighted:YES];
        [_minThumb setHighlighted:YES];
	}
    
	return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self turnOff];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self turnOff];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Checks to make sure the slider isn't being slid (yeah)
    
    if(!_minThumbOn && !_maxThumbOn){
        // Gets first touch
        UITouch *touch = [[touches allObjects] firstObject];
        if (touch != nil) {
            
            // Gets touch point
            CGPoint touchPoint = [touch locationInView:self];
            
            // Sets touch point value
            CGFloat x = MAX([self xForValue:_minimumValue], MIN(touchPoint.x - _distanceFromCenter, [self xForValue:_maximumValue]));
            _minThumb.center = CGPointMake(x, _minThumb.center.y);
            _selectedValue = [self valueForX:_minThumb.center.x];
            
            // Updates layout and notifies via value changed
            [self setNeedsLayout];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
    
    [self turnOff];
}

#endif

- (void)turnOff {
    _minThumbOn = FALSE;
	_maxThumbOn = FALSE;
    
    [_trackBackgroundMin setHighlighted:NO];
    [_trackBackgroundMax setHighlighted:NO];
    [_minThumb setHighlighted:NO];
}

// disabled editing when true and styles it accordingly
- (void)setVibeFeel:(BOOL)vibeFeel {
    _vibeFeel = vibeFeel;
    [self updateVibeFeel];
}

- (void)setUserMoved:(BOOL)userMoved {
    _userMoved = userMoved;
    [self updateVibeFeel];
}

- (void)updateVibeFeel {
    if (_vibeFeel == NO) {
        [_trackBackgroundMin setImage:[[UIImage imageNamed:( _userMoved ? @"slider_background_selected_min" : @"slider_background_min" )] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 0)]];
        [_trackBackgroundMin setHighlightedImage:[[UIImage imageNamed:@"slider_background_selected_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 0)]];
        
        [_trackBackgroundMax setImage:[[UIImage imageNamed:( _userMoved ? @"slider_background_selected_max" : @"slider_background_max" )] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 25)]];
        [_trackBackgroundMax setHighlightedImage:[[UIImage imageNamed:@"slider_background_selected_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 25)]];
        
        
        // Load up the handle images so we can measure them
        [_minThumb setImage:[UIImage imageNamed: _userMoved ? @"slider_thumb_selected" : @"slider_thumb"]];
        [_minThumb setHighlightedImage:[UIImage imageNamed:@"slider_thumb_selected_with_light"]];
    } else {
        [_trackBackgroundMin setImage:[[UIImage imageNamed:@"slider_background_profile_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 0)]];
        [_trackBackgroundMin setHighlightedImage:[[UIImage imageNamed:@"slider_background_profile_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 0)]];
        
        [_trackBackgroundMax setImage:[[UIImage imageNamed:@"slider_background_profile_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 25)]];
        [_trackBackgroundMax setHighlightedImage:[[UIImage imageNamed:@"slider_background_profile_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 25)]];
        
        
        // Load up the handle images so we can measure them
        [_minThumb setImage:[UIImage imageNamed:@"slider_profile_thumb"]];
        [_minThumb setHighlightedImage:[UIImage imageNamed:@"slider_profile_thumb"]];
    }
}

@end
