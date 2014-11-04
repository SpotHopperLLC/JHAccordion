//
//  SHLabelLatoBold.m
//  SpotHopper
//
//  Created by Brennan Stehling on 3/31/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kFontName @"Lato-Bold"

#import "SHLabelLatoBold.h"

@implementation SHLabelLatoBold

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
