//
//  SliderModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/18/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SliderModel.h"

#import "SliderTemplateModel.h"

@implementation SliderModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ (%@) [%@]", self.ID, self.value, self.sliderTemplate, NSStringFromClass([self class])];
}

- (id)debugQuickLookObject {
    return self.value;
}

#pragma mark - Getters

- (NSNumber *)value {
    if (_value != nil) return _value;
    _value = [self objectForKey:@"value"];
    return _value;
//    return [self objectForKey:@"value"];
}

- (SliderTemplateModel *)sliderTemplate {
    if (_sliderTemplate != nil) return _sliderTemplate;
    _sliderTemplate = [self linkedResourceForKey:@"slider_template"];
    return _sliderTemplate;
}

@end
