//
//  SHEnums.m
//  SpotHopper
//
//  Created by Brennan Stehling on 8/19/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHModelFormatters.h"

#import <JSONAPI/JSONAPI.h>

@implementation SHModelFormatters

+ (void)registerFormatters {
    NSDateFormatter *dateFormatterSeconds = [[NSDateFormatter alloc] init];
    [dateFormatterSeconds setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatterSeconds setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSDateFormatter *dateFormatterMilliseconds = [[NSDateFormatter alloc] init];
    [dateFormatterMilliseconds setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatterMilliseconds setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    // Date
    [JSONAPIResourceFormatter registerFormat:@"Date" withBlock:^id(id jsonValue) {
        NSDate *date = nil;
        NSError *error = nil;
        
        if ([jsonValue isKindOfClass:[NSString class]]) {
            NSString *dateString = (NSString *)jsonValue;
            if (dateString.length) {
                if (![dateFormatterSeconds getObjectValue:&date forString:jsonValue range:nil error:&error]) {
                    // if it fails with seconds try milliseconds
                    if (![dateFormatterMilliseconds getObjectValue:&date forString:jsonValue range:nil error:&error]) {
                        DebugLog(@"Date '%@' could not be parsed: %@", jsonValue, error);
                    }
                }
            }
        }
        
        return date;
    }];
    
    // Time
    [JSONAPIResourceFormatter registerFormat:@"Time" withBlock:^id(id jsonValue) {
        NSDate *date = nil;
        
        if ([jsonValue isKindOfClass:[NSString class]]) {
            NSString *timeString = (NSString *)jsonValue;
            if (timeString.length) {
                
                // sample: 19:00:00
                date = [NSDate date];
                DebugLog(@"date: %@", date);
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSCalendarUnit units = NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSTimeZoneCalendarUnit;
                NSDateComponents *components = [calendar components:units fromDate:date];
                
                NSArray *parts = [timeString componentsSeparatedByString:@":"];
                if (parts.count == 3) {
                    [components setHour:[parts[0] integerValue]];
                    [components setMinute:[parts[1] integerValue]];
                    [components setSecond:[parts[2] integerValue]];
                    DebugLog(@"components: %@", components);
                }
                
                date = [calendar dateFromComponents:components];
                DebugLog(@"date: %@", date);
            }
        }
        
        return date;
    }];
    
    // Weekday
    [JSONAPIResourceFormatter registerFormat:@"Weekday" withBlock:^id(id jsonValue) {
        NSInteger weekday = [jsonValue integerValue];
        
        return [NSNumber numberWithInteger:weekday];
    }];
}

@end
