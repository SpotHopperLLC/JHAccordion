//
//  PriceModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/31/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "PriceModel.h"

#import "NSNumber+Currency.h"

#import "SizeModel.h"

@implementation PriceModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ [%@]", self.ID, self.priceAndSize, NSStringFromClass([self class])];
}

#pragma mark -

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'cents' to 'cents' property
    // Maps values in JSON key 'size' to 'size' property
    return @{
             @"cents" : @"cents",
             @"links.size" : @"size"
             };
}

- (NSString *)priceAndSize {
    if (_cents.floatValue == 0.0f && !_size.name.length) {
        return nil;
    }
    
    NSString *price = [NSNumber numberWithFloat:(_cents.floatValue / 100.0f)].currencyFormat;
    if (_cents.floatValue != 0.0f && _size.name.length) {
        return [NSString stringWithFormat:@"%@ / %@", price, _size.name];
    } else if (_cents != nil) {
        return price;
    }
    else if (_size.name.length) {
        return _size.name;
    }
    
    return nil;
}

@end
