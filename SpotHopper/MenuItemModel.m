//
//  MenuItemModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "MenuItemModel.h"

@implementation MenuItemModel

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'price' to 'name' property
    // Maps values in JSON key 'featured' to 'price' property
    // Maps values in JSON key 'in_stock' to 'latitude' property
    // Maps linked resource in JSON key 'drinks' to 'drinks' property
    // Maps linked resource in JSON key 'spots' to 'spots' property
    return @{
             @"name" : @"name",
             @"price" : @"price",
             @"in_stock" : @"inStock",
             @"latitude" : @"latitude",
             @"links.drinks" : @"drinks",
             @"links.spots" : @"spots",
             };
}

@end
