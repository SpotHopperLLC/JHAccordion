//
//  SHSlider.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHSlider.h"

#import "SHStyleKit+Additions.h"

#pragma mark - C Functions
#pragma mark -

double radians (double degrees) {return degrees * M_PI/180;}
double degrees (double radians) {return radians * 180/M_PI;}
double angleInRadians (CGAffineTransform transform) {
    return atan2f(transform.b, transform.a);
}
double angleInDegrees (CGAffineTransform transform) {
    return degrees(angleInRadians(transform));
}
double getPercentage(double min, double max, double currentValue) {
    if (currentValue < min) {
        currentValue = min;
    }
    else if (currentValue > max) {
        currentValue = max;
    }
    
    double percentage = (currentValue - min) / (max - min);
    
    return percentage;
}
double getValue(double min, double max, double currentPercentage) {
    if (currentPercentage < 0.0) {
        currentPercentage = 0;
    }
    else if (currentPercentage > 1.0) {
        currentPercentage = 1.0;
    }
    
    double value = ((max - min) * currentPercentage) + min;
    
    return value;
}

@interface SHSlider() <UIGestureRecognizerDelegate>

//@property (nonatomic, assign) CGFloat minimumValue;
//@property (nonatomic, assign) CGFloat maximumValue;
//@property (nonatomic, assign) CGFloat distanceFromCenter;

//@property (nonatomic, assign) CGFloat padding;

//@property (nonatomic, assign) BOOL maxThumbOn;
//@property (nonatomic, assign) BOOL minThumbOn;

//@property (nonatomic, strong) UIImageView *minThumb;
//@property (nonatomic, strong) UIImageView *trackBackgroundMin;
//@property (nonatomic, strong) UIImageView *trackBackgroundMax;

//@property (nonatomic) CGFloat valueSnapToInterval;

//@property (nonatomic, weak) UITapGestureRecognizer *tapGestureRecognizer;
//@property (nonatomic, weak) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation SHSlider

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (!self) {
		return nil;
	}
//	[self _RS_commonInit];
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (!self) {
		return nil;
	}
//	[self _RS_commonInit];
	return self;
}

//- (void)_RS_commonInit {
//	CGRect bounds = [self bounds];
//    
//	_minThumbOn = FALSE;
//	_maxThumbOn = FALSE;
//	//_padding = 20.0f;
//    
//    _trackBackgroundMin = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"slider_background_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 0)] highlightedImage:[[UIImage imageNamed:@"slider_background_selected_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 0)]];
//    _trackBackgroundMax = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"slider_background_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 25)] highlightedImage:[[UIImage imageNamed:@"slider_background_selected_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 25)]];
//    
//    // Load up the handle images so we can measure them
//    _minThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider_thumb"] highlightedImage:[UIImage imageNamed:@"slider_thumb_selected_with_light"]];
//    [_minThumb setContentMode:UIViewContentModeCenter];
//    [self updateVibeFeel];
//    
//    // the padding is half of the width of the widest thumb, so that the thumb goes to edge of the subview
//    _padding=_minThumb.frame.size.width/2;
//    
//	_trackBackgroundMin.frame = CGRectMake(_padding,
//                                        self.frame.size.height/2-_trackBackgroundMin.frame.size.height/2,
//                                        (bounds.size.width / 2.0f) - _padding,
//                                        _trackBackgroundMin.frame.size.height);
//	_trackBackgroundMin.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    _trackBackgroundMax.frame = CGRectMake((bounds.size.width / 2.0f),
//                                           self.frame.size.height/2-_trackBackgroundMin.frame.size.height/2,
//                                           (bounds.size.width / 2.0f) - _padding,
//                                           _trackBackgroundMin.frame.size.height);
//	_trackBackgroundMax.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    
//	[self addSubview:_trackBackgroundMin];
//    [self addSubview:_trackBackgroundMax];
//    
//    CGPoint center = _minThumb.center;
//	[self addSubview:_minThumb];
//    
//    _minThumb.frame = CGRectMake(0, 0, 110.0f, 110.0f);
//    _minThumb.center = center;
//	_minThumb.contentMode = UIViewContentModeCenter;
//    [_minThumb setAutoresizingMask:UIViewAutoresizingNone];
//    
//	self.minimumValue = 0.0f;
//	self.maximumValue = 1.0f;
//	self.selectedValue = 0.25f;
//    self.valueSnapToInterval = 0.1;
//    
//    [_minThumb setClipsToBounds:NO];
//    [self setClipsToBounds:NO];
//    
//    [self modifyControl:self];
//}

#pragma mark - Base Overrides
#pragma mark -

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect result = [super thumbRectForBounds:bounds trackRect:rect value:value];
    
    // the closer to the center the smaller the offset should be when highlighted
    if (self.isHighlighted) {
        double percentage = getPercentage(self.minimumValue, self.maximumValue, value);
        CGFloat maxOffset = 10;
        if (percentage < 0.5) {
            CGFloat offset = maxOffset * (percentage - 0.5) * 2;
            result = CGRectOffset(result, offset, 0);
        }
        else {
            CGFloat offset = maxOffset * (percentage - 0.5) * 2;
            result = CGRectOffset(result, offset, 0);
        }
    }
    
    return result;
}

- (void)setSelectedValue:(CGFloat)selectedValue {
    [self setSelectedValue:selectedValue animated:FALSE];
}

- (void)setSelectedValue:(CGFloat)selectedValue animated:(BOOL)animated {
    _selectedValue = selectedValue;
    
//    CGFloat duration = animated ? 0.25 : 0.0;
//    
//    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
//    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
//        _minThumb.center = CGPointMake([self xForValue:selectedValue], self.frame.size.height / 2.0);
//    } completion:^(BOOL finished) {
//    }];
}

//- (CGFloat)xForValue:(CGFloat)value {
//	return (self.frame.size.width - (_padding * 2.0)) * ((value - self.minimumValue) / (self.maximumValue - self.minimumValue)) + _padding;
//}
//
//- (CGFloat)valueForX:(CGFloat)x {
//	return self.minimumValue + (x - _padding) / (self.frame.size.width - (_padding * 2.0)) * (self.maximumValue - self.minimumValue);
//}

#pragma mark - Gestures

//- (void)modifyControl:(UIControl *)control {
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognized:)];
//    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognized:)];
//    control.gestureRecognizers = @[tapGestureRecognizer, panGestureRecognizer];
//    
//    self.tapGestureRecognizer = tapGestureRecognizer;
//    self.panGestureRecognizer = panGestureRecognizer;
//}

- (IBAction)gestureRecognized:(id)sender {
//    [self handleSliderGestureRecognizer:(UIGestureRecognizer *)sender];
}

//- (void)valueChanged:(id)sender {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(slider:valueDidChange:)]) {
//        [self.delegate slider:self valueDidChange:self.selectedValue];
//    }
//}

//- (void)handleSliderGestureRecognizer:(UIGestureRecognizer *)recognizer {
//    if (_vibeFeel == YES) return;
//    
//    switch (recognizer.state) {
//        case UIGestureRecognizerStateBegan:
//            [_minThumb setHighlighted:YES];
//            break;
//        case UIGestureRecognizerStateChanged:
//            // do nothing
//            break;
//        case UIGestureRecognizerStateEnded:
//        case UIGestureRecognizerStateCancelled:
//        case UIGestureRecognizerStateFailed:
//            [_minThumb setHighlighted:NO];
//            break;
//            
//        default:
//            // do nothing
//            break;
//    }
//    
//    if (recognizer.state == UIGestureRecognizerStateBegan ||
//        recognizer.state == UIGestureRecognizerStateChanged ||
//        recognizer.state == UIGestureRecognizerStateEnded) {
//        if ([recognizer.view isKindOfClass:[SHSlider class]]) {
//            SHSlider *slider = (SHSlider *)recognizer.view;
//            CGPoint point = [recognizer locationInView:recognizer.view];
//            CGFloat width = CGRectGetWidth(slider.frame);
//            CGFloat percentage = MAX(0.0, MIN(1.0, point.x / width)); // bound to 0.0 to 1.0
//            
//            // new value is based on the slider's min and max values which
//            // could be different with each slider
//            CGFloat newValue = ((slider.maximumValue - slider.minimumValue) * percentage) + slider.minimumValue;
//            
//            [slider setSelectedValue:newValue]; // ensures thumb control is opaque after value is set from the default
//            if (self.delegate && [self.delegate respondsToSelector:@selector(slider:valueDidChange:)]) {
//                [self.delegate slider:self valueDidChange:self.selectedValue];
//            }
//            
//            if (recognizer.state == UIGestureRecognizerStateEnded && self.delegate && [self.delegate respondsToSelector:@selector(slider:valueDidFinishChanging:)]) {
//                [self.delegate slider:self valueDidFinishChanging:self.selectedValue];
//            }
//        }
//        
//    }
//    
//    [self sendActionsForControlEvents:UIControlEventValueChanged];
//}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // ensure the pan gesture does not handle vertical movement
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIView *view = [gestureRecognizer view];
        CGPoint translation = [gestureRecognizer translationInView:[view superview]];
        // Check for horizontal gesture
        return fabsf(translation.x) > fabsf(translation.y);
    }
    
    return YES;
}

//- (void)turnOff {
//    _minThumbOn = FALSE;
//	_maxThumbOn = FALSE;
//    
//    [_trackBackgroundMin setHighlighted:NO];
//    [_trackBackgroundMax setHighlighted:NO];
//    [_minThumb setHighlighted:NO];
//}

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
    // TODO: rewrite
//    if (_vibeFeel == NO) {
//        [_trackBackgroundMin setImage:[[UIImage imageNamed:( _userMoved ? @"slider_background_selected_min" : @"slider_background_min" )] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 0)]];
//        [_trackBackgroundMin setHighlightedImage:[[UIImage imageNamed:@"slider_background_selected_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 0)]];
//        
//        [_trackBackgroundMax setImage:[[UIImage imageNamed:( _userMoved ? @"slider_background_selected_max" : @"slider_background_max" )] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 25)]];
//        [_trackBackgroundMax setHighlightedImage:[[UIImage imageNamed:@"slider_background_selected_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 25)]];
//        
//        
//        // Load up the handle images so we can measure them
//        [_minThumb setImage:[UIImage imageNamed: _userMoved ? @"slider_thumb_selected" : @"slider_thumb"]];
//        [_minThumb setHighlightedImage:[UIImage imageNamed:@"slider_thumb_selected_with_light"]];
//    } else {
//        [_trackBackgroundMin setImage:[[UIImage imageNamed:@"slider_background_profile_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 0)]];
//        [_trackBackgroundMin setHighlightedImage:[[UIImage imageNamed:@"slider_background_profile_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 25, 0, 0)]];
//        
//        [_trackBackgroundMax setImage:[[UIImage imageNamed:@"slider_background_profile_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 25)]];
//        [_trackBackgroundMax setHighlightedImage:[[UIImage imageNamed:@"slider_background_profile_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 25)]];
//        
//        
//        // Load up the handle images so we can measure them
//        [_minThumb setImage:[UIImage imageNamed:@"slider_profile_thumb"]];
//        [_minThumb setHighlightedImage:[UIImage imageNamed:@"slider_profile_thumb"]];
//    }
}

#pragma mark - Custom Images
#pragma mark -

- (UIImage *)drawTrackImage {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIColor *trackColor = [SHStyleKit color:SHStyleKitColorMyTintColor];
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(200, 2), NO, 0.0f);
        
        // START DRAWING
        {
            
            //// Rectangle Drawing
            UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 200, 2)];
            [trackColor setFill];
            [rectanglePath fill];
            
        }
        // END DRAWING
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return image;
}

- (UIImage *)drawNormalThumbImage {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(20, 20), NO, 0.0f);
        
        // START DRAWING
        {
            
            //// Group
            {
                //// Shadow Drawing
                UIBezierPath* shadowPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0.5, 2.5, 17, 17)];
                [UIColor.grayColor setFill];
                [shadowPath fill];
                
                
                //// Circle Drawing
                UIBezierPath* circlePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(2, 1, 17, 17)];
                [UIColor.whiteColor setFill];
                [circlePath fill];
                [UIColor.blackColor setStroke];
                circlePath.lineWidth = 1;
                [circlePath stroke];
            }
            
        }
        // END DRAWING
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return image;
}

- (UIImage *)drawHighlightedThumbImage {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 40), NO, 0.0f);
        
        // START DRAWING
        {
            
            //// Color Declarations
            UIColor* myWhiteTranslucent = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.494];
            
            //// Glow Drawing
            UIBezierPath* glowPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(2, 2, 36, 36)];
            [myWhiteTranslucent setFill];
            [glowPath fill];
            
            
            //// Shadow Drawing
            UIBezierPath* shadowPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(10.5, 12.5, 17, 17)];
            [UIColor.grayColor setFill];
            [shadowPath fill];
            
            
            //// Circle Drawing
            UIBezierPath* circlePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(12, 11, 17, 17)];
            [UIColor.whiteColor setFill];
            [circlePath fill];
            [UIColor.blackColor setStroke];
            circlePath.lineWidth = 1;
            [circlePath stroke];
            
        }
        // END DRAWING
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return image;
}

@end
