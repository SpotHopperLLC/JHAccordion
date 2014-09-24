//
//  SHAppUtil.m
//  SpotHopper
//
//  Created by Brennan Stehling on 9/24/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHAppUtil.h"

@implementation SHAppUtil

+ (instancetype)defaultInstance {
    static SHAppUtil *defaultInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        defaultInstance = [[SHAppUtil alloc] init];
    });
    return defaultInstance;
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

@end
