//
//  SHLabelLatoLight.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/30/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#define kFontName @"Lato-Light"
#define kFontNameItalic @"Lato-LightItalic"

#import "SHLabelLatoLight.h"

#import <CoreText/CoreText.h>

@implementation SHLabelLatoLight

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
    NSString *fontName;
    if ([self isItalic] == YES) {
        fontName = kFontNameItalic;
    } else {
        fontName = kFontName;
    }
    
    UIFont *font = [UIFont fontWithName:fontName size:self.font.pointSize];
    if (font == nil) {
        DebugLog(@"Font not found - %@", fontName);
    }
    [self setFont:font];
}

- (BOOL)isBold {
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, 10, NULL);
    CTFontSymbolicTraits traits = CTFontGetSymbolicTraits(font);
    BOOL isBold = ((traits & kCTFontBoldTrait) == kCTFontBoldTrait);
    CFRelease(font);
    
    return isBold;
}

- (BOOL)isItalic {
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, 10, NULL);
    CTFontSymbolicTraits traits = CTFontGetSymbolicTraits(font);
    BOOL isItalic = ((traits & kCTFontItalicTrait) == kCTFontItalicTrait);
    CFRelease(font);
    
    return isItalic;
}

- (void)italic:(BOOL)italic {
    if (italic == YES) {
        UIFont *font = [UIFont fontWithName:kFontNameItalic size:self.font.pointSize];
        if (font == nil) {
            DebugLog(@"Font not found - %@", kFontNameItalic);
        }
        [self setFont:font];
    } else {
        UIFont *font = [UIFont fontWithName:kFontName size:self.font.pointSize];
        if (font == nil) {
            DebugLog(@"Font not found - %@", kFontName);
        }
        [self setFont:font];
    }
}

@end
