//
//  DrinkModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "DrinkModel.h"

@implementation DrinkModel

#pragma mark - Getters

- (NSString *)name {
    return [self objectForKey:@"name"];
}

- (NSString *)type {
    return [self objectForKey:@"type"];
}

- (NSString *)subtype {
    return [self objectForKey:@"subtype"];
}

- (NSString *)descriptionOfDrink {
    return [self objectForKey:@"description"];
}

- (NSNumber *)alcoholByVolume {
    return [self objectForKey:@"alcohol_by_volume"];
}

- (NSString *)style {
    return [self objectForKey:@"style"];
}

- (NSNumber *)vintage {
    return [self objectForKey:@"vintage"];
}

- (NSNumber *)region {
    return [self objectForKey:@"region"];
}

- (NSString *)recipe {
    return [self objectForKey:@"receipe"];
}

- (SpotModel *)spot {
    return [self linkedResourceForKey:@"spots"];
}

- (NSNumber *)spotId {
    return [self objectForKey:@"spot_id"];
}

@end
