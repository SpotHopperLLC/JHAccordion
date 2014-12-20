//
//  MenuTypeModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/23/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "MenuTypeModel.h"

@implementation MenuTypeModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%@)", self.name, self.ID];
}

#pragma mark -

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'name' to 'name' property
    // Maps linked resource in JSON key 'drink_type' to 'drinkType' property
    // Maps linked resource in JSON key 'drink_subtypes' to 'drinkSubtypes' property
    return @{
             @"name" : @"name",
             @"links.drink_type" : @"drinkType",
             @"links.drink_subtypes" : @"drinkSubtypes",
             };
}

@end
