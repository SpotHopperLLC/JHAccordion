//
//  SHStyleKit.h
//  SpotHopper
//
//  Created by SpotHopper on 5/20/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import <Foundation/Foundation.h>


@interface SHStyleKit : NSObject

// Colors
+ (UIColor*)myTintColor;
+ (UIColor*)myTintColorTransparent;
+ (UIColor*)myTextColor;
+ (UIColor*)myWhiteColor;
+ (UIColor*)myLightHeaderColor;
+ (UIColor*)myClearColor;
+ (UIColor*)myScreenColor;

// Drawing Methods
+ (void)drawWineIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawSpecialsIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawSpotIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawCocktailIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawBeerIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawNavigationArrowIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawNextArrowIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawSearchIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawSpotSideBarIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawFeaturedListIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawPreviousArrowIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawDrinksIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawOutlineIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawCheckMarkIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName fillColorName: (NSString*)fillColorName;
+ (void)drawThumbsUpIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName fillColorName: (NSString*)fillColorName;
+ (void)drawShareIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY color1Name: (NSString*)color1Name color2Name: (NSString*)color2Name color3Name: (NSString*)color3Name;
+ (void)drawMapBubblePinFilledIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY;
+ (void)drawMapBubblePinEmptyIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY;
+ (void)drawGradientBackgroundWithWidth: (CGFloat)width height: (CGFloat)height scaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY;

@end
