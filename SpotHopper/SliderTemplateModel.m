//
//  SliderTemplateModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/18/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SliderTemplateModel.h"

@implementation SliderTemplateModel

- (NSString *)name {
    return [self objectForKey:@"name"];
}

- (NSString *)minLabel {
    return [self objectForKey:@"min_label"];
}

- (NSString *)maxLabel {
    return [self objectForKey:@"max_label"];
}

- (NSNumber *)defaultValue {
    return [self objectForKey:@"default_value"];
}

- (BOOL)required {
    return [[self objectForKey:@"required"] boolValue];
}

@end
