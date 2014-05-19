//
//  MatchPercentAnnotationView.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/10/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kXOffset 4.0f
#define kYOffset -2.0f

#define kWidth 60
#define kHeight 60

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
    
    UILabel *percentLabel = [[UILabel alloc] initWithFrame:imageFrame];
    percentLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:percentLabel];
    self.percentLabel = percentLabel;
    
    UIImageView *innerImageView = [[UIImageView alloc] initWithFrame:innerFrame];
    [self addSubview:innerImageView];
    innerImageView.center = CGPointMake(kWidth/2, kHeight/2);
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
            // Gets attributes for string - uses for string size and actually drawing
            NSDictionary *attributes = @{
                                         NSFontAttributeName : [UIFont fontWithName:@"Lato-Light" size:22.0],
                                         NSForegroundColorAttributeName: ( self.isHighlighted ? kColorOrange : [UIColor whiteColor] )
                                         };
            
            // Gets string size
            NSString *string = self.spot.matchPercent;
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
            self.percentLabel.attributedText = attributedString;
        }
        [self setHighlighted:FALSE];
    }
}

- (void)setHighlighted:(BOOL)isHighlighted {
    [super setHighlighted:isHighlighted];
    
    self.pinImageView.alpha = isHighlighted ? 1.0 : 0.9;
    
    if (self.isHighlighted) {
        [SHStyleKit setImageView:self.pinImageView withDrawing:SHStyleKitDrawingMapBubblePinEmptyIcon color:SHStyleKitColorMyTintColor];
        if (self.drawing != SHStyleKitDrawingNone) {
            [SHStyleKit setImageView:self.innerImageView
                         withDrawing:self.drawing color:SHStyleKitColorMyTintColor];
        }
    }
    else {
        [SHStyleKit setImageView:self.pinImageView withDrawing:SHStyleKitDrawingMapBubblePinFilledIcon color:SHStyleKitColorMyWhiteColor];
        if (self.drawing != SHStyleKitDrawingNone) {
            [SHStyleKit setImageView:self.innerImageView withDrawing:self.drawing color:SHStyleKitColorMyWhiteColor];
        }
    }
    self.pinImageView.alpha = isHighlighted ? 1.0 : 0.9;
    [self bringSubviewToFront:self.innerImageView];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont fontWithName:@"Lato-Light" size:22.0],
                                 NSForegroundColorAttributeName: ( isHighlighted ? kColorOrange : [UIColor whiteColor] )
                                 };
    
    NSString *string = self.spot.matchPercent;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    self.percentLabel.attributedText = attributedString;
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
