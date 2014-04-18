//
//  UserState.m
//  SpotHopper
//
//  Created by Brennan Stehling on 4/17/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "UserState.h"

#define kFirstUseDate           @"UserState_FirstUseDate"
#define kSpotlistCount          @"UserState_SpotlistCount"
#define kDrinklistCount         @"UserState_DrinklistCount"

@implementation UserState

+ (void)setFirstUseDate:(NSDate*)firstUseDate {
    if (firstUseDate) {
        [[NSUserDefaults standardUserDefaults] setObject:firstUseDate forKey:kFirstUseDate];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFirstUseDate];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDate*)firstUseDate {
    NSDate *firstUseDate = [[NSUserDefaults standardUserDefaults] objectForKey:kFirstUseDate];
    return firstUseDate;
}

+ (void)setSpotlistCount:(NSNumber*)spotlistCount {
    if (spotlistCount) {
        [[NSUserDefaults standardUserDefaults] setObject:spotlistCount forKey:kSpotlistCount];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSpotlistCount];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSNumber*)spotlistCount {
    NSNumber *spotlistCount = [[NSUserDefaults standardUserDefaults] objectForKey:kSpotlistCount];
    return spotlistCount;
}

+ (void)setDrinklistCount:(NSNumber*)drinklistCount {
    if (drinklistCount) {
        [[NSUserDefaults standardUserDefaults] setObject:drinklistCount forKey:kDrinklistCount];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDrinklistCount];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSNumber*)drinklistCount {
    NSNumber *drinklistCount = [[NSUserDefaults standardUserDefaults] objectForKey:kDrinklistCount];
    return drinklistCount;
}

@end
