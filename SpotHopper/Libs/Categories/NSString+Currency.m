//
//  NSString+Currency.m
//  TapprLibrary
//
//  Created by Josh Holtz on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+Currency.h"

@implementation NSString (Currency)

- (NSString*)currencyFormat {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    
    return [numberFormatter stringFromNumber:[NSNumber numberWithFloat:[self floatValue]]];
}

@end
