//
//  UILabelGotham.m
//  KohlsEverywhere
//
//  Created by Josh Holtz on 6/27/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "UILabelGotham.h"

#import <CoreText/CoreText.h>

@implementation UILabelGotham

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    NSString *fontName;
    if ([self isBold] == YES) {
        fontName = @"Gotham-Bold";
    } else if ([self isItalic] == YES) {
        fontName = @"Gotham-BoldItalic";
    } else {
        fontName = @"Gotham-Medium";
    }
    
    UIFont *font = [UIFont fontWithName:fontName size:self.font.pointSize];
    
    if (font != nil) {
        [self setFont:font];
    } else {
        DebugLog(@"Cannot find font - %@", fontName);
        DebugLog(@"Available fonts are...");
        for(NSString* family in [UIFont familyNames]) {
            DebugLog(@"  %@", family);
            for(NSString* name in [UIFont fontNamesForFamilyName: family]) {
                DebugLog(@"    %@", name);
            }
        }
    }
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

@end
