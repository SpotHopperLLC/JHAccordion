//
//  NSDate+Util.m
//  ReceiptScanner
//
//  Created by Josh Holtz on 5/28/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "NSDate+Util.h"

@implementation NSDate (Util)

+ (NSDate *)dateAsFirstDayOfWeek {
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:today];
    /*
     Create a date components to represent the number of days to subtract
     from the current date.
     The weekday value for Sunday in the Gregorian calendar is 1, so
     subtract 1 from the number
     of days to subtract from the date in question.  (If today's Sunday,
     subtract 0 days.)
     */
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    /* Substract [gregorian firstWeekday] to handle first day of the week being something else than Sunday */
    [componentsToSubtract setDay: - ([weekdayComponents weekday] - [gregorian firstWeekday])];
    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
    
    /*
     Optional step:
     beginningOfWeek now has the same hour, minute, and second as the
     original date (today).
     To normalize to midnight, extract the year, month, and day components
     and create a new date from those components.
     */
    NSDateComponents *components = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                fromDate: beginningOfWeek];
    beginningOfWeek = [gregorian dateFromComponents: components];
    
    return beginningOfWeek;
}

- (NSDate*)dateToGMT {
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:self];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:self];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    return [[NSDate alloc] initWithTimeInterval:interval sinceDate:self];
}

- (NSDate*)addDays:(NSInteger)numberOfDays {
    // Create and initialize date component instance
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:numberOfDays];
    
    // Retrieve date with increased days count
    NSDate *newDate = [[NSCalendar currentCalendar]
                       dateByAddingComponents:dateComponents
                       toDate:self options:0];
    return newDate;
}

- (NSDate*)addMonths:(NSInteger)numberOfMonths {
    // Create and initialize date component instance
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:numberOfMonths];
    
    // Retrieve date with increased days count
    NSDate *newDate = [[NSCalendar currentCalendar]
                       dateByAddingComponents:dateComponents
                       toDate:self options:0];
    return newDate;
}

+ (NSDateComponents*)timeBetween:(NSDate*)startDate and:(NSDate*)endDate {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    
    return components;
}

@end
