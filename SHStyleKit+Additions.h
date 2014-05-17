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
    SHStyleKitColorMyTintColor = 1,
    SHStyleKitColorMyTintColorTransparent = 2,
    SHStyleKitColorMyTextColor = 3,
    SHStyleKitColorMyWhiteColor = 4
} SHStyleKitColor;

typedef enum {
    SHStyleKitDrawingNone = 0,
    SHStyleKitDrawingSpotIcon = 1,
    SHStyleKitDrawingSpecialsIcon = 2,
    SHStyleKitDrawingBeerIcon = 3,
    SHStyleKitDrawingCocktailIcon = 4,
    SHStyleKitDrawingWineIcon = 5,
    SHStyleKitDrawingNavigationIconArrow = 6,
    SHStyleKitDrawingPreviousArrowIcon = 7,
    SHStyleKitDrawingNextArrowIcon = 8,
    SHStyleKitDrawingSearchIcon = 9,
    SHStyleKitDrawingMapBubblePinFilledIcon = 10,
    SHStyleKitDrawingMapBubbleEmptyIcon = 11,
    SHStyleKitDrawingSpotSideBarIcon = 12,
    SHStyleKitDrawingFeaturedListIcon = 13,
    SHStyleKitDrawingGradientBackground = 14
} SHStyleKitDrawing;

#import "SHStyleKit.h"

@interface SHStyleKit (Additions)

#pragma mark - UI
#pragma mark -

+ (void)setImageView:(UIImageView *)imageView withDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color;

+ (void)setButton:(UIButton *)button withDrawing:(SHStyleKitDrawing)drawing normalColor:(SHStyleKitColor)normalColor highlightedColor:(SHStyleKitColor)highlightedColor;

+ (void)setLabel:(UILabel *)label textColor:(SHStyleKitColor)textColor;

+ (UIImage *)drawImage:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size;


#pragma mark - Backgrounds
#pragma mark -

+ (UIImage *)gradientBackgroundWithSize:(CGSize)size;

@end
