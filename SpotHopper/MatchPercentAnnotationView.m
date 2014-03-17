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

#import "SpotAnnotationCallout.h"

@implementation MatchPercentAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, 72, 62);
        self.opaque = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setCalloutView:(SpotAnnotationCallout *)calloutView {
    _calloutView = calloutView;
    
    [_calloutView.lblName setText:_spot.name];
    [_calloutView.lblType setText:_spot.spotType.name];
}

- (void)drawRect:(CGRect)rect {

    if (_spot.match == nil) {
        // NO MATCH - just a normal image
        UIImage *image = [UIImage imageNamed:@"img_spot_pin_view"];
        [image drawInRect:rect];
    } else {
        // Determines which image to draw (depends on if highlighted or not)
        UIImage *image = [UIImage imageNamed:( self.isHighlighted ? @"img_match_pin_view_selected" : @"img_match_pin_view" )];
        [image drawInRect:rect];
        
        // Gets attrbutes for string - uses for string size and actually drawing
        NSDictionary *attributes = @{
                                     NSFontAttributeName : [UIFont fontWithName:@"Lato-Light" size:22.0],
                                     NSForegroundColorAttributeName: ( self.isHighlighted ? kColorOrange : [UIColor whiteColor] )
                                     };
        
        // Gets string size
        NSString *string = _spot.matchPercent;
        CGSize sizeOfString = [string sizeWithAttributes:attributes];
        
        // Calculates x and y of rect to draw string in (it will appear in the middle of the bubble
        CGFloat x = ((CGRectGetWidth(rect) - sizeOfString.width) / 2.0f) + kXOffset;
        CGFloat y = ((CGRectGetHeight(rect) - sizeOfString.height) / 2.0f) + kYOffset;
        CGFloat width = sizeOfString.width;
        CGFloat height = sizeOfString.height;
        
        [string drawInRect:CGRectMake(x, y, width, height) withAttributes:attributes];
    }
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // Makes callout clickable if touch point was inside callout
    if (CGRectContainsPoint(_calloutView.frame, point)) {
        return YES;
    }
    return NO;
}

@end
