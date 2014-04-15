//
//  NSArray+HoursOfOperation.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/15/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "NSArray+HoursOfOperation.h"

@implementation NSArray (HoursOfOperation)

- (NSArray*)datesForToday {
    // Get durrent day number of week
    NSDate *now = [NSDate date];
    
    return [self datesForNow:now];
}

- (NSArray*)datesForNow:(NSDate*)now {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSDayCalendarUnit|NSTimeZoneCalendarUnit fromDate:now];

    // Get open and close time
    NSInteger dayOfWeek = [comps weekday];
    NSInteger dayOfWeekYesterday = dayOfWeek - 1;
    if (dayOfWeekYesterday < 1) {
        // If today is Sunday, yesterday should be Saturday
        // And for some reason this is like the only thing in the world that doesn't start counting from 0
        dayOfWeekYesterday = 7;
    }
    
    // Gets open and close times for today and yesterday (since today COULD still fall into yesterday's open time if close was 2am)
    NSString *timeOpenYesterday = [self closeForDayOfWeek:dayOfWeekYesterday];
    NSString *timeCloseYesterday = [self closeForDayOfWeek:dayOfWeekYesterday];
    NSString *timeOpen = [self openForDayOfWeek:dayOfWeek];
    NSString *timeClose = [self closeForDayOfWeek:dayOfWeek];
    
    
    // Converts yesterdays hours to NSDate objects
    NSDate *dateOpenYesterday = nil, *dateCloseYesterday = nil;
    if (timeOpenYesterday.length > 0 && timeCloseYesterday.length > 0) {
        dateOpenYesterday = [self makeDateFromTime:timeOpenYesterday withGregorian:gregorian withDateComponents:comps withDateOpen:nil isYesterday:YES];
        dateCloseYesterday = [self makeDateFromTime:timeCloseYesterday withGregorian:gregorian withDateComponents:comps withDateOpen:dateOpenYesterday isYesterday:YES];
    }
    
    // Converts todays hours to NSDate objects
    NSDate *dateOpen = nil, *dateClose = nil;
    if (timeOpen.length > 0 && timeClose.length > 0) {
        dateOpen = [self makeDateFromTime:timeOpen withGregorian:gregorian withDateComponents:comps withDateOpen:nil isYesterday:NO];
        dateClose = [self makeDateFromTime:timeClose withGregorian:gregorian withDateComponents:comps withDateOpen:dateOpen isYesterday:NO];
    }

    // If less than close yesterday, its still yesterday
    if (dateOpenYesterday && dateCloseYesterday && [now timeIntervalSinceDate:dateCloseYesterday] < 0) {
        return @[ dateOpenYesterday, dateCloseYesterday ];
    }
    // Else if less than close today it is today
    else if (dateOpen && dateClose && [now timeIntervalSinceDate:dateClose] < 0) {
        return @[ dateOpen, dateClose ];
    }

    return nil;
}

#pragma mark - Private

- (NSString*)openForDayOfWeek:(NSInteger)dayOfWeek {
    dayOfWeek = dayOfWeek - 1;
    
    NSArray *hoursToday = [self objectAtIndex:dayOfWeek];
    NSString *timeOpen = [hoursToday firstObject];
    
    if ([timeOpen isEqual:[NSNull null]]) {
        return nil;
    }
    
    return timeOpen;
}

- (NSString*)closeForDayOfWeek:(NSInteger)dayOfWeek {
    dayOfWeek = dayOfWeek - 1;
    
    NSArray *hoursToday = [self objectAtIndex:dayOfWeek];
    NSString *timeClose = [hoursToday lastObject];
    
    if ([timeClose isEqual:[NSNull null]]) {
        return nil;
    }
    
    return timeClose;
}

- (NSDate*)makeDateFromTime:(NSString*)time withGregorian:(NSCalendar*)gregorian withDateComponents:(NSDateComponents*)comps withDateOpen:(NSDate*)dateOpen isYesterday:(BOOL)isYesterday {
    if (time.length == 0) {
        return nil;
    }
    
    // Formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"hh:mm a"];
    
    // Start date
    NSError *error = nil;
    NSDate *date;
    if ([dateFormatter getObjectValue:&date forString:time range:nil error:&error]) {
        
        // Sets the open and close time to an actual date so we can compare
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:date];
        [components setSecond:0];
        [components setDay:[comps day] - ( isYesterday ? 1 : 0 )]; // Subtracts a day if we are looking at yesterdays hours
        [components setMonth:[comps month]];
        [components setYear:[comps year]];
        [components setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        date = [calendar dateFromComponents:components];
        
        //Add extra day cause the close is tomorrow, not before the start (dur)
        if (dateOpen != nil && [date timeIntervalSinceDate:dateOpen] < 0) {
            [components setDay:[comps day]+1];
            date = [calendar dateFromComponents:components];
        }
    }
    
    return date;
}

@end
