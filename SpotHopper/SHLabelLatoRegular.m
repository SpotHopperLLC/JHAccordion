//
//  SHLabelLatoRegular.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/15/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kFontName @"Lato-Regular"

#import "SHLabelLatoRegular.h"

@implementation SHLabelLatoRegular

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
    UIFont *font = [UIFont fontWithName:kFontName size:self.font.pointSize];
    if (font == nil) {
        DebugLog(@"Font not found - %@", kFontName);
    }
    [self setFont:font];
}

@end
