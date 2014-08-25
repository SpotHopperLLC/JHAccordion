//
//  NSArray+DailySpecials.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/26/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "NSArray+DailySpecials.h"

@implementation NSArray (DailySpecials)

- (NSString*)specialsForToday {
    // Get durrent day number of week
    NSDate *now = [NSDate date];
    
    return [self specialsForNow:now];
}

- (NSString*)specialsForNow:(NSDate*)now {
    NSAssert(now, @"Date must be defined");
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSDayCalendarUnit|NSTimeZoneCalendarUnit fromDate:now];
    
    // Get special on day (1 indexed so subtracting one)
    NSInteger dayOfWeek = [comps weekday] - 1;
    
    if (dayOfWeek >= 0 && dayOfWeek <= 6 && dayOfWeek < self.count) {
        NSString *result = [self objectAtIndex:dayOfWeek];
        if ([result isEqual:[NSNull null]]) {
            return nil;
        }
        
        return result;
    }
    
    return nil;
}


@end
