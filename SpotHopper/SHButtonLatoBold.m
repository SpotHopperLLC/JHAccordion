//
//  SHButtonLatoBold.m
//  SpotHopper
//
//  Created by Brennan Stehling on 4/8/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kFontName @"Lato-Bold"

#import "SHButtonLatoBold.h"

@implementation SHButtonLatoBold

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    UIFont *font = [UIFont fontWithName:kFontName size:self.titleLabel.font.pointSize];
    if (font == nil) {
        NSLog(@"Font not found - %@", kFontName);
    }
    [self.titleLabel setFont:font];
}

@end
