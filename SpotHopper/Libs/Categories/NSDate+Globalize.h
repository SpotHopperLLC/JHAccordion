//
//  NSDate+Globalize.h
//  TapprLibrary
//
//  Created by Josh Holtz on 5/10/12.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Globalize)

+ (NSDate*)dateFromUTC:(NSString*)str;

+ (NSDate*)dateFromWeirdRuby:(NSString*)str;

- (NSDate*)dateToLocalTimezone;

- (NSString *)stringAsShortDate;
- (NSString *)stringAsShortDateShortTime;

@end
