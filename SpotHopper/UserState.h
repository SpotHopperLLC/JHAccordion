//
//  UserState.h
//  SpotHopper
//
//  Created by Brennan Stehling on 4/17/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserState : NSObject

+ (void)setFirstUseDate:(NSDate*)firstUseDate;
+ (NSDate*)firstUseDate;
+ (void)setSpotlistCount:(NSNumber*)spotlistCount;
+ (NSNumber*)spotlistCount;
+ (void)setDrinklistCount:(NSNumber*)drinklistCount;
+ (NSNumber*)drinklistCount;

@end
