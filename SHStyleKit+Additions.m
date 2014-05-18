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

#pragma mark - UI
#pragma mark -

+ (void)setImageView:(UIImageView *)imageView withDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color {
    UIImage *image = [SHStyleKit drawImage:drawing color:color size:imageView.frame.size];
    imageView.image = image;
}

+ (void)setButton:(UIButton *)button withDrawing:(SHStyleKitDrawing)drawing normalColor:(SHStyleKitColor)normalColor highlightedColor:(SHStyleKitColor)highlightedColor;
{
    UIImage *normalImage = [SHStyleKit drawImage:drawing color:normalColor size:button.frame.size];
    UIImage *highlightedImage = [SHStyleKit drawImage:drawing color:highlightedColor size:button.frame.size];
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
}

+ (void)setLabel:(UILabel *)label textColor:(SHStyleKitColor)textColor;
{
    label.textColor = [self color:textColor];
}

#pragma mark - Drawing
#pragma mark -

+ (UIImage *)drawImage:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size;
{
    UIImage *image = [[self sh_sharedImageCache] cachedImageForDrawing:drawing color:color size:size];
    if (image) {
        return image;
    }
    
    //UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    // scaling does not currently work with the code generated by PaintCode (5/16/2014)
    CGFloat scaleX = 1; //size.width / 1024;
    CGFloat scaleY = 1; //size.height / 1024;
    NSString *colorName = [SHStyleKit colorName:color];
    
    switch (drawing) {
        case SHStyleKitDrawingSpotIcon:
            image = [SHStyleKit imageOfSpotIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingSpecialsIcon:
            image = [SHStyleKit imageOfSpecialsIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingBeerIcon:
            image = [SHStyleKit imageOfBeerIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingCocktailIcon:
            image = [SHStyleKit imageOfCocktailIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingWineIcon:
            image = [SHStyleKit imageOfWineIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingNavigationIconArrow:
            image = [SHStyleKit imageOfNavigationArrowIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingPreviousArrowIcon:
            image = [SHStyleKit imageOfPreviousArrowIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingNextArrowIcon:
            image = [SHStyleKit imageOfNextArrowIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingSearchIcon:
            image = [SHStyleKit imageOfSearchIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingMapBubblePinFilledIcon:
            image = [SHStyleKit imageOfMapBubblePinFilledIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingMapBubblePinEmptyIcon:
            image = [SHStyleKit imageOfMapBubblePinEmptyIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingSpotSideBarIcon:
            image = [SHStyleKit imageOfSpotSideBarIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingFeaturedListIcon:
            image = [SHStyleKit imageOfFeaturedListIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        default:
            break;
    }
    
    //image = UIGraphicsGetImageFromCurrentImageContext();
    //UIGraphicsEndImageContext();
    
    image = [self resizeImage:image toMaximumSize:size];
    [[self sh_sharedImageCache] cacheImage:image forDrawing:drawing color:color size:size];
    
    return image;
}

#pragma mark - Backgrounds
#pragma mark -

+ (UIImage *)gradientBackgroundWithSize:(CGSize)size;
{
    UIImage *image = [[self sh_sharedImageCache] cachedImageForDrawing:SHStyleKitDrawingGradientBackground color:SHStyleKitColorNone size:size];
    if (image) {
        return image;
    }
    
    image = [SHStyleKit imageOfGradientBackgroundWithWidth:size.width height:size.height scaleX:1 scaleY:1];
    
    [[self sh_sharedImageCache] cacheImage:image forDrawing:SHStyleKitDrawingGradientBackground color:SHStyleKitColorNone size:size];
    
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
    if (!image || !key.length) {
        return;
    }
    [self setObject:image forKey:key];
}

@end