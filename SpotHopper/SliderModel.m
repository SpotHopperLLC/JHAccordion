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
    NSMutableArray *details = @[].mutableCopy;
    
    if (self.starred) {
        [details addObject:@"Starred"];
    }
    
    if (self.sliderTemplate.showInSummary) {
        [details addObject:@"Show in Summary"];
    }
    
    [details addObject:self.sliderTemplate.description];

    return [NSString stringWithFormat:@"%@ - %@ (%@) [%@]", self.ID, self.value, details, NSStringFromClass([self class])];
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

#pragma mark - Comparison

- (NSComparisonResult)compare:(SliderModel *)otherSlider {
    // compare starred
    // compare sliderTemplate.showInSummary
    // compare order or importance?
    
    NSComparisonResult result = NSOrderedSame;
    
    // first check starred
    if (self.starred && !otherSlider.starred) {
        result = (NSComparisonResult)NSOrderedAscending;
    }
    else if (!self.starred && otherSlider.starred) {
        result = (NSComparisonResult)NSOrderedDescending;
    }
    else {
        // now check showInSummary
        if (self.sliderTemplate.showInSummary && !otherSlider.sliderTemplate.showInSummary) {
            result = (NSComparisonResult)NSOrderedAscending;
        }
        else if (!self.sliderTemplate.showInSummary && otherSlider.sliderTemplate.showInSummary) {
            result = (NSComparisonResult)NSOrderedDescending;
        }
        else {
            result = [self.sliderTemplate.order compare:otherSlider.sliderTemplate.order];
        }
    }
    
    return result;
    
}

@end
