//
//  SpotCalloutView.m
//  SpotHopper
//
//  Created by Brennan Stehling on 6/25/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SpotCalloutView.h"

#import "SHStyleKit+Additions.h"

NSString * const SpotCalloutViewIdentifier = @"SpotCalloutView";

#define kHeightOfArrow 14
#define kWidthOfArrow 20

#pragma mark - Class Extension
#pragma mark -

@interface SpotCalloutView ()

@property (weak, nonatomic, readwrite) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *spotNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *drink1Label;
@property (weak, nonatomic) IBOutlet UILabel *drink2Label;

@end

@implementation SpotCalloutView

#pragma mark - Public
#pragma mark -

- (void)setIcon:(SpotCalloutIcon)icon spotNameText:(NSString *)spotNameText drink1Text:(NSString *)drink1Text drink2Text:(NSString *)drink2Text {
    CGSize iconSize = CGSizeMake(40.0f, 40.f);
    
    switch (icon) {
        case SpotCalloutIconBeerOnTap:
            self.iconImageView.image = [SHStyleKit drawImage:SHStyleKitDrawingBeerIcon color:SHStyleKitColorMyTintColor size:iconSize];
            break;
        case SpotCalloutIconBeerInBottle:
            self.iconImageView.image = [SHStyleKit drawImage:SHStyleKitDrawingBeerIcon color:SHStyleKitColorMyTintColor size:iconSize];
            break;
        case SpotCalloutIconBeerOnTapAndInBottle:
            self.iconImageView.image = [SHStyleKit drawImage:SHStyleKitDrawingBeerIcon color:SHStyleKitColorMyTintColor size:iconSize];
            break;
        case SpotCalloutIconCocktail:
            self.iconImageView.image = [SHStyleKit drawImage:SHStyleKitDrawingCocktailIcon color:SHStyleKitColorMyTintColor size:iconSize];
            break;
        case SpotCalloutIconWine:
            self.iconImageView.image = [SHStyleKit drawImage:SHStyleKitDrawingWineIcon color:SHStyleKitColorMyTintColor size:iconSize];
            
            break;
            
        default:
            self.iconImageView.image = nil;
            break;
    }
    
    if (spotNameText.length) {
        self.spotNameLabel.text = spotNameText;
    }
    else {
        self.spotNameLabel.text = nil;
    }
    
    if (drink1Text.length) {
        self.drink1Label.text = drink1Text;
    }
    else {
        self.drink1Label.text = nil;
    }

    if (drink2Text.length) {
        self.drink2Label.text = drink2Text;
    }
    else {
        self.drink2Label.text = nil;
    }

    if (self.superview) {
        [self adjustHeightWithIntrinsicSize];
    }
}

#pragma mark - Private
#pragma mark -

- (void)adjustHeightWithIntrinsicSize {
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    CGRect frame = self.frame;
    frame.size.height = CGRectGetHeight(self.containerView.frame) + kHeightOfArrow;
    self.frame = frame;
    
    UIImage *backgroundImage = [self drawRoundedCorners:self.frame.size position:0.5 borderRadius:10 strokeWidth:1];
    self.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
}

- (UIImage *)drawRoundedCorners:(CGSize)size position:(CGFloat)position borderRadius:(CGFloat)borderRadius strokeWidth:(CGFloat)strokeWidth {
    CGSize arrowSize = CGSizeMake(kWidthOfArrow, kHeightOfArrow);
    
    // define the 4 sides
    CGFloat left = strokeWidth;
    CGFloat right = size.width - strokeWidth;
    CGFloat top = strokeWidth;
    CGFloat bottom = size.height - strokeWidth - arrowSize.height;
    
    // define the 4 corners (started at top/left going clockwise)
    CGPoint point1 = CGPointMake(left, top);
    CGPoint point2 = CGPointMake(right, top);
    CGPoint point3 = CGPointMake(right, bottom);
    CGPoint point4 = CGPointMake(left, bottom);
    
    // define the points where each rounded corner will start and end (started at top/left going clockwise)
    CGPoint pointA __unused = CGPointMake(left, top + borderRadius);
    CGPoint pointB = CGPointMake(left + borderRadius, top);
    CGPoint pointC __unused = CGPointMake(right - borderRadius, top);
    CGPoint pointD = CGPointMake(right, top + borderRadius);
    CGPoint pointE __unused = CGPointMake(right, bottom - borderRadius);
    CGPoint pointF = CGPointMake(right - borderRadius, bottom);
    CGPoint pointG = CGPointMake(left + borderRadius, bottom);
    CGPoint pointH = CGPointMake(left, bottom - borderRadius);
    
    // define arrow position
    CGFloat arrowMiddle = size.width * position;
    CGPoint arrowLeftBase = CGPointMake(arrowMiddle - (arrowSize.width/2), bottom);
    CGPoint arrowRightBase = CGPointMake(arrowMiddle + (arrowSize.width/2), bottom);
    CGPoint arrowPoint = CGPointMake(arrowMiddle, bottom + arrowSize.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.9].CGColor);
    
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, pointB.x, pointB.y);
    
    // CGContextAddArcToPoint
    // Note: the first point is where the hard corner would be without corner radius and the 2nd point is where the line ends
    
    CGContextAddArcToPoint(context, point2.x, point2.y, pointD.x, pointD.y, borderRadius);
    CGContextAddArcToPoint(context, point3.x, point3.y, pointF.x, pointF.y, borderRadius);
    
    // draw arrow if the position is not zero
    if (position > 0) {
        // line from F to right arrow base
        CGContextAddLineToPoint(context, arrowRightBase.x, arrowRightBase.y);
        
        // to arrow point then left base
//        CGContextAddArcToPoint(context, arrowPoint.x, arrowPoint.y, arrowLeftBase.x, arrowLeftBase.y, borderRadius/4);
        
        // line from right arrow base to arrow point
        CGContextAddLineToPoint(context, arrowPoint.x, arrowPoint.y);
        // line from arrow point to left arrow base
        CGContextAddLineToPoint(context, arrowLeftBase.x, arrowLeftBase.y);
        
        // line from left arrow base to G
        CGContextAddLineToPoint(context, pointG.x, pointG.y);
    }
    
    CGContextAddArcToPoint(context, point4.x, point4.y, pointH.x, pointH.y, borderRadius);
    CGContextAddArcToPoint(context, point1.x, point1.y, pointB.x, pointB.y, borderRadius);
    
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
