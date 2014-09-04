//
//  SizeModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/31/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SizeModel.h"

@implementation SizeModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ [%@]", self.ID, self.href, NSStringFromClass([self class])];
}

#pragma mark -

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'name' to 'name' property
    return @{
             @"name" : @"name",
             @"links.menu_types": @"menuTypes"
             };
}

@end
 