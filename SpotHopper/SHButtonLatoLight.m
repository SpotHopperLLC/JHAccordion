//
//  SHButtonLatoLight.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/30/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#define kFontName @"Lato-Light"

#import "SHButtonLatoLight.h"

@implementation SHButtonLatoLight

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupLatoLight];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLatoLight];
    }
    return self;
}

- (void)setupLatoLight {
    UIFont *font = [UIFont fontWithName:kFontName size:self.titleLabel.font.pointSize];
    if (font == nil) {
        NSLog(@"Font not found - %@", kFontName);
    }
    [self.titleLabel setFont:font];
}

@end
