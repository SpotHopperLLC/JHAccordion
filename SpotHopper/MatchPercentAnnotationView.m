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

#import "MatchPercentAnnotationView.h"

#import "SpotModel.h"
#import "SpotTypeModel.h"

#import "SpotAnnotationCallout.h"

#pragma mark - Class Extension
#pragma mark -

@interface MatchPercentAnnotationView ()

@property (weak, nonatomic) UIImageView *pinImageView;
@property (weak, nonatomic) UIImageView *innerImageView;
@property (weak, nonatomic) UILabel *percentLabel;

@end

@implementation MatchPercentAnnotationView

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
    
    self.centerOffset = CGPointMake(kWidth / 3, -1 * (kHeight / 2));
    self.opaque = NO;
    
    //self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.25f];
    
    CGFloat width = kWidth;
    CGFloat height = kHeight;
    
    self.frame = CGRectMake(0, 0, width, height);
    CGRect imageFrame = CGRectMake(0, 0, width, height);
    CGRect innerFrame = CGRectMake(0, 0, width*2/3, height*2/3);
    
    UIImageView *pinImageView = [[UIImageView alloc] initWithFrame:imageFrame];
    [self addSubview:pinImageView];
    self.pinImageView = pinImageView;
    
    // frame has to be offset a little to the right due to the shadow below the bubble (about 5% of the width)
    CGFloat shadowOffset = CGRectGetWidth(imageFrame) * 0.05;
    
    CGRect labelFrame = imageFrame;
    labelFrame.origin.x = shadowOffset;
    UILabel *percentLabel = [[UILabel alloc] initWithFrame:labelFrame];
    percentLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:percentLabel];
    self.percentLabel = percentLabel;
    
    UIImageView *innerImageView = [[UIImageView alloc] initWithFrame:innerFrame];
    [self addSubview:innerImageView];
    innerImageView.center = CGPointMake((kWidth/2) + shadowOffset, kHeight/2);
    self.innerImageView = innerImageView;
}

- (void)setSpot:(SpotModel *)spot {
    if (![_spot isEqual:spot]) {
        _spot = spot;
        
        if (!spot.match) {
            self.percentLabel.hidden = TRUE;
        }
        else if (self.drawing != SHStyleKitDrawingNone) {
            self.innerImageView.hidden = FALSE;
            self.percentLabel.hidden = TRUE;
        }
        else {
            self.innerImageView.hidden = TRUE;
            self.percentLabel.hidden = FALSE;
        }
        [self setHighlighted:FALSE];
    }
}

- (void)setHighlighted:(BOOL)isHighlighted {
    [super setHighlighted:isHighlighted];
    
    self.pinImageView.alpha = isHighlighted ? 1.0 : 0.9;
    
    if (self.isHighlighted) {
        [SHStyleKit setImageView:self.pinImageView withDrawing:SHStyleKitDrawingMapBubblePinFilledIcon color:SHStyleKitColorMyWhiteColor];
        if (self.drawing != SHStyleKitDrawingNone) {
            [SHStyleKit setImageView:self.innerImageView
                         withDrawing:self.drawing color:SHStyleKitColorMyWhiteColor];
        }
    }
    else {
        [SHStyleKit setImageView:self.pinImageView withDrawing:SHStyleKitDrawingMapBubblePinEmptyIcon color:SHStyleKitColorMyTintColor];
        if (self.drawing != SHStyleKitDrawingNone) {
            [SHStyleKit setImageView:self.innerImageView withDrawing:self.drawing color:SHStyleKitColorMyTintColor];
        }
    }
    self.pinImageView.alpha = isHighlighted ? 1.0 : 0.9;
    [self bringSubviewToFront:self.innerImageView];
    
    if (self.spot.matchPercent.length) {
        NSDictionary *attributes = @{
                                     NSFontAttributeName : [UIFont fontWithName:@"Lato-Light" size:kFontSize],
                                     NSForegroundColorAttributeName: ( isHighlighted ?  [UIColor whiteColor] : kColorOrange)
                                     };

        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.spot.matchPercent attributes:attributes];
        self.percentLabel.attributedText = attributedString;
    }
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

@end
