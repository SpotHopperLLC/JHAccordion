//
//  SpotModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SpotModel.h"

@implementation SpotModel

#pragma mark - Getters

- (NSString *)name {
    return [self objectForKey:@"name"];
}

- (NSString *)type {
    return [self objectForKey:@"type"];
}

- (NSString *)address {
    return [self objectForKey:@"address"];
}

- (NSString *)phoneNumber {
    return [self objectForKey:@"phone_number"];
}

- (NSArray *)hoursOfOperation {
    return [self objectForKey:@"hoursOfOperation"];
}

- (NSNumber *)latitude {
    return [self objectForKey:@"latitude"];
}

- (NSNumber *)longitude {
    return [self objectForKey:@"longitude"];
}

- (NSDictionary *)sliders {
    return [self objectForKey:@"sliders"];
}

@end
