//
//  SpecialModel.h
//  SpotHopper
//
//  Created by Brennan Stehling on 8/19/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHJSONAPIResource.h"

#import <JSONAPI/JSONAPI.h>

#import "SHModelFormatters.h"

@class SpotModel, ErrorModel;

@interface SpecialModel : SHJSONAPIResource

@property (copy, nonatomic) NSString *text;
@property (assign, nonatomic) SHWeekday weekday;
@property (assign, nonatomic) NSInteger likeCount;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
@property (strong, nonatomic) SpotModel *spot;

@property (readonly, nonatomic) NSString *weekdayString;
@property (readonly, nonatomic) NSString *startTimeString;
@property (readonly, nonatomic) NSString *endTimeString;

+ (void)fetchSpecialsForSpot:(SpotModel *)spot success:(void(^)(NSArray *specials))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;
+ (Promise *)fetchSpecialsForSpot:(SpotModel *)spot;

+ (void)fetchSpecial:(SpecialModel *)special success:(void(^)(SpecialModel *special))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;
+ (Promise *)fetchSpecial:(SpecialModel *)special;

+ (void)saveSpecial:(SpecialModel *)special success:(void(^)(SpecialModel *special))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;
+ (Promise *)saveSpecial:(SpecialModel *)special;

+ (void)purgeSpecial:(SpecialModel *)special success:(void(^)(BOOL success))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;
+ (Promise *)purgeSpecial:(SpecialModel *)special;

@end
