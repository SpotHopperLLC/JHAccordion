//
//  SHStyleKit.h
//  SpotHopper
//
//  Created by SpotHopper on 9/19/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class PCGradient;

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
+ (UIColor*)myTintTransparentColor;
+ (UIColor*)myTextColor;
+ (UIColor*)myWhiteColor;
+ (UIColor*)myBlackColor;
+ (UIColor*)myLightHeaderColor;
+ (UIColor*)myPencilColor;
+ (UIColor*)myClearColor;
+ (UIColor*)myScreenColor;
+ (UIColor*)myTintDesaturatedColor;
+ (UIColor*)myWhiteTransparentColor;
+ (UIColor*)myBlackTransparentColor;
+ (UIColor*)myTextTransparentColor;

// Gradients
+ (PCGradient*)myWhiteShadowGradient;
+ (PCGradient*)myDarkShadowGradient;
+ (PCGradient*)myLightShadowGradient;

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
+ (void)drawWineDrinklistIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawBeerDrinklistIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawCocktailDrinklistIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawFillerUpIconWithYPos: (CGFloat)yPos;
+ (void)drawDeleteIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawDefaultAvatarIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawCloseIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY fillColorName: (NSString*)fillColorName;
+ (void)drawTapIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawBottleAndTapIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawBottleIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawSimilarWineIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawSimilarCocktailIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawSimilarBeerIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawSimilarSpotIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName;
+ (void)drawStarIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName fillColorName: (NSString*)fillColorName;
+ (void)drawMoreIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY fillColorName: (NSString*)fillColorName;
+ (void)drawClockIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY fillColorName: (NSString*)fillColorName;
+ (void)drawPhoneIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY fillColorName: (NSString*)fillColorName;
+ (void)drawMapBubblePinFilledIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY;
+ (void)drawMapBubblePinEmptyIconWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY;
+ (void)drawCalloutBackgroundImage;
+ (void)drawGradientBackgroundWithWidth: (CGFloat)width height: (CGFloat)height scaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY;
+ (void)drawTopBarBackgroundWithFillColorName: (NSString*)fillColorName;
+ (void)drawTopBarWhiteShadowBackground;
+ (void)drawBottomBarBlackShadowBackground;
+ (void)drawTopShadow;
+ (void)drawMyPlaceholderWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY;
+ (void)drawPencilArrowWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY rotation: (CGFloat)rotation;
+ (void)drawSwooshRatingWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY strokeColorName: (NSString*)strokeColorName fillColorName: (NSString*)fillColorName position: (CGFloat)position;
+ (void)drawRatingStarsWithScaleX: (CGFloat)scaleX scaleY: (CGFloat)scaleY fillColorName: (NSString*)fillColorName percentage: (CGFloat)percentage;

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



@interface PCGradient : NSObject
@property(nonatomic, readonly) CGGradientRef CGGradient;
- (CGGradientRef)CGGradient NS_RETURNS_INNER_POINTER;

+ (instancetype)gradientWithColors: (NSArray*)colors locations: (const CGFloat*)locations;
+ (instancetype)gradientWithStartingColor: (UIColor*)startingColor endingColor: (UIColor*)endingColor;

@end
