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
    SHStyleKitDrawingDirectionArrowIcon = 7,
    SHStyleKitDrawingSearchIcon = 8
} SHStyleKitDrawing;

#import "SHStyleKit.h"

@interface SHStyleKit (Additions)

#pragma mark - Icons
#pragma mark -

+ (UIImage *)spotIconWithColor:(SHStyleKitColor)color size:(CGSize)size;

+ (UIImage *)specialsIconWithColor:(SHStyleKitColor)color size:(CGSize)size;

+ (UIImage *)beerIconWithColor:(SHStyleKitColor)color size:(CGSize)size;

+ (UIImage *)cocktailIconWithColor:(SHStyleKitColor)color size:(CGSize)size;

+ (UIImage *)wineIconWithColor:(SHStyleKitColor)color size:(CGSize)size;

+ (UIImage *)navigationArrowIconWithColor:(SHStyleKitColor)color size:(CGSize)size;

+ (UIImage *)directionArrowIconWithColor:(SHStyleKitColor)color size:(CGSize)size;

+ (UIImage *)searchIconWithColor:(SHStyleKitColor)color size:(CGSize)size;

#pragma mark - Backgrounds
#pragma mark -

+ (UIImage *)gradientBackgroundWithWidth:(CGFloat)width height:(CGFloat)height;

@end
