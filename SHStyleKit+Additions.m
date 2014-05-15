//
//  SHStyleKit+Additions.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/14/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHStyleKit+Additions.h"

NSString * const SHStyleKitColorNameMyTintColor = @"myTintColor";
NSString * const SHStyleKitColorNameMyTintTransparentColor = @"myTintColorTransparent";
NSString * const SHStyleKitColorNameMyTextColor = @"myTextColor";
NSString * const SHStyleKitColorNameMyWhiteColor = @"myWhiteColor";

@interface SHStyleKitCache : NSCache
- (UIImage *)cachedImageForDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size;
- (void)cacheImage:(UIImage *)image
        forDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size;
@end

@implementation SHStyleKit (Additions)

+ (UIColor *)color:(SHStyleKitColor)color {
    switch (color) {
        case SHStyleKitColorMyTintColor:
            return SHStyleKit.myTintColor;
        case SHStyleKitColorMyTintColorTransparent:
            return SHStyleKit.myTintColorTransparent;
        case SHStyleKitColorMyTextColor:
            return SHStyleKit.myTextColor;
        case SHStyleKitColorMyWhiteColor:
            return SHStyleKit.myWhiteColor;
        default:
            return [UIColor clearColor];
            break;
    }
}

+ (NSString *)colorName:(SHStyleKitColor)color {
    switch (color) {
        case SHStyleKitColorMyTintColor:
            return SHStyleKitColorNameMyTintColor;
        case SHStyleKitColorMyTintColorTransparent:
            return SHStyleKitColorNameMyTintTransparentColor;
        case SHStyleKitColorMyTextColor:
            return SHStyleKitColorNameMyTextColor;
        case SHStyleKitColorMyWhiteColor:
            return SHStyleKitColorNameMyWhiteColor;
        default:
            return @"";
            break;
    }
}

#pragma mark - Icons
#pragma mark -

+ (UIImage *)spotIconWithColor:(SHStyleKitColor)color size:(CGSize)size;
{
    return [SHStyleKit drawImage:SHStyleKitDrawingSpotIcon color:color size:size];
}

+ (UIImage *)specialsIconWithColor:(SHStyleKitColor)color size:(CGSize)size;
{
    return [SHStyleKit drawImage:SHStyleKitDrawingSpecialsIcon color:color size:size];
}

+ (UIImage *)beerIconWithColor:(SHStyleKitColor)color size:(CGSize)size;
{
    return [SHStyleKit drawImage:SHStyleKitDrawingBeerIcon color:color size:size];
}

+ (UIImage *)cocktailIconWithColor:(SHStyleKitColor)color size:(CGSize)size;
{
    return [SHStyleKit drawImage:SHStyleKitDrawingCocktailIcon color:color size:size];
}

+ (UIImage *)wineIconWithColor:(SHStyleKitColor)color size:(CGSize)size;
{
    return [SHStyleKit drawImage:SHStyleKitDrawingWineIcon color:color size:size];
}

+ (UIImage *)navigationArrowIconWithColor:(SHStyleKitColor)color size:(CGSize)size;
{
    return [SHStyleKit drawImage:SHStyleKitDrawingNavigationIconArrow color:color size:size];
}

+ (UIImage *)directionArrowIconWithColor:(SHStyleKitColor)color size:(CGSize)size;
{
    return [SHStyleKit drawImage:SHStyleKitDrawingDirectionArrowIcon color:color size:size];
}

+ (UIImage *)searchIconWithColor:(SHStyleKitColor)color size:(CGSize)size;
{
    return [SHStyleKit drawImage:SHStyleKitDrawingSearchIcon color:color size:size];
}

#pragma mark - Backgrounds
#pragma mark -

+ (UIImage *)gradientBackgroundWithWidth:(CGFloat)width height:(CGFloat)height;
{
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0.0f);
    
    [SHStyleKit drawGradientBackgroundWithWidth:width height:height];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Caching
#pragma mark -

+ (SHStyleKitCache *)sh_sharedImageCache {
    static SHStyleKitCache *_sh_imageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sh_imageCache = [[SHStyleKitCache alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_sh_imageCache removeAllObjects];
        }];
    });
    
    return _sh_imageCache;
}

#pragma mark - Private
#pragma mark -

+ (UIImage *)drawImage:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size;
{
    UIImage *image = [[self sh_sharedImageCache] cachedImageForDrawing:drawing color:color size:size];
    if (image) {
        return image;
    }
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1024, 1024), NO, 0.0f);
    
    switch (drawing) {
        case SHStyleKitDrawingSpotIcon:
            [SHStyleKit drawSpotIconWithColorName:[SHStyleKit colorName:color]];
            break;
        case SHStyleKitDrawingSpecialsIcon:
            [SHStyleKit drawSpecialsIconWithColorName:[SHStyleKit colorName:color]];
            break;
        case SHStyleKitDrawingBeerIcon:
            [SHStyleKit drawBeerIconWithColorName:[SHStyleKit colorName:color]];
            break;
        case SHStyleKitDrawingCocktailIcon:
            [SHStyleKit drawCocktailIconWithColorName:[SHStyleKit colorName:color]];
            break;
        case SHStyleKitDrawingWineIcon:
            [SHStyleKit drawWineIconWithColorName:[SHStyleKit colorName:color]];
            break;
        case SHStyleKitDrawingNavigationIconArrow:
            [SHStyleKit drawNavigationArrowIconWithColorName:[SHStyleKit colorName:color]];
            break;
        case SHStyleKitDrawingDirectionArrowIcon:
            [SHStyleKit drawDirectionArrowIconWithColorName:[SHStyleKit colorName:color]];
            break;
        case SHStyleKitDrawingSearchIcon:
            [SHStyleKit drawSearchIconWithColorName:[SHStyleKit colorName:color]];
            break;
            
        default:
            break;
    }
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    image = [self resizeImage:image toMaximumSize:size];
    [[self sh_sharedImageCache] cacheImage:image forDrawing:drawing color:color size:size];
    
    return image;
}

+ (UIImage *)resizeImage:(UIImage *)image toMaximumSize:(CGSize)maxSize;
{
    CGFloat widthRatio = maxSize.width / image.size.width;
    CGFloat heightRatio = maxSize.height / image.size.height;
    CGFloat scaleRatio = widthRatio < heightRatio ? widthRatio : heightRatio;
    CGSize newSize = CGSizeMake(image.size.width * scaleRatio, image.size.height * scaleRatio);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, image.scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

@end

@implementation SHStyleKitCache

- (NSString *)keyForDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size;
{
    return [NSString stringWithFormat:@"drawing-%li-color-%li-width-%f-height-%f", (long)drawing, (long)color, size.width, size.height];
}

- (UIImage *)cachedImageForDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size;
{
    NSString *key = [self keyForDrawing:drawing color:color size:size];
    return [self objectForKey:key];
}

- (void)cacheImage:(UIImage *)image
        forDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size;
{
    NSString *key = [self keyForDrawing:drawing color:color size:size];
    [self setObject:image forKey:key];
}

@end