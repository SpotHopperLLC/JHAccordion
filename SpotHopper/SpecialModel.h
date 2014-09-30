//
//  SpecialModel.h
//  SpotHopper
//
//  Created by Brennan Stehling on 8/19/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHJSONAPIResource.h"

#import <JSONAPI/JSONAPI.h>

#import "SHModelResourceManager.h"

@class SpotModel, ErrorModel;

@interface SpecialModel : SHJSONAPIResource

@property (copy, nonatomic) NSString *text;
@property (assign, nonatomic) SHWeekday weekday;
@property (assign, nonatomic) NSUInteger likeCount;
@property (copy, nonatomic) NSString *startTimeString;
@property (assign, nonatomic) NSTimeInterval duration; // seconds
@property (strong, nonatomic) SpotModel *spot;

@property (assign, nonatomic) BOOL userLikesSpecial;

@property (readonly, nonatomic) NSDate *startTime;
@property (readonly, nonatomic) NSDate *endTime;
@property (readonly, nonatomic) NSString *timeString;
@property (readonly, nonatomic) NSString *weekdayString;
@property (readonly, nonatomic) NSUInteger durationInMinutes;

@property (readonly, nonatomic) NSDate *startTimeForToday;
@property (readonly, nonatomic) NSDate *endTimeForToday;

- (NSDate *)startTimeForDate:(NSDate *)date;
- (NSDate *)endTimeForDate:(NSDate *)date;

+ (SpecialModel *)specialForToday:(NSArray *)specials;

////// Service Layer //////

+ (void)fetchSpecialsForSpot:(SpotModel *)spot success:(void(^)(NSArray *specials))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;
+ (Promise *)fetchSpecialsForSpot:(SpotModel *)spot;

+ (void)fetchSpecial:(SpecialModel *)special success:(void(^)(SpecialModel *special))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;
+ (Promise *)fetchSpecial:(SpecialModel *)special;

+ (void)saveSpecial:(SpecialModel *)special success:(void(^)(SpecialModel *special))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;
+ (Promise *)saveSpecial:(SpecialModel *)special;

+ (void)purgeSpecial:(SpecialModel *)special success:(void(^)(BOOL success))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;
+ (Promise *)purgeSpecial:(SpecialModel *)special;

@end
