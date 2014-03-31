//
//  PriceModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/31/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "PriceModel.h"

@implementation PriceModel

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'cents' to 'cents' property
    // Maps values in JSON key 'size' to 'size' property
    return @{
             @"cents" : @"cents",
             @"links.size" : @"size"
             };
}

@end
