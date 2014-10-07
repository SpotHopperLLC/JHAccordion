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

@property (nonatomic, weak) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, weak) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, weak) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@implementation SHSlider

#pragma mark - Initialization
#pragma mark -

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (!self) {
		return nil;
	}
    [self customizeSlider:self];
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (!self) {
		return nil;
	}
    [self customizeSlider:self];
	return self;
}

#pragma mark - Customizations
#pragma mark -

- (void)customizeSlider:(UISlider *)slider {
    // add the tap and pan gestures for the added behavior
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderGestureRecognized:)];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderGestureRecognized:)];
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    tapGestureRecognizer.delegate = self;
    panGestureRecognizer.delegate = self;
    longPressGestureRecognizer.delegate = self;
    slider.gestureRecognizers = @[tapGestureRecognizer, panGestureRecognizer, longPressGestureRecognizer];
    
    // ensure the built-in gestures fire the delegate callbacks
    [self addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tapGestureRecognizer = tapGestureRecognizer;
    self.panGestureRecognizer = panGestureRecognizer;

    [self updateView];
}

#pragma mark - Base Overrides
#pragma mark -

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect result = [super thumbRectForBounds:bounds trackRect:rect value:value];
    
    // the highlighted thumb image is large so the size needs to be adjusted by the offset
    // so that when the thumb position is nearer the edges it is positioned appropriately
    
    // the closer to the center the smaller the offset should be when highlighted
    if (self.isHighlighted) {
        double percentage = getPercentage(self.minimumValue, self.maximumValue, value);
        CGFloat maxOffset = 15;
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
    
    CGFloat duration = animated ? 0.25 : 0.0;
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        [self setValue:selectedValue animated:animated];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Gestures
#pragma mark -

- (IBAction)sliderGestureRecognized:(UIGestureRecognizer *)recognizer {
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            self.highlighted = TRUE;
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            self.highlighted = FALSE;
            break;
            
        default:
            break;
    }
    
    if ([recognizer.view isKindOfClass:[UISlider class]]) {
        UISlider *slider = (UISlider *)recognizer.view;
        CGPoint point = [recognizer locationInView:recognizer.view];
        CGFloat width = CGRectGetWidth(slider.frame);
        CGFloat percentage = point.x / width;
        
        // new value is based on the slider's min and max values which
        // could be different with each slider
        CGFloat newValue = ((slider.maximumValue - slider.minimumValue) * percentage) + slider.minimumValue;
        [slider setValue:newValue animated:TRUE];
        [slider sendActionsForControlEvents:UIControlEventValueChanged];
        
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            [self reportValueDidChange];
        }
        else if (recognizer.state == UIGestureRecognizerStateEnded) {
            [self reportValueDidFinishChanging];
        }
    }
}

- (IBAction)longPressGestureRecognized:(UIGestureRecognizer *)recognizer {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    [self reportValueDidReset];
}

- (void)valueChanged:(id)sender {
    [self reportValueDidChange];
}

- (void)touchUpInside:(id)sender {
    [self reportValueDidFinishChanging];
}

- (void)reportValueDidChange {
    self.sliderModel.value = [NSNumber numberWithFloat:(self.value * 10)];
    
    if (!self.isUserMoved) {
        self.userMoved = TRUE;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(slider:valueDidChange:)]) {
        self.selectedValue = self.value;
        [self.delegate slider:self valueDidChange:self.value];
    }
}

- (void)reportValueDidFinishChanging {
    self.sliderModel.value = [NSNumber numberWithFloat:(self.value * 10)];
    if ([self.delegate respondsToSelector:@selector(slider:valueDidFinishChanging:)]) {
        self.selectedValue = self.value;
        [self.delegate slider:self valueDidFinishChanging:self.value];
    }
}

- (void)reportValueDidReset {
    self.value = 0.5;
    self.sliderModel.value = nil;
    self.userMoved = FALSE;
    
    if ([self.delegate respondsToSelector:@selector(sliderValueDidReset:)]) {
        self.selectedValue = self.value;
        [self.delegate sliderValueDidReset:self];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // ensure the pan gesture does not handle vertical movement so sliders do not
    // interfere with scrolling in a table view or other scroll view descendant
    
    BOOL should = YES;
    
    if ([gestureRecognizer isEqual:self.panGestureRecognizer]) {
        UIView *view = [gestureRecognizer view];
        CGPoint translation = [gestureRecognizer translationInView:[view superview]];
        // Check for horizontal gesture
        
        should = fabsf(translation.x) > fabsf(translation.y);
    }
    
    return should;
}

// disabled editing when true and styles it accordingly
- (void)setVibeFeel:(BOOL)vibeFeel {
    if (_vibeFeel != vibeFeel) {
        _vibeFeel = vibeFeel;
        [self updateView];
    }
}

- (void)setUserMoved:(BOOL)userMoved {
    if (_userMoved != userMoved) {
        _userMoved = userMoved;
        [self updateView];
    }
}

- (void)updateView {
    UIImage *setTrackImage = [[self drawSetTrackImage] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    UIImage *unsetTrackImage = [[self drawUnsetTrackImage] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    UIImage *normalThumbImage = [self drawNormalThumbImage];
    UIImage *highlightedThumbImage = [self drawHighlightedThumbImage];
    
    if (self.isVibeFeel) {
        // TODO: replace with drawing from StyleKit (slider_profile_thumb)
        UIImage *vibeThumbImage = [UIImage imageNamed:@"slider_profile_thumb"];
        
        [self setThumbImage:vibeThumbImage forState:UIControlStateNormal];
        [self setThumbImage:vibeThumbImage forState:UIControlStateSelected];
        [self setThumbImage:vibeThumbImage forState:UIControlStateHighlighted];
        
        [self setMinimumTrackImage:unsetTrackImage forState:UIControlStateNormal];
        [self setMaximumTrackImage:unsetTrackImage forState:UIControlStateNormal];
    }
    else {
        [self setThumbImage:normalThumbImage forState:UIControlStateNormal];
        [self setThumbImage:highlightedThumbImage forState:UIControlStateSelected];
        [self setThumbImage:highlightedThumbImage forState:UIControlStateHighlighted];
        
        [self setMinimumTrackImage:(self.isUserMoved ? setTrackImage : unsetTrackImage) forState:UIControlStateNormal];
        [self setMaximumTrackImage:(self.isUserMoved ? setTrackImage : unsetTrackImage) forState:UIControlStateNormal];
    }
}

#pragma mark - Custom Images
#pragma mark -

- (UIImage *)drawSetTrackImage {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIColor *trackColor = [UIColor colorWithRed:0.90 green:0.65 blue:0.47 alpha:1.0];
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(200, 3), NO, 0.0f);
        
        // START DRAWING
        {
            
            //// Rectangle Drawing
            UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 200, 3)];
            [trackColor setFill];
            [rectanglePath fill];
            
        }
        // END DRAWING
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    return image;
}

- (UIImage *)drawUnsetTrackImage {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIColor *trackColor = [UIColor lightGrayColor];
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(200, 3), NO, 0.0f);
        
        // START DRAWING
        {
            
            //// Rectangle Drawing
            UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 200, 3)];
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
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0.0f);
        
        // START DRAWING
        {
            
            //// Shadow Drawing
            UIBezierPath* shadowPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(1.5, 2, 27, 27)];
            [UIColor.lightGrayColor setFill];
            [shadowPath fill];
            
            
            //// Circle Drawing
            UIBezierPath* circlePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(1.5, 1.5, 27, 27)];
            [UIColor.whiteColor setFill];
            [circlePath fill];
            [UIColor.lightGrayColor setStroke];
            circlePath.lineWidth = 1;
            [circlePath stroke];
            
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
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(60, 60), NO, 0.0f);
        
        // START DRAWING
        {
            
            //// Color Declarations
            UIColor* myWhiteTranslucent = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.494];
            
            //// Glow Drawing
            UIBezierPath* glowPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(3, 3, 54, 54)];
            [myWhiteTranslucent setFill];
            [glowPath fill];
            
            
            //// Shadow Drawing
            UIBezierPath* shadowPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(16.5, 17, 27, 27)];
            [UIColor.lightGrayColor setFill];
            [shadowPath fill];
            
            
            //// Circle Drawing
            UIBezierPath* circlePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(16.5, 16.5, 27, 27)];
            [UIColor.whiteColor setFill];
            [circlePath fill];
            [UIColor.lightGrayColor setStroke];
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
