//
//  TTTAttributedLabel+QuickFonting.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/4/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "TTTAttributedLabel+QuickFonting.h"

@implementation TTTAttributedLabel (QuickFonting)

- (void)setText:(NSString*)text withFont:(UIFont *)font onString:(NSString*)stringToFont {
    [self setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        NSRange range = [[mutableAttributedString string] rangeOfString:stringToFont options:NSCaseInsensitiveSearch];
        
        if (range.location != NSNotFound && font != nil) {
            
            CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
            if (fontRef) {
                [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:range];
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:range];
                
                CFRelease(fontRef);
            }
        }
        
        return mutableAttributedString;
    }];
}

- (void)setText:(NSString*)text withFont:(UIFont *)font onStrings:(NSArray*)strings {
    [self setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        
        for (NSString *stringToFont in strings) {
        
            NSRange range = [[mutableAttributedString string] rangeOfString:stringToFont options:NSCaseInsensitiveSearch];
            
            if (range.location != NSNotFound && font != nil) {
                
                CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
                if (fontRef) {
                    [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:range];
                    [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:range];
                    
                    CFRelease(fontRef);
                }
            }
        
        }
        return mutableAttributedString;
    }];
}

@end
