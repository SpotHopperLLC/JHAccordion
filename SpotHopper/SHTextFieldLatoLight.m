//
//  SHTextFieldLatoLight.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/30/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#define kFontName @"Lato-Light"

#import "SHTextFieldLatoLight.h"

@implementation SHTextFieldLatoLight

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
    [self setBorderStyle:UITextBorderStyleNone];
    
    UIFont *font = [UIFont fontWithName:kFontName size:self.font.pointSize];
    if (font == nil) {
        NSLog(@"Font not found - %@", kFontName);
    }
    [self setFont:font];
}

@end
