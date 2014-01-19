//
//  SliderModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/18/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SliderModel.h"

@implementation SliderModel

- (NSNumber *)value {
    return [self objectForKey:@"value"];
}

- (SliderTemplateModel *)sliderTemplate {
    return [self linkedResourceForKey:@"slider_template"];
}

@end
