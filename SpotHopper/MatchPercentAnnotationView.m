//
//  MatchPercentAnnotationView.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/10/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kXOffset 4.0f
#define kYOffset -2.0f

#import "MatchPercentAnnotationView.h"

#import "SpotModel.h"
#import "SpotTypeModel.h"

#import "SHStyleKit+Additions.h"

#import "SpotAnnotationCallout.h"

#pragma mark - Class Extension
#pragma mark -

@interface MatchPercentAnnotationView ()

@property (weak, nonatomic) UIImageView *pinImageView;
@property (weak, nonatomic) UILabel *percentLabel;

@end

@implementation MatchPercentAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier spot:(SpotModel *)spot calloutView:(SpotAnnotationCallout *)calloutView {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.calloutView = calloutView;
        
        //self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5f];
        
        self.frame = CGRectMake(0, 0, 60, 60);
        self.opaque = NO;
        
        CGRect imageFrame = CGRectMake(0, 0, 60, 60);
        
        UIImageView *pinImageView = [[UIImageView alloc] initWithFrame:imageFrame];
        [self addSubview:pinImageView];
        self.pinImageView = pinImageView;
        
        UILabel *percentLabel = [[UILabel alloc] initWithFrame:imageFrame];
        percentLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:percentLabel];
        self.percentLabel = percentLabel;
        
        self.centerOffset = CGPointMake(20, -30);
        
        [self setSpot:spot];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setSpot:(SpotModel *)spot {
    if (![_spot isEqual:spot]) {
        _spot = spot;
        
        if (!spot.match) {
            self.percentLabel.hidden = TRUE;
        }
        else {
            self.percentLabel.hidden = FALSE;
            // Gets attrbutes for string - uses for string size and actually drawing
            NSDictionary *attributes = @{
                                         NSFontAttributeName : [UIFont fontWithName:@"Lato-Light" size:22.0],
                                         NSForegroundColorAttributeName: ( self.isHighlighted ? kColorOrange : [UIColor whiteColor] )
                                         };
            
            // Gets string size
            NSString *string = _spot.matchPercent;
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
    }
    else {
        [SHStyleKit setImageView:self.pinImageView withDrawing:SHStyleKitDrawingMapBubblePinFilledIcon color:SHStyleKitColorMyWhiteColor];
    }
    self.pinImageView.alpha = isHighlighted ? 1.0 : 0.9;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont fontWithName:@"Lato-Light" size:22.0],
                                 NSForegroundColorAttributeName: ( isHighlighted ? kColorOrange : [UIColor whiteColor] )
                                 };
    
    NSString *string = _spot.matchPercent;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    self.percentLabel.attributedText = attributedString;
}

- (void)setCalloutView:(SpotAnnotationCallout *)calloutView {
    _calloutView = calloutView;
    
    [_calloutView.lblName setText:_spot.name];
    [_calloutView.lblType setText:_spot.spotType.name];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // Makes callout clickable if touch point was inside callout
    if (CGRectContainsPoint(_calloutView.frame, point)) {
        return YES;
    }
    return NO;
}

@end
