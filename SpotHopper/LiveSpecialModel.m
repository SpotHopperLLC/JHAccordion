//
//  LiveSpecialModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/26/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "LiveSpecialModel.h"

@implementation LiveSpecialModel

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'text' to 'text' property
    // Maps values in JSON key 'start_date' to 'startDateStr' property
    // Maps values in JSON key 'end_date' to 'endDateStr' property
    // Maps linked resource in JSON key 'spot' to 'spot' property
    return @{
             @"text" : @"text",
             @"start_date" : @"startDateStr",
             @"end_date" : @"endDateStr",
             @"links.spot" : @"spot"
             };
}

- (NSDate *)startDate {
    return [self formatDateTimestamp:[self startDateStr]];
}

- (NSDate *)endDate {
    return [self formatDateTimestamp:[self endDateStr]];
}

@end
