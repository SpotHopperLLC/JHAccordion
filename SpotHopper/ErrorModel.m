//
//  ErrorModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/10/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "ErrorModel.h"

@implementation ErrorModel

- (NSString *)human {
    NSString *human = [self objectForKey:@"human"];
    return (human.length > 0 ? human : @"An unknown error occured");
}

- (NSString *)error {
    return [self objectForKey:@"error"];
}

- (NSDictionary *)validations {
    return [self objectForKey:@"validations"];
}

@end
