//
//  SHAppUtil.m
//  SpotHopper
//
//  Created by Brennan Stehling on 9/24/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHAppUtil.h"

#import "SHAppConfiguration.h"

#import "SpotModel.h"
#import "SpecialModel.h"
#import "DrinkModel.h"
#import "CheckInModel.h"

#import "ImageUtil.h"
#import "Tracker.h"
#import "SSTURLShortener.h"

@implementation SHAppUtil

+ (instancetype)defaultInstance {
    static SHAppUtil *defaultInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        defaultInstance = [[SHAppUtil alloc] init];
    });
    return defaultInstance;
}

#pragma mark - Sharing
#pragma mark -

- (void)shareSpecial:(SpecialModel *)special atSpot:(SpotModel *)spot withViewController:(UIViewController *)vc {
    if (!spot.highlightImage) {
        [self shareSpecial:special atSpot:spot image:nil withViewController:vc];
    }
    else {
        [ImageUtil loadImage:spot.highlightImage placeholderImage:nil withThumbImageBlock:nil withFullImageBlock:^(UIImage *fullImage) {
            [self shareSpecial:special atSpot:spot image:fullImage withViewController:vc];
        } withErrorBlock:^(NSError *error) {
            [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
}

- (void)shareSpecial:(SpecialModel *)special atSpot:(SpotModel *)spot image:(UIImage *)image withViewController:(UIViewController *)vc {
    NSString *link = [NSString stringWithFormat:@"%@/spots/%lu/specials", [SHAppConfiguration websiteUrl], (unsigned long)[spot.ID integerValue]];
    
    // go.spotapps.co -> www.spothopperapp.com
    [SSTURLShortener shortenURL:[NSURL URLWithString:link] username:[SHAppConfiguration bitlyUsername] apiKey:[SHAppConfiguration bitlyAPIKey] withCompletionBlock:^(NSURL *shortenedURL, NSError *error) {
        NSString *specialText = special.text;
        
        NSMutableArray *activityItems = @[].mutableCopy;
        [activityItems addObject:[NSString stringWithFormat:@"Special at %@", spot.name]];
        [activityItems addObject:specialText.length ? specialText : @""];
        [activityItems addObject:shortenedURL];
//        [activityItems addObject:[NSURL URLWithString:link]];
//        if (image) {
//            [activityItems addObject:image];
//        }
        NSMutableArray *activities = @[].mutableCopy;
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activities];
        
        [vc presentViewController:activityView animated:YES completion:nil];
    }];
}

- (void)shareSpot:(SpotModel *)spot withViewController:(UIViewController *)vc {
    if (!spot.highlightImage) {
        [self shareSpot:spot image:nil withViewController:vc];
    }
    else {
        [ImageUtil loadImage:spot.highlightImage placeholderImage:nil withThumbImageBlock:nil withFullImageBlock:^(UIImage *fullImage) {
            [self shareSpot:spot image:fullImage withViewController:vc];
        } withErrorBlock:^(NSError *error) {
            [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
}

- (void)shareSpot:(SpotModel *)spot image:(UIImage *)image withViewController:(UIViewController *)vc {
    NSString *link = [NSString stringWithFormat:@"%@/spots/%lu", [SHAppConfiguration websiteUrl], (unsigned long)[spot.ID integerValue]];

    // go.spotapps.co -> www.spothopperapp.com
    [SSTURLShortener shortenURL:[NSURL URLWithString:link] username:[SHAppConfiguration bitlyUsername] apiKey:[SHAppConfiguration bitlyAPIKey] withCompletionBlock:^(NSURL *shortenedURL, NSError *error) {
        NSMutableArray *activityItems = @[].mutableCopy;
        [activityItems addObject:spot.name.length ? spot.name : @""];
        [activityItems addObject:shortenedURL];
//        [activityItems addObject:[NSURL URLWithString:link]];
//        if (image) {
//            [activityItems addObject:image];
//        }
        NSMutableArray *activities = @[].mutableCopy;
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activities];
        
        [vc presentViewController:activityView animated:YES completion:nil];
    }];
}

- (void)shareDrink:(DrinkModel *)drink withViewController:(UIViewController *)vc {
    if (!drink.highlightImage) {
        [self shareDrink:drink image:nil withViewController:vc];
    }
    else {
        [ImageUtil loadImage:drink.highlightImage placeholderImage:nil withThumbImageBlock:nil withFullImageBlock:^(UIImage *fullImage) {
            [self shareDrink:drink image:fullImage withViewController:vc];
        } withErrorBlock:^(NSError *error) {
            [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
}

- (void)shareDrink:(DrinkModel *)drink image:(UIImage *)image withViewController:(UIViewController *)vc {
    NSString *link = [NSString stringWithFormat:@"%@/drinks/%lu", [SHAppConfiguration websiteUrl], (unsigned long)[drink.ID integerValue]];
    
    // go.spotapps.co -> www.spothopperapp.com
    [SSTURLShortener shortenURL:[NSURL URLWithString:link] username:[SHAppConfiguration bitlyUsername] apiKey:[SHAppConfiguration bitlyAPIKey] withCompletionBlock:^(NSURL *shortenedURL, NSError *error) {
        
        NSMutableArray *activityItems = @[].mutableCopy;
        [activityItems addObject:drink.name.length ? drink.name : @""];
        [activityItems addObject:shortenedURL];
//        [activityItems addObject:[NSURL URLWithString:link]];
//        if (image) {
//            [activityItems addObject:image];
//        }
        NSMutableArray *activities = @[].mutableCopy;
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activities];
        
        [vc presentViewController:activityView animated:YES completion:nil];
    }];
}

- (void)shareCheckin:(CheckInModel *)checkin withViewController:(UIViewController *)vc {
    if (!checkin.spot.highlightImage) {
        [self shareCheckin:checkin image:nil withViewController:vc];
    }
    else {
        [ImageUtil loadImage:checkin.spot.highlightImage placeholderImage:nil withThumbImageBlock:nil withFullImageBlock:^(UIImage *fullImage) {
            [self shareCheckin:checkin image:fullImage withViewController:vc];
        } withErrorBlock:^(NSError *error) {
            [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
}

- (void)shareCheckin:(CheckInModel *)checkin image:(UIImage *)image withViewController:(UIViewController *)vc {
    NSString *link = [NSString stringWithFormat:@"%@/checkins/%@", [SHAppConfiguration websiteUrl], checkin.ID];
    
    // go.spotapps.co -> www.spothopperapp.com
    [SSTURLShortener shortenURL:[NSURL URLWithString:link] username:[SHAppConfiguration bitlyUsername] apiKey:[SHAppConfiguration bitlyAPIKey] withCompletionBlock:^(NSURL *shortenedURL, NSError *error) {
        
        NSMutableArray *activityItems = @[].mutableCopy;
        [activityItems addObject:checkin.spot.name.length ? checkin.spot.name : @""];
        [activityItems addObject:shortenedURL];
//        [activityItems addObject:[NSURL URLWithString:link]];
//        if (image) {
//            [activityItems addObject:image];
//        }
        NSMutableArray *activities = @[].mutableCopy;
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activities];
        
        [vc presentViewController:activityView animated:YES completion:nil];
    }];
}

#pragma mark - Text Height
#pragma mark -

- (CGFloat)heightForAttributedString:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth {
    if ([text isKindOfClass:[NSString class]] && !text.length) {
        // no text means no height
        return 0;
    }
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize size = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:options context:nil].size;
    
    CGFloat height = ceilf(size.height) + 1; // add 1 point as padding
    
    return height;
}

- (CGFloat)heightForString:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxWidth {
    if (![text isKindOfClass:[NSString class]] || !text.length) {
        // no text means no height
        return 0;
    }
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    CGSize size = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:options attributes:attributes context:nil].size;
    CGFloat height = ceilf(size.height) + 1; // add 1 point as padding
    
    return height;
}

- (CGFloat)widthForAttributedString:(NSAttributedString *)text maxWidth:(CGFloat)maxHeight {
    if ([text isKindOfClass:[NSString class]] && !text.length) {
        // no text means no height
        return 0;
    }
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, maxHeight) options:options context:nil].size;
    
    CGFloat width = ceilf(size.width) + 1; // add 1 point as padding
    
    return width;
}

- (CGFloat)widthForString:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxHeight {
    if (![text isKindOfClass:[NSString class]] || !text.length) {
        // no text means no height
        return 0;
    }
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    CGSize size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, maxHeight) options:options attributes:attributes context:nil].size;
    CGFloat width = ceilf(size.width) + 1; // add 1 point as padding
    
    return width;
}

#pragma mark - Layout Constraints
#pragma mark -

- (NSLayoutConstraint *)getTopConstraint:(UIView *)view {
    return [self getConstraintInView:view forLayoutAttribute:NSLayoutAttributeTop];
}

- (NSLayoutConstraint *)getWidthConstraint:(UIView *)view {
    return [self getConstraintInView:view forLayoutAttribute:NSLayoutAttributeWidth];
}

- (NSLayoutConstraint *)getHeightConstraint:(UIView *)view {
    return [self getConstraintInView:view forLayoutAttribute:NSLayoutAttributeHeight];
}

- (NSLayoutConstraint *)getConstraintInView:(UIView *)view forLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    NSLayoutConstraint *foundConstraint = nil;
    
    if (layoutAttribute == NSLayoutAttributeTop || layoutAttribute == NSLayoutAttributeBottom ||
        layoutAttribute == NSLayoutAttributeLeading || layoutAttribute == NSLayoutAttributeTrailing) {
        
        for (NSLayoutConstraint *constraint in view.superview.constraints) {
            if (constraint.firstAttribute == layoutAttribute &&
                [view isEqual:constraint.firstItem]) {
                foundConstraint = constraint;
                break;
            }
        }
    }
    else {
        for (NSLayoutConstraint *constraint in view.constraints) {
            if (constraint.firstAttribute == layoutAttribute &&
                constraint.secondAttribute == NSLayoutAttributeNotAnAttribute) {
                foundConstraint = constraint;
                break;
            }
        }
    }
    
    return foundConstraint;
}

#pragma mark - Loading Images
#pragma mark -

- (void)loadImage:(ImageModel *)imageModel intoImageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage {
    [ImageUtil loadImage:imageModel placeholderImage:placeholderImage withThumbImageBlock:^(UIImage *thumbImage) {
        imageView.image = thumbImage;
    } withFullImageBlock:^(UIImage *fullImage) {
        imageView.image = fullImage;
    } withErrorBlock:^(NSError *error) {
        [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)loadImage:(ImageModel *)imageModel intoButton:(UIButton *)button placeholderImage:(UIImage *)placeholderImage {
    button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    button.clipsToBounds = TRUE;
    
    [ImageUtil loadImage:imageModel placeholderImage:placeholderImage withThumbImageBlock:^(UIImage *thumbImage) {
        [button setImage:thumbImage forState:UIControlStateNormal];
    } withFullImageBlock:^(UIImage *fullImage) {
        [button setImage:fullImage forState:UIControlStateNormal];
    } withErrorBlock:^(NSError *error) {
        [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

@end
