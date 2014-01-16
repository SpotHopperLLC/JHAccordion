//
//  NSDictionary+Slider.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/15/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "NSDictionary+Slider.h"

@implementation NSDictionary (Slider)

- (NSString *)ID {
    return [self objectForKey:@"ID"];
}

- (NSString *)name {
    return [self objectForKey:@"name"];
}

- (NSString *)min {
    return [self objectForKey:@"min"];
}

- (NSString *)max {
    return [self objectForKey:@"max"];
}

- (NSNumber *)value {
    return [self objectForKey:@"value"];
}

@end
