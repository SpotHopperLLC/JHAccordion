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

#pragma mark -

- (NSDictionary *)mapKeysToProperties {
    return @{
             @"value" : @"value",
             @"starred" : @"starred",
             @"links.slider_template" : @"sliderTemplate"
             };
}

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ (%@) [%@]", self.ID, self.value, self.sliderTemplate, NSStringFromClass([self class])];
}

- (id)debugQuickLookObject {
    return self.value;
}

#pragma mark - Getters

- (NSString *)name {
    return self.sliderTemplate.name;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	SliderModel *copy = [super copyWithZone:zone];
    
    copy.value = self.value;
    copy.sliderTemplate = self.sliderTemplate;
    copy.starred = self.starred;
    
    return copy;
}

@end
