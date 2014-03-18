//
//  NSArray+HoursOfOperation.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/15/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (HoursOfOperation)

- (NSArray*)datesForToday;

// THIS SHOULD ONLY GET CALLED PUBLICLY WHEN TESTING, OKAY?
- (NSArray*)datesForNow:(NSDate*)now;

@end
