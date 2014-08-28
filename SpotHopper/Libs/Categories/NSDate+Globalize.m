//
//  NSDate+Globalize.m
//  TapprLibrary
//
//  Created by Josh Holtz on 5/10/12.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "NSDate+Globalize.h"

@implementation NSDate (Globalize)

+ (NSDate*)dateFromUTC:(NSString*)str {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'S"];
    
    return [[dateFormatter dateFromString:str] dateToLocalTimezone];
}

+ (NSDate*)dateFromWeirdRuby:(NSString*)str {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss '+'S"];
    
    return [[dateFormatter dateFromString:str] dateToLocalTimezone];
}

- (NSDate*)dateToLocalTimezone {
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:self];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:self];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    return [[NSDate alloc] initWithTimeInterval:interval sinceDate:self];
}

- (NSString *)stringAsShortDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy"];
    
    return [dateFormatter stringFromDate:self];
}

- (NSString *)stringAsShortDateShortTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
    
    return [dateFormatter stringFromDate:self];
}

@end
