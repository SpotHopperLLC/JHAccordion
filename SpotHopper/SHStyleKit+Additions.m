//
//  SHStyleKit+Additions.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/14/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHStyleKit+Additions.h"

NSString * const SHStyleKitColorNameMyTintColor = @"myTintColor";
NSString * const SHStyleKitColorNameMyTintTransparentColor = @"myTintTransparentColor";
NSString * const SHStyleKitColorNameMyTextColor = @"myTextColor";
NSString * const SHStyleKitColorNameMyTextTransparentColor = @"myTextTransparentColor";
NSString * const SHStyleKitColorNameMyWhiteColor = @"myWhiteColor";
NSString * const SHStyleKitColorNameMyWhiteTransparentColor = @"myWhiteTransparentColor";
NSString * const SHStyleKitColorNameMyBlackColor = @"myBlackColor";
NSString * const SHStyleKitColorNameMyPencilColor = @"myPencilColor";
NSString * const SHStyleKitColorNameMyClearColor = @"myClearColor";

@interface SHStyleKitCache : NSCache
- (UIImage *)cachedImageForDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size rotation:(NSInteger)rotation position:(CGFloat)position;
- (void)cacheImage:(UIImage *)image
        forDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size rotation:(NSInteger)rotation position:(CGFloat)position;
@end

@implementation SHStyleKit (Additions)

+ (UIColor *)color:(SHStyleKitColor)color {
    switch (color) {
        case SHStyleKitColorMyTintColor:
            return SHStyleKit.myTintColor;
        case SHStyleKitColorMyTintTransparentColor:
            return SHStyleKit.myTintTransparentColor;
        case SHStyleKitColorMyTextColor:
            return SHStyleKit.myTextColor;
        case SHStyleKitColorMyTextTransparentColor:
            return SHStyleKit.myTextTransparentColor;
        case SHStyleKitColorMyWhiteColor:
            return SHStyleKit.myWhiteColor;
        case SHStyleKitColorMyWhiteTransparentColor:
            return SHStyleKit.myWhiteTransparentColor;
        case SHStyleKitColorMyBlackColor:
            return SHStyleKit.myBlackColor;
        case SHStyleKitColorMyPencilColor:
            return SHStyleKit.myPencilColor;
        case SHStyleKitColorMyClearColor:
            return SHStyleKit.myClearColor;
        default:
            return [UIColor clearColor];
            break;
    }
}

+ (NSString *)colorName:(SHStyleKitColor)color {
    switch (color) {
        case SHStyleKitColorMyTintColor:
            return SHStyleKitColorNameMyTintColor;
        case SHStyleKitColorMyTintTransparentColor:
            return SHStyleKitColorNameMyTintTransparentColor;
        case SHStyleKitColorMyTextColor:
            return SHStyleKitColorNameMyTextColor;
        case SHStyleKitColorMyTextTransparentColor:
            return SHStyleKitColorNameMyTextTransparentColor;
        case SHStyleKitColorMyWhiteColor:
            return SHStyleKitColorNameMyWhiteColor;
        case SHStyleKitColorMyWhiteTransparentColor:
            return SHStyleKitColorNameMyWhiteTransparentColor;
        case SHStyleKitColorMyBlackColor:
            return SHStyleKitColorNameMyBlackColor;
        case SHStyleKitColorMyClearColor:
            return SHStyleKitColorNameMyClearColor;
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

+ (void)setButton:(UIButton *)button withDrawing:(SHStyleKitDrawing)drawing text:(NSString *)text normalColor:(SHStyleKitColor)normalColor highlightedColor:(SHStyleKitColor)highlightedColor;
{
    UIImage *normalImage = [SHStyleKit drawImage:drawing color:normalColor size:button.frame.size];
    UIImage *highlightedImage = [SHStyleKit drawImage:drawing color:highlightedColor size:button.frame.size];
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:highlightedImage forState:UIControlStateHighlighted];
    [button setTitle:text forState:UIControlStateNormal];
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

+ (UIImage *)drawImage:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size {
    return [self drawImage:drawing color:color size:size position:0.0f];
}

+ (UIImage *)drawImage:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size position:(CGFloat)position;
{
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        NSLog(@"Size cannot be zero");
        return nil;
    }
    
    NSInteger rotation = 0;
    switch (drawing) {
        case SHStyleKitDrawingNavigationArrowUpIcon:
        case SHStyleKitDrawingArrowUpIcon:
        case SHStyleKitDrawingPencilArrowUp:
            rotation = 90;
            break;

        case SHStyleKitDrawingNavigationArrowLeftIcon:
        case SHStyleKitDrawingArrowLeftIcon:
        SHStyleKitDrawingPencilArrowLeft:
            rotation = 180;
            break;
            
        case SHStyleKitDrawingNavigationArrowDownIcon:
        case SHStyleKitDrawingArrowDownIcon:
        SHStyleKitDrawingPencilArrowDown:
            rotation = 270;
            break;
    
        default:
            // leave the default
            break;
    }
    
    UIImage *image = [[self sh_sharedImageCache] cachedImageForDrawing:drawing color:color size:size rotation:rotation position:position];
    if (image) {
        return image;
    }
    
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
        case SHStyleKitDrawingSimilarSpotIcon:
            [SHStyleKit drawSimilarSpotIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingSimilarBeerIcon:
            [SHStyleKit drawSimilarBeerIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingSimilarCocktailIcon:
            [SHStyleKit drawSimilarCocktailIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingSimilarWineIcon:
            [SHStyleKit drawSimilarWineIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingBottleIcon:
            [SHStyleKit drawBottleIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingTapIcon:
            [SHStyleKit drawTapIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingBottleAndTapIcon:
            [SHStyleKit drawBottleAndTapIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingBeerDrinklistIcon:
            [SHStyleKit drawBeerDrinklistIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingCocktailDrinklistIcon:
            [SHStyleKit drawCocktailDrinklistIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingWineDrinklistIcon:
            [SHStyleKit drawWineDrinklistIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
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
        case SHStyleKitDrawingStarIcon:
            if (color == SHStyleKitColorMyTintColor) {
                [SHStyleKit drawStarIconWithScaleX:scaleX scaleY:scaleY
                                   strokeColorName:[SHStyleKit colorName:SHStyleKitColorMyWhiteColor]
                                     fillColorName:[SHStyleKit colorName:SHStyleKitColorMyTintColor]];
            }
            else if (color == SHStyleKitColorMyTintTransparentColor) {
                [SHStyleKit drawStarIconWithScaleX:scaleX scaleY:scaleY
                                   strokeColorName:[SHStyleKit colorName:SHStyleKitColorMyWhiteColor]
                                     fillColorName:[SHStyleKit colorName:SHStyleKitColorMyTintTransparentColor]];
            }
            else if (color == SHStyleKitColorMyTextTransparentColor) {
                [SHStyleKit drawStarIconWithScaleX:scaleX scaleY:scaleY
                                   strokeColorName:[SHStyleKit colorName:SHStyleKitColorMyWhiteColor]
                                     fillColorName:[SHStyleKit colorName:SHStyleKitColorMyTextTransparentColor]];
            }
            else if (color == SHStyleKitColorMyWhiteColor) {
                [SHStyleKit drawStarIconWithScaleX:scaleX scaleY:scaleY
                                   strokeColorName:[SHStyleKit colorName:SHStyleKitColorMyTintColor]
                                     fillColorName:[SHStyleKit colorName:SHStyleKitColorMyWhiteColor]];
            }
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
            
        case SHStyleKitDrawingCloseIcon:
            [SHStyleKit drawCloseIconWithScaleX:scaleX scaleY:scaleY fillColorName:colorName];
            break;
            
        case SHStyleKitDrawingDeleteIcon:
            [SHStyleKit drawDeleteIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
        case SHStyleKitDrawingArrowRightIcon:
        case SHStyleKitDrawingArrowUpIcon:
        case SHStyleKitDrawingArrowLeftIcon:
        case SHStyleKitDrawingArrowDownIcon: {
            
            NSString *fillColorName = SHStyleKitColorNameMyTintColor;
            NSString *strokeColorName = SHStyleKitColorNameMyClearColor;
            
            switch (color) {
                case SHStyleKitColorMyWhiteColor:
                    fillColorName = SHStyleKitColorNameMyWhiteColor;
                    strokeColorName = SHStyleKitColorNameMyBlackColor;
                    break;
                case SHStyleKitColorMyBlackColor:
                    fillColorName = SHStyleKitColorNameMyBlackColor;
                    strokeColorName = SHStyleKitColorNameMyWhiteColor;
                    break;
                case SHStyleKitColorMyTextColor:
                    fillColorName = SHStyleKitColorNameMyTextColor;
                    strokeColorName = SHStyleKitColorNameMyClearColor;
                    break;
                    
                default:
                    break;
            }
            
            [SHStyleKit drawArrowIconWithScaleX:scaleX scaleY:scaleY strokeColorName:strokeColorName fillColorName:fillColorName rotation:rotation];
        }
            break;
            
        case SHStyleKitDrawingPlaceholderBasic:
            [SHStyleKit drawMyPlaceholderWithScaleX:scaleX scaleY:scaleY];
            break;
            
        case SHStyleKitDrawingDefaultAvatarIcon:
            [SHStyleKit drawDefaultAvatarIconWithScaleX:scaleX scaleY:scaleY strokeColorName:colorName];
            break;
            
        case SHStyleKitDrawingTopBarBackground:
            [SHStyleKit drawTopBarBackgroundWithFillColorName:colorName];
            
        case SHStyleKitDrawingTopBarWhiteShadowBackground:
            [SHStyleKit drawTopBarWhiteShadowBackground];
            break;
            
        case SHStyleKitDrawingBottomBarBlackShadowBackground:
            [SHStyleKit drawBottomBarBlackShadowBackground];
            break;
            
        case SHStyleKitDrawingPencilArrowRight:
        case SHStyleKitDrawingPencilArrowLeft:
        case SHStyleKitDrawingPencilArrowUp:
        case SHStyleKitDrawingPencilArrowDown:
            [SHStyleKit drawPencilArrowWithScaleX:scaleX scaleY:scaleY rotation:rotation];
            break;
            
        case SHStyleKitDrawingSwooshDial:
            [SHStyleKit drawSwooshRatingWithScaleX:scaleX scaleY:scaleY strokeColorName:[SHStyleKit colorName:SHStyleKitColorMyTintColor] fillColorName:[SHStyleKit colorName:SHStyleKitColorMyTextTransparentColor] position:position];
            
        default:
            break;
    }
    
    // draw the outline to debug image creation
     //[SHStyleKit drawOutlineIconWithScaleX:scaleX scaleY:scaleY strokeColorName:SHStyleKitColorNameMyTintColor];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // only a last resort
    //image = [SHStyleKit resizeImage:image toMaximumSize:size];
    
    [[self sh_sharedImageCache] cacheImage:image forDrawing:drawing color:color size:size rotation:rotation position:position];
    
    return image;
}

#pragma mark - Backgrounds
#pragma mark -

+ (UIImage *)gradientBackgroundWithSize:(CGSize)size;
{
    UIImage *image = [[self sh_sharedImageCache] cachedImageForDrawing:SHStyleKitDrawingGradientBackground color:SHStyleKitColorNone size:size rotation:0 position:0.0f];
    if (image) {
        return image;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, 568), NO, 0.0f);
    [SHStyleKit drawGradientBackgroundWithWidth: size.width height: size.height scaleX: 1 scaleY: 1];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [[self sh_sharedImageCache] cacheImage:image forDrawing:SHStyleKitDrawingGradientBackground color:SHStyleKitColorNone size:size rotation:0 position:0.0f];
    
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

- (NSString *)keyForDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size rotation:(NSInteger)rotation position:(CGFloat)position;
{
    return [NSString stringWithFormat:@"drawing-%li-color-%li-width-%f-height-%f-rotation-%li-%f", (long)drawing, (long)color, size.width, size.height, (long)rotation, position];
}

- (UIImage *)cachedImageForDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size rotation:(NSInteger)rotation position:(CGFloat)position;
{
    NSString *key = [self keyForDrawing:drawing color:color size:size rotation:rotation position:position];
    return [self objectForKey:key];
}

- (void)cacheImage:(UIImage *)image
        forDrawing:(SHStyleKitDrawing)drawing color:(SHStyleKitColor)color size:(CGSize)size rotation:(NSInteger)rotation position:(CGFloat)position;
{
    NSString *key = [self keyForDrawing:drawing color:color size:size rotation:rotation position:position];
    if (!image || !key.length) {
        return;
    }
    [self setObject:image forKey:key];
}

@end