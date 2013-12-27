//
//  UILabelRockwell.m
//  ReceiptScanner
//
//  Created by Josh Holtz on 5/27/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "UILabelRockwell.h"

#import <CoreText/CoreText.h>

@implementation UILabelRockwell

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
        fontName = @"Rockwell-Bold";
    } else if ([self isItalic] == YES) {
        fontName = @"Rockwell-Italic";
    } else {
        fontName = @"Rockwell";
    }
    
    [self setFont:[UIFont fontWithName:fontName size:self.font.pointSize]];
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
