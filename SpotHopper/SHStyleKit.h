//
//  SHStyleKit.h
//  SpotHopper
//
//  Created by SpotHopper on 6/5/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import <Foundation/Foundation.h>


@interface SHStyleKit : NSObject

// iOS Controls Customization Outlets
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* wineIconTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* specialsIconTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* spotIconTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* cocktailIconTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* beerIconTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* navigationArrowIconTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* searchIconTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* spotSideBarIconTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* featuredListIconTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* arrowIconTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* drinksIconTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* outlineIconTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* checkMarkIconTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* thumbsUpIconTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* shareIconTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* mapBubblePinFilledIconTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* mapBubblePinEmptyIconTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* gradientBackgroundTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* myPlaceholderTargets;

// Colors
+ (UIColor*)myTintColor;
+ (UIColor*)myTintColorTransparent;
+ (UIColor*)myTextColor;
+ (UIColor*)myWhiteColor;
+ (UIColor*)myBlackColor;
+ (UIColor*)myLightHeaderColor;
+ (UIColor*)myClearColor;
+ (UIColor*)myScreenColor;
+ (UIColor*)myTintColorDesaturated;
+ (UIColor*)myWhiteColorTransparent;

// Drawing Methods
+ (void)drawWineIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawSpecialsIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawSpotIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawCocktailIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawBeerIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawNavigationArrowIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName rotation: (CGFloat)rotation;
+ (void)drawSearchIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawSpotSideBarIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawFeaturedListIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawArrowIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName fillColorName: (NSString*)fillColorName rotation: (CGFloat)rotation;
+ (void)drawDrinksIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawOutlineIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawCheckMarkIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName fillColorName: (NSString*)fillColorName;
+ (void)drawThumbsUpIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName fillColorName: (NSString*)fillColorName;
+ (void)drawShareIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY color1Name: (NSString*)color1Name color2Name: (NSString*)color2Name color3Name: (NSString*)color3Name;
+ (void)drawReviewsIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawDrinkMenuIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawMapBubblePinFilledIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY;
+ (void)drawMapBubblePinEmptyIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY;
+ (void)drawGradientBackgroundWithWidth: (CGFloat)width height: (CGFloat)height scaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY;
+ (void)drawTopBarBackgroundWithFillColorName: (NSString*)fillColorName;
+ (void)drawTopBarWhiteShadowBackground;
+ (void)drawMyPlaceholderWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY;

// Generated Images
+ (UIImage*)imageOfWineIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (UIImage*)imageOfSpecialsIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (UIImage*)imageOfSpotIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (UIImage*)imageOfCocktailIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (UIImage*)imageOfBeerIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (UIImage*)imageOfNavigationArrowIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName rotation: (CGFloat)rotation;
+ (UIImage*)imageOfSearchIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (UIImage*)imageOfSpotSideBarIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (UIImage*)imageOfFeaturedListIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (UIImage*)imageOfArrowIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName fillColorName: (NSString*)fillColorName rotation: (CGFloat)rotation;
+ (UIImage*)imageOfDrinksIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (UIImage*)imageOfOutlineIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (UIImage*)imageOfCheckMarkIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName fillColorName: (NSString*)fillColorName;
+ (UIImage*)imageOfThumbsUpIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName fillColorName: (NSString*)fillColorName;
+ (UIImage*)imageOfShareIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY color1Name: (NSString*)color1Name color2Name: (NSString*)color2Name color3Name: (NSString*)color3Name;
+ (UIImage*)imageOfMapBubblePinFilledIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY;
+ (UIImage*)imageOfMapBubblePinEmptyIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY;
+ (UIImage*)imageOfGradientBackgroundWithWidth: (CGFloat)width height: (CGFloat)height scaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY;
+ (UIImage*)imageOfMyPlaceholderWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY;

@end
