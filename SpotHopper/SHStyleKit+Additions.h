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
extern NSString * const SHStyleKitColorNameMyWhiteColor;

typedef enum {
    SHStyleKitColorNone = 0,
    SHStyleKitColorMyTintColor,
    SHStyleKitColorMyTintColorTransparent,
    SHStyleKitColorMyTextColor,
    SHStyleKitColorMyWhiteColor
} SHStyleKitColor;

typedef enum {
    SHStyleKitDrawingNone = 0,
    SHStyleKitDrawingSpotIcon,
    SHStyleKitDrawingSpecialsIcon,
    SHStyleKitDrawingBeerIcon,
    SHStyleKitDrawingCocktailIcon,
    SHStyleKitDrawingWineIcon,
    SHStyleKitDrawingSearchIcon,
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
    SHStyleKitDrawingPlaceholderBasic,
    SHStyleKitDrawingGradientBackground
} SHStyleKitDrawing;

#import "SHStyleKit.h"

@interface SHStyleKit (Additions)

#pragma mark - UI
#pragma mark -

+ (void)setImageView:(UIImageView *)imageView withDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color;

+ (void)setButton:(UIButton *)button withDrawing:(SHStyleKitDrawing)drawing normalColor:(SHStyleKitColor)normalColor highlightedColor:(SHStyleKitColor)highlightedColor size:(CGSize)size;

+ (void)setButton:(UIButton *)button withDrawing:(SHStyleKitDrawing)drawing normalColor:(SHStyleKitColor)normalColor highlightedColor:(SHStyleKitColor)highlightedColor;

+ (void)setButton:(UIButton *)button normalTextColor:(SHStyleKitColor)normalTextColor highlightedTextColor:(SHStyleKitColor)highlightedTextColor;

+ (void)setLabel:(UILabel *)label textColor:(SHStyleKitColor)textColor;

+ (void)setTextView:(UITextView *)textView textColor:(SHStyleKitColor)textColor;

+ (UIImage *)drawImage:(SHStyleKitDrawing)drawing size:(CGSize)size;

+ (UIImage *)drawImage:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size;

#pragma mark - Backgrounds
#pragma mark -

+ (UIImage *)gradientBackgroundWithSize:(CGSize)size;

@end
