//
//  AverageReviewModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/5/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "AverageReviewModel.h"

@implementation AverageReviewModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", self.ID, self.href];
}

#pragma mark -

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'rating' to 'rating' property
    // Maps linked resource in JSON key 'sliders' to 'sliders' property
    // Maps linked resource in JSON key 'drink' to 'drink' property
    // Maps linked resource in JSON key 'spot' to 'spot' property
    return @{
             @"rating" : @"rating",
             @"links.sliders" : @"sliders",
             @"links.drink" : @"drink",
             @"links.spot" : @"spot",
             };
    
}

@end
