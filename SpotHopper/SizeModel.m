//
//  SizeModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/31/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SizeModel.h"

@implementation SizeModel

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'name' to 'name' property
    return @{
             @"name" : @"name"
             };
}

@end
