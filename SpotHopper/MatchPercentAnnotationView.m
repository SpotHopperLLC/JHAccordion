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

@implementation MatchPercentAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, 72, 62);
        self.opaque = NO;
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
//    [self setImage:[UIImage imageNamed:@"img_match_pin_view"]];
//    [self setHighlighted:NO];
}

- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextClearRect(context, rect);
    
    UIImage *image = [UIImage imageNamed:@"img_match_pin_view"];
    [image drawInRect:rect];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName : [UIFont fontWithName:@"Lato-Light" size:22.0],
                                 NSForegroundColorAttributeName: [UIColor whiteColor]
                                 };
    
    NSString *string = _spot.matchPercent;
    CGSize sizeOfString = [string sizeWithAttributes:attributes];
    [string drawInRect:CGRectMake(((CGRectGetWidth(rect) - sizeOfString.width) / 2.0f) + kXOffset, ((CGRectGetHeight(rect) - sizeOfString.height) / 2.0f) + kYOffset, sizeOfString.width, sizeOfString.height) withAttributes:attributes];
    
}


@end
