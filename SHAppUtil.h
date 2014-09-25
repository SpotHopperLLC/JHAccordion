//
//  SHAppUtil.h
//  SpotHopper
//
//  Created by Brennan Stehling on 9/24/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageModel;

@interface SHAppUtil : NSObject

+ (instancetype)defaultInstance;

#pragma mark - Text Height
#pragma mark -

- (CGFloat)heightForAttributedString:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth;

- (CGFloat)heightForString:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxWidth;

- (CGFloat)widthForAttributedString:(NSAttributedString *)text maxWidth:(CGFloat)maxHeight;

- (CGFloat)widthForString:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxHeight;

#pragma mark - Layout Constraints
#pragma mark -

- (NSLayoutConstraint *)getTopConstraint:(UIView *)view;

- (NSLayoutConstraint *)getWidthConstraint:(UIView *)view;

- (NSLayoutConstraint *)getHeightConstraint:(UIView *)view;

- (NSLayoutConstraint *)getConstraintInView:(UIView *)view forLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

#pragma mark - Loading Images
#pragma mark -

- (void)loadImage:(ImageModel *)imageModel intoImageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage;

- (void)loadImage:(ImageModel *)imageModel intoButton:(UIButton *)button placeholderImage:(UIImage *)placeholderImage;

@end
