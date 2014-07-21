//
//  NSNumber+Currency.m
//  ReceiptScanner
//
//  Created by Josh Holtz on 5/27/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "NSNumber+Currency.h"

@implementation NSNumber (Currency)

- (NSString*)currencyFormat {
    static NSNumberFormatter *numberFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:[NSLocale currentLocale]];
    });
    
    return [numberFormatter stringFromNumber:self];
}

@end
