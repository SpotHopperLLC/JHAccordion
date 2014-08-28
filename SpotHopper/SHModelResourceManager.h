//
//  SHEnums.h
//  SpotHopper
//
//  Created by Brennan Stehling on 8/19/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SHWeekdayNone = -1,
    SHWeekdaySunday = 0,
    SHWeekdayMonday = 1,
    SHWeekdayTuesday = 2,
    SHWeekdayWednesday = 3,
    SHWeekdayThursday = 4,
    SHWeekdayFriday = 5,
    SHWeekdaySaturday = 6
} SHWeekday;

@interface SHModelResourceManager : NSObject

+ (void)prepareResources;

@end
