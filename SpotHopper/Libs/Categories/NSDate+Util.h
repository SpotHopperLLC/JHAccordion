//
//  NSDate+Util.h
//  ReceiptScanner
//
//  Created by Josh Holtz on 5/28/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Util)

+ (NSDate*)dateAsFirstDayOfWeek;
- (NSDate*)dateToGMT;
- (NSDate*)addDays:(NSInteger)numberOfDays;
- (NSDate*)addMonths:(NSInteger)numberOfMonths;
+ (NSDateComponents*)timeBetween:(NSDate*)startDate and:(NSDate*)endDate;

@end
