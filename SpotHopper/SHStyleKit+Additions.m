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
- (UIImage *)cachedImageForDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size rotation:(NSInteger)rotation;
- (void)cacheImage:(UIImage *)image
        forDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size rotation:(NSInteger)rotation;
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

+ (void)setImageView:(UIImageView *)imageView withDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color;
{
    UIImage *image = [SHStyleKit drawImage:drawing color:color size:imageView.frame.size];
    imageView.image = image;
}

+ (void)setButton:(UIButton *)button withDrawing:(SHStyleKitDrawing)drawing normalColor:(SHStyleKitColor)normalColor highlightedColor:(SHStyleKitColor)highlightedColor size:(CGSize)size;
{
    UIImage *normalImage = [SHStyleKit drawImage:drawing color:normalColor size:size];
    UIImage *highlightedImage = [SHStyleKit drawImage:drawing color:highlightedColor size:size];
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
}

+ (void)setButton:(UIButton *)button withDrawing:(SHStyleKitDrawing)drawing normalColor:(SHStyleKitColor)normalColor highlightedColor:(SHStyleKitColor)highlightedColor;
{
    UIImage *normalImage = [SHStyleKit drawImage:drawing color:normalColor size:button.frame.size];
    UIImage *highlightedImage = [SHStyleKit drawImage:drawing color:highlightedColor size:button.frame.size];
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
}

+ (void)setButton:(UIButton *)button withDrawing:(SHStyleKitDrawing)drawing text:(NSString*)text normalColor:(SHStyleKitColor)normalColor highlightedColor:(SHStyleKitColor)highlightedColor;
{
    button.titleLabel.text = text;
    UIImage *normalImage = [SHStyleKit drawImage:drawing color:normalColor size:button.frame.size];
    UIImage *highlightedImage = [SHStyleKit drawImage:drawing color:highlightedColor size:button.frame.size];
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
}


+ (void)setButton:(UIButton *)button normalTextColor:(SHStyleKitColor)normalTextColor highlightedTextColor:(SHStyleKitColor)highlightedTextColor;
{
    [button setTitleColor:[self color:normalTextColor] forState:UIControlStateNormal];
    [button setTitleColor:[self color:highlightedTextColor] forState:UIControlStateHighlighted];
}

+ (void)setLabel:(UILabel *)label textColor:(SHStyleKitColor)textColor;
{
    label.textColor = [self color:textColor];
}

+ (void)setTextField:(UITextField *)textField textColor:(SHStyleKitColor)textColor;
{
    UIColor *color = [self color:textColor];
    textField.textColor = color;
}

+ (void)setTextView:(UITextView *)textView textColor:(SHStyleKitColor)textColor;
{
    UIColor *color = [self color:textColor];
    textView.textColor = color;
}

#pragma mark - Drawing
#pragma mark -

+ (UIImage *)drawImage:(SHStyleKitDrawing)drawing size:(CGSize)size;
{
    return [SHStyleKit drawImage:drawing color:SHStyleKitColorNone size:size];
}

+ (UIImage *)drawImage:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size;
{
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        NSLog(@"Size canot be zero");
        return nil;
    }
    
    NSInteger rotation = 0;
    switch (drawing) {
        case SHStyleKitDrawingNavigationArrowUpIcon:
        case SHStyleKitDrawingArrowUpIcon:
            rotation = 90;
            break;

        case SHStyleKitDrawingNavigationArrowLeftIcon:
        case SHStyleKitDrawingArrowLeftIcon:
            rotation = 180;
            break;
            
        case SHStyleKitDrawingNavigationArrowDownIcon:
        case SHStyleKitDrawingArrowDownIcon:
            rotation = 270;
            break;
    
        default:
            // leave the default
            break;
    }
    
    UIImage *image = [[self sh_sharedImageCache] cachedImageForDrawing:drawing color:color size:size rotation:rotation];
    if (image) {
        return image;
    }
    
    // scaling does not currently work with the code generated by PaintCode (5/16/2014)
    CGFloat scaleX = size.width / 1024;
    CGFloat scaleY = size.height / 1024;
    NSString *colorName = [SHStyleKit colorName:color];
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    switch (drawing) {
        case SHStyleKitDrawingSpotIcon:
            [SHStyleKit drawSpotIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingSpecialsIcon:
            [SHStyleKit drawSpecialsIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingBeerIcon:
            [SHStyleKit drawBeerIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingCocktailIcon:
            [SHStyleKit drawCocktailIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingWineIcon:
            [SHStyleKit drawWineIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingDrinkMenuIcon:
            [SHStyleKit drawDrinkMenuIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingReviewsIcon:
            [SHStyleKit drawReviewsIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingSearchIcon:
            [SHStyleKit drawSearchIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingMapBubblePinFilledIcon:
            [SHStyleKit drawMapBubblePinFilledIconWithScaleX:scaleX scaleY:scaleY];
            break;
        case SHStyleKitDrawingMapBubblePinEmptyIcon:
            [SHStyleKit drawMapBubblePinEmptyIconWithScaleX:scaleX scaleY:scaleY];
            break;
        case SHStyleKitDrawingSpotSideBarIcon:
            [SHStyleKit drawSpotSideBarIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingFeaturedListIcon:
            [SHStyleKit drawFeaturedListIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingDrinksIcon:
            [SHStyleKit drawDrinksIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
            
        case SHStyleKitDrawingShareIcon:
            if (color == SHStyleKitColorMyTintColor) {
                [SHStyleKit drawShareIconWithScaleX:scaleX
                                             scaleY:scaleY
                                         color1Name:colorName
                                         color2Name:[SHStyleKit colorName:SHStyleKitColorMyWhiteColor]
                                         color3Name:[SHStyleKit colorName:SHStyleKitColorMyTextColor]];
            }
            else if (color == SHStyleKitColorMyWhiteColor) {
                [SHStyleKit drawShareIconWithScaleX:scaleX
                                             scaleY:scaleY
                                         color1Name:colorName
                                         color2Name:[SHStyleKit colorName:SHStyleKitColorMyTintColor]
                                         color3Name:[SHStyleKit colorName:SHStyleKitColorMyTextColor]];
            }
            else {
                [SHStyleKit drawShareIconWithScaleX:scaleX
                                             scaleY:scaleY
                                         color1Name:colorName
                                         color2Name:[SHStyleKit colorName:SHStyleKitColorMyTextColor]
                                         color3Name:[SHStyleKit colorName:SHStyleKitColorMyTintColor]];
            }
            break;
        case SHStyleKitDrawingCheckMarkIcon:
                if (color == SHStyleKitColorMyTintColor) {
                    [SHStyleKit drawCheckMarkIconWithScaleX:scaleX scaleY:scaleY
                                            strokeColorName:colorName
                                              fillColorName:[SHStyleKit colorName:SHStyleKitColorMyWhiteColor]];
                }
                else {
                    [SHStyleKit drawCheckMarkIconWithScaleX:scaleX scaleY:scaleY
                                            strokeColorName:colorName
                                              fillColorName:[SHStyleKit colorName:SHStyleKitColorMyTintColor]];
                }
            break;
        case SHStyleKitDrawingThumbsUpIcon:
            if (color == SHStyleKitColorMyTintColor) {
                [SHStyleKit drawThumbsUpIconWithScaleX:scaleX scaleY:scaleY
                                        strokeColorName:colorName
                                          fillColorName:[SHStyleKit colorName:SHStyleKitColorMyWhiteColor]];
            }
            else {
                [SHStyleKit drawThumbsUpIconWithScaleX:scaleX scaleY:scaleY
                                        strokeColorName:colorName
                                          fillColorName:[SHStyleKit colorName:SHStyleKitColorMyTintColor]];
            }
            break;
        case SHStyleKitDrawingNavigationArrowRightIcon:
        case SHStyleKitDrawingNavigationArrowUpIcon:
        case SHStyleKitDrawingNavigationArrowLeftIcon:
        case SHStyleKitDrawingNavigationArrowDownIcon:
            [SHStyleKit drawNavigationArrowIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName rotation:rotation];
            break;
        case SHStyleKitDrawingArrowRightIcon:
        case SHStyleKitDrawingArrowUpIcon:
        case SHStyleKitDrawingArrowLeftIcon:
        case SHStyleKitDrawingArrowDownIcon:
            [SHStyleKit drawArrowIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName rotation:rotation];
            break;
            
        case SHStyleKitDrawingPlaceholderBasic:
            [SHStyleKit drawMyPlaceholderWithScaleX:scaleX scaleY:scaleY];
            break;
            
        default:
            break;
    }
    
    // draw the outline to debug image creation
    //[SHStyleKit drawOutlineIconWithScaleX:scaleX scaleY:scaleY strokeColorName:SHStyleKitColorNameMyTintColor];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // only a last resort
    image = [SHStyleKit resizeImage:image toMaximumSize:size];
    
    [[self sh_sharedImageCache] cacheImage:image forDrawing:drawing color:color size:size rotation:rotation];
    
    return image;
}

#pragma mark - Backgrounds
#pragma mark -

+ (UIImage *)gradientBackgroundWithSize:(CGSize)size;
{
    UIImage *image = [[self sh_sharedImageCache] cachedImageForDrawing:SHStyleKitDrawingGradientBackground color:SHStyleKitColorNone size:size rotation:0];
    if (image) {
        return image;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 568), NO, 0.0f);
    [SHStyleKit drawGradientBackgroundWithWidth: size.width height: size.height scaleX: 1 scaleY: 1];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [[self sh_sharedImageCache] cacheImage:image forDrawing:SHStyleKitDrawingGradientBackground color:SHStyleKitColorNone size:size rotation:0];
    
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
    if (CGSizeEqualToSize(image.size, maxSize)) {
        return image;
    }
    
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

- (NSString *)keyForDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size rotation:(NSInteger)rotation;
{
    return [NSString stringWithFormat:@"drawing-%li-color-%li-width-%f-height-%f-rotation-%li", (long)drawing, (long)color, size.width, size.height, (long)rotation];
}

- (UIImage *)cachedImageForDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size rotation:(NSInteger)rotation;
{
    NSString *key = [self keyForDrawing:drawing color:color size:size rotation:rotation];
    return [self objectForKey:key];
}

- (void)cacheImage:(UIImage *)image
        forDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size rotation:(NSInteger)rotation;
{
    NSString *key = [self keyForDrawing:drawing color:color size:size rotation:rotation];
    if (!image || !key.length) {
        return;
    }
    [self setObject:image forKey:key];
}

@end