//
//  MatchPercentAnnotationView.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/10/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kXOffset 4.0f
#define kYOffset -2.0f

#define kWidth 40
#define kHeight 40
#define kFontSize 14.0

#define kLargeWidth 60
#define kLargeHeight 60
#define kLargeFontSize 18.0

#import "MatchPercentAnnotationView.h"

#import "SpotModel.h"
#import "SpotTypeModel.h"

#import "SpotAnnotationCallout.h"

#pragma mark - Class Extension
#pragma mark -

@interface MatchPercentAnnotationView ()

@property (weak, nonatomic) UIImageView *pinImageView;
@property (weak, nonatomic) UIImageView *highlightedPinImageView;
@property (weak, nonatomic) UIImageView *innerImageView;
@property (weak, nonatomic) UILabel *percentLabel;
@property (weak, nonatomic) UILabel *highlightedPercentLabel;

@end

@implementation MatchPercentAnnotationView {
    BOOL _isSettingSpot;
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupAnnotation:annotation reuseIdentifier:reuseIdentifier calloutView:nil drawing:SHStyleKitDrawingNone];
    }
    return self;
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier calloutView:(SpotAnnotationCallout *)calloutView {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupAnnotation:annotation reuseIdentifier:reuseIdentifier calloutView:calloutView drawing:SHStyleKitDrawingNone];
    }
    return self;
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier calloutView:(SpotAnnotationCallout *)calloutView drawing:(SHStyleKitDrawing)drawing {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupAnnotation:annotation reuseIdentifier:reuseIdentifier calloutView:calloutView drawing:drawing];
    }
    return self;
}

- (void)setupAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier calloutView:(SpotAnnotationCallout *)calloutView drawing:(SHStyleKitDrawing)drawing {
    self.calloutView = calloutView;
    self.drawing = drawing;
    
    [self addSubviews];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self addSubviews];
    [self setNeedsDisplay];
}

- (void)addSubviews {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    CGFloat width = self.useLargeIcon ? kLargeWidth : kWidth;
    CGFloat height = self.useLargeIcon ? kLargeHeight : kHeight;
    
    self.centerOffset = CGPointMake(width / 3, -1 * (height / 2));
    self.opaque = NO;
    
    /*
    if (self.useLargeIcon) {
        self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.25f];
    }
    else {
        self.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.25f];
    }
     */
    
    self.frame = CGRectMake(0, 0, width, height);
    CGRect imageFrame = CGRectMake(0, 0, width, height);
    CGRect innerFrame = CGRectMake(0, 0, width*0.6f, height*0.6f);
    
    UIImageView *highlightedPinImageView = [[UIImageView alloc] initWithFrame:imageFrame];
    [SHStyleKit setImageView:highlightedPinImageView withDrawing:SHStyleKitDrawingMapBubblePinFilledIcon color:SHStyleKitColorMyWhiteColor];
    [self addSubview:highlightedPinImageView];
    self.highlightedPinImageView = highlightedPinImageView;
    
    UIImageView *pinImageView = [[UIImageView alloc] initWithFrame:imageFrame];
    [SHStyleKit setImageView:pinImageView withDrawing:SHStyleKitDrawingMapBubblePinEmptyIcon color:SHStyleKitColorMyTintColor];
    [self addSubview:pinImageView];
    self.pinImageView = pinImageView;
    
    // frame has to be offset a little to the right due to the shadow below the bubble (about 5% of the width)
    CGFloat shadowOffset = CGRectGetWidth(imageFrame) * 0.05;
    CGRect labelFrame = imageFrame;
    labelFrame.origin.x = shadowOffset;
    
    UILabel *highlightedPercentLabel = [[UILabel alloc] initWithFrame:labelFrame];
    highlightedPercentLabel.textAlignment = NSTextAlignmentCenter;
    highlightedPercentLabel.textColor = [SHStyleKit myWhiteColor];
    [self addSubview:highlightedPercentLabel];
    self.highlightedPercentLabel = highlightedPercentLabel;
    
    UILabel *percentLabel = [[UILabel alloc] initWithFrame:labelFrame];
    percentLabel.textAlignment = NSTextAlignmentCenter;
    percentLabel.textColor = [SHStyleKit myTintColor];
    [self addSubview:percentLabel];
    self.percentLabel = percentLabel;
    
    UIImageView *innerImageView = [[UIImageView alloc] initWithFrame:innerFrame];
    [self addSubview:innerImageView];
    innerImageView.center = CGPointMake((width/2) + shadowOffset, height/2);
    self.innerImageView = innerImageView;
    
    [self drawIcon];
}

- (void)setSpot:(SpotModel *)spot {
    [self setSpot:spot highlighted:FALSE];
}

- (void)setSpot:(SpotModel *)spot highlighted:(BOOL)highlighted {
    if (![_spot isEqual:spot]) {
        _spot = spot;
        
        if (self.drawing != SHStyleKitDrawingNone) {
            self.innerImageView.hidden = FALSE;
            self.percentLabel.hidden = TRUE;
            self.highlightedPercentLabel.hidden = TRUE;
        }
        else if (self.spot.matchPercent.length) {
            self.innerImageView.hidden = TRUE;
            self.percentLabel.hidden = FALSE;
            self.highlightedPercentLabel.hidden = FALSE;
            
            NSDictionary *attributes = @{ NSFontAttributeName : [UIFont fontWithName:@"Lato-Light" size:kFontSize] };
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.spot.matchPercent attributes:attributes];
            self.percentLabel.attributedText = attributedString;
            self.highlightedPercentLabel.attributedText = attributedString;
        }
        else {
            self.percentLabel.hidden = TRUE;
            self.highlightedPercentLabel.hidden = TRUE;
        }
        
        _isSettingSpot = TRUE;
        self.highlighted = highlighted;
        _isSettingSpot = FALSE;
    }
}

- (void)setHighlighted:(BOOL)isHighlighted {
    if (!_isSettingSpot && self.isHighlighted == isHighlighted) {
        return;
    }
    
    [super setHighlighted:isHighlighted];
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.25 delay:0.0 options:options animations:^{
        self.pinImageView.alpha = isHighlighted ? 0.0 : 0.9;
        self.highlightedPinImageView.alpha = isHighlighted ? 1.0 : 0.0;
        self.percentLabel.alpha = isHighlighted ? 0.0 : 1.0;
        self.highlightedPercentLabel.alpha = isHighlighted ? 1.0 : 0.0;
    } completion:^(BOOL finished) {
        if (isHighlighted) {
            [self bounce];
        }
    }];
    
    [self drawIcon];
}

- (void)setCalloutView:(SpotAnnotationCallout *)calloutView {
    _calloutView = calloutView;
    
    [_calloutView.lblName setText:self.spot.name];
    [_calloutView.lblType setText:self.spot.spotType.name];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // Makes callout clickable if touch point was inside callout
    if (CGRectContainsPoint(_calloutView.frame, point)) {
        return YES;
    }
    return NO;
}

- (void)bounce {
    // simply bounce up and back into place the catch the user's attention
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position.y"];
    
    anim.fromValue = [NSNumber numberWithInt:0];
    anim.toValue = [NSNumber numberWithInt:-2];
    anim.duration = 0.15;
    anim.autoreverses = YES;
    anim.repeatCount = 2;
    anim.additive = YES;
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:anim forKey:@"bounceAnimation"];
}

- (void)drawIcon {
    if (self.drawing == SHStyleKitDrawingNone) {
        self.innerImageView.image = nil;
    }
    else {
        if (self.isHighlighted) {
            [SHStyleKit setImageView:self.innerImageView
                         withDrawing:self.drawing
                               color:SHStyleKitColorMyWhiteColor];
        }
        else {
            [SHStyleKit setImageView:self.innerImageView
                         withDrawing:self.drawing
                               color:SHStyleKitColorMyTintColor];
        }
        [self bringSubviewToFront:self.innerImageView];
    }
}

@end
