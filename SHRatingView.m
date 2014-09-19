//
//  SHRatingView.m
//  SpotHopper
//
//  Created by Brennan Stehling on 9/19/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHRatingView.h"

#import "SHStyleKit+Additions.h"

#pragma mark - Class Extension
#pragma mark -

@interface SHRatingView ()

@property (weak, nonatomic) UIImageView *imageView;

@end

@implementation SHRatingView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    if (!self.imageView) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:imageView];
        
        self.imageView = imageView;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(imageView);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:views]];
        
        UIImage *image = [SHStyleKit drawImageForRatingStarsWithPercentage:(self.percentage * 10) size:self.frame.size];
        self.imageView.image = image;
    }
}

- (void)setPercentage:(CGFloat)percentage {
    _percentage = percentage;
    
    UIImage *image = [SHStyleKit drawImageForRatingStarsWithPercentage:(_percentage * 10) size:self.frame.size];
    self.imageView.image = image;
}

@end
