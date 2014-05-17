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
        self.spot = spot;
        self.calloutView = calloutView;
        
        self.frame = CGRectMake(0, 0, 72, 62);
        self.opaque = NO;
        
        if (!self.spot.match) {
            UIImageView *pinImageView = [[UIImageView alloc] initWithFrame:self.frame];
            pinImageView.image = [UIImage imageNamed:@"img_spot_pin_view"];
            [self addSubview:pinImageView];
            self.pinImageView = pinImageView;
        }
        else {
            UIImage *image = [UIImage imageNamed:( self.isHighlighted ? @"img_match_pin_view_selected" : @"img_match_pin_view" )];
            UIImageView *pinImageView = [[UIImageView alloc] initWithFrame:self.frame];
            pinImageView.image = image;
            [self addSubview:pinImageView];
            self.pinImageView = pinImageView;
            
            self.pinImageView.alpha = self.isHighlighted ? 1.0 : 0.9;

            // Gets attrbutes for string - uses for string size and actually drawing
            NSDictionary *attributes = @{
                                         NSFontAttributeName : [UIFont fontWithName:@"Lato-Light" size:22.0],
                                         NSForegroundColorAttributeName: ( self.isHighlighted ? kColorOrange : [UIColor whiteColor] )
                                         };

            // Gets string size
            NSString *string = _spot.matchPercent;
            CGSize sizeOfString = [string sizeWithAttributes:attributes];
            
            // Calculates x and y of rect to draw string in (it will appear in the middle of the bubble
            CGFloat x = ((CGRectGetWidth(self.frame) - sizeOfString.width) / 2.0f) + kXOffset;
            CGFloat y = ((CGRectGetHeight(self.frame) - sizeOfString.height) / 2.0f) + kYOffset;
            CGFloat width = sizeOfString.width;
            CGFloat height = sizeOfString.height;
            
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
            
            UILabel *percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
            percentLabel.attributedText = attributedString;
            [self addSubview:percentLabel];
            self.percentLabel = percentLabel;
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setHighlighted:(BOOL)isHighlighted {
    [super setHighlighted:isHighlighted];
    
    UIImage *image = [UIImage imageNamed:( isHighlighted ? @"img_match_pin_view_selected" : @"img_match_pin_view" )];
    self.pinImageView.image = image;
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
