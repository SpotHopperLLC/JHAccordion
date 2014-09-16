//
//  SHStyleKit+Additions.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/14/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

extern NSString * const SHStyleKitColorNameMyTintColor;
extern NSString * const SHStyleKitColorNameMyTintTransparentColor;
extern NSString * const SHStyleKitColorNameMyTextColor;
extern NSString * const SHStyleKitColorNameMyTextTransparentColor;
extern NSString * const SHStyleKitColorNameMyWhiteColor;
extern NSString * const SHStyleKitColorNameMyWhiteTransparentColor;
extern NSString * const SHStyleKitColorNameMyBlackColor;
extern NSString * const SHStyleKitColorNameMyPencilColor;
extern NSString * const SHStyleKitColorNameMyClearColor;

typedef enum {
    SHStyleKitColorNone = 0,
    SHStyleKitColorMyTintColor,
    SHStyleKitColorMyTintTransparentColor,
    SHStyleKitColorMyTextColor,
    SHStyleKitColorMyTextTransparentColor,
    SHStyleKitColorMyWhiteColor,
    SHStyleKitColorMyWhiteTransparentColor,
    SHStyleKitColorMyBlackColor,
    SHStyleKitColorMyPencilColor,
    SHStyleKitColorMyClearColor
} SHStyleKitColor;

typedef enum {
    SHStyleKitDrawingNone = 0,
    SHStyleKitDrawingSpotIcon,
    SHStyleKitDrawingSpecialsIcon,
    SHStyleKitDrawingBeerIcon,
    SHStyleKitDrawingCocktailIcon,
    SHStyleKitDrawingWineIcon,
    SHStyleKitDrawingSimilarSpotIcon,
    SHStyleKitDrawingSimilarBeerIcon,
    SHStyleKitDrawingSimilarCocktailIcon,
    SHStyleKitDrawingSimilarWineIcon,
    SHStyleKitDrawingBottleIcon,
    SHStyleKitDrawingTapIcon,
    SHStyleKitDrawingBottleAndTapIcon,
    SHStyleKitDrawingBeerDrinklistIcon,
    SHStyleKitDrawingCocktailDrinklistIcon,
    SHStyleKitDrawingWineDrinklistIcon,
    SHStyleKitDrawingDrinkMenuIcon,
    SHStyleKitDrawingReviewsIcon,
    SHStyleKitDrawingSearchIcon,
    SHStyleKitDrawingStarIcon,
    SHStyleKitDrawingMapBubblePinFilledIcon,
    SHStyleKitDrawingMapBubblePinEmptyIcon,
    SHStyleKitDrawingSpotSideBarIcon,
    SHStyleKitDrawingFeaturedListIcon,
    SHStyleKitDrawingDrinksIcon,
    SHStyleKitDrawingShareIcon,
    SHStyleKitDrawingCheckMarkIcon,
    SHStyleKitDrawingThumbsUpIcon,
    SHStyleKitDrawingNavigationArrowRightIcon,
    SHStyleKitDrawingNavigationArrowLeftIcon,
    SHStyleKitDrawingNavigationArrowUpIcon,
    SHStyleKitDrawingNavigationArrowDownIcon,
    SHStyleKitDrawingArrowRightIcon,
    SHStyleKitDrawingArrowLeftIcon,
    SHStyleKitDrawingArrowUpIcon,
    SHStyleKitDrawingArrowDownIcon,
    SHStyleKitDrawingDeleteIcon,
    SHStyleKitDrawingCloseIcon,
    SHStyleKitDrawingPlaceholderBasic,
    SHStyleKitDrawingDefaultAvatarIcon,
    SHStyleKitDrawingGradientBackground,
    SHStyleKitDrawingTopBarBackground,
    SHStyleKitDrawingTopBarWhiteShadowBackground,
    SHStyleKitDrawingBottomBarBlackShadowBackground,
    SHStyleKitDrawingPencilArrowRight,
    SHStyleKitDrawingPencilArrowLeft,
    SHStyleKitDrawingPencilArrowUp,
    SHStyleKitDrawingPencilArrowDown,
    SHStyleKitDrawingSwooshDial
} SHStyleKitDrawing;

#import "SHStyleKit.h"

@interface SHStyleKit (Additions)

#pragma mark - UI
#pragma mark -

+ (void)setImageView:(UIImageView *)imageView withDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color;

+ (void)setButton:(UIButton *)button withDrawing:(SHStyleKitDrawing)drawing normalColor:(SHStyleKitColor)normalColor highlightedColor:(SHStyleKitColor)highlightedColor size:(CGSize)size;

+ (void)setButton:(UIButton *)button withDrawing:(SHStyleKitDrawing)drawing normalColor:(SHStyleKitColor)normalColor highlightedColor:(SHStyleKitColor)highlightedColor;

+(void)setButton:(UIButton *)button withDrawing:(SHStyleKitDrawing)drawing text:(NSString *)text normalColor:(SHStyleKitColor)normalColor highlightedColor:(SHStyleKitColor)highlightedColor;

+ (void)setButton:(UIButton *)button normalTextColor:(SHStyleKitColor)normalTextColor highlightedTextColor:(SHStyleKitColor)highlightedTextColor;

+ (void)setLabel:(UILabel *)label textColor:(SHStyleKitColor)textColor;

+ (void)setTextField:(UITextField *)textField textColor:(SHStyleKitColor)textColor;

+ (void)setTextView:(UITextView *)textView textColor:(SHStyleKitColor)textColor;

+ (UIColor *)color:(SHStyleKitColor)color;

+ (UIImage *)drawImage:(SHStyleKitDrawing)drawing size:(CGSize)size;

+ (UIImage *)drawImage:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size;

+ (UIImage *)drawImage:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size position:(CGFloat)position;

#pragma mark - Backgrounds
#pragma mark -

+ (UIImage *)gradientBackgroundWithSize:(CGSize)size;

@end
