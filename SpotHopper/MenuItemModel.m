//
//  MenuItemModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "MenuItemModel.h"

@implementation MenuItemModel

#pragma mark - Debugging
#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", self.ID, self.href];
}

#pragma mark - Mapping
#pragma mark -

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'name' to 'name' property
    // Maps values in JSON key 'featured' to 'price' property
    // Maps values in JSON key 'in_stock' to 'latitude' property
    // Maps linked resource in JSON key 'drink' to 'drink' property
    // Maps linked resource in JSON key 'spot' to 'spot' property
    // Maps linked resource in JSON key 'menu_type' to 'menuType' property
    // Maps linked resource in JSON key 'prices' to 'prices' property
    return @{
             @"name" : @"name",
             @"price" : @"price",
             @"in_stock" : @"inStock",
             @"latitude" : @"latitude",
             @"links.drink" : @"drink",
             @"links.spot" : @"spot",
             @"links.menu_type" : @"menuType",
             @"links.prices" : @"prices"
             };
}

@end
