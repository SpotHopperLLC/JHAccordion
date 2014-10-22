//
//  CheckInModel.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/5/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#define kCheckInModelParamPage @"page_number"
#define kCheckInModelParamsPageSize @"page_size"
#define kCheckInModelParamQuery @"query"

#define kCheckInModelParamCheckInId @"id"
#define kCheckInModelParamSpotId @"spot_id"
#define kCheckInModelParamUserId @"user_id"
#define kCheckInModelParamText @"text"

#import "SHJSONAPIResource.h"

#import <JSONAPI/JSONAPI.h>

@class ErrorModel, SpotModel, UserModel;

@interface CheckInModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *createdAtStr;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) UserModel *user;
@property (nonatomic, strong) SpotModel *spot;

- (Promise *)getCheckIn:(NSDictionary *)params success:(void(^)(CheckInModel *checkInModel, JSONAPI* jsonAPI))successBlock failure:(void(^)(ErrorModel* errorModel))failureBlock;
- (Promise *)postCheckIn:(NSDictionary *)params success:(void(^)(CheckInModel *checkInModel, JSONAPI* jsonAPI))successBlock failure:(void(^)(ErrorModel* errorModel))failureBlock;
- (Promise *)putCheckIn:(NSDictionary *)params success:(void(^)(CheckInModel *checkInModel, JSONAPI* jsonAPI))successBlock failure:(void(^)(ErrorModel* errorModel))failureBlock;

#pragma mark - Revised Code for 2.0

+ (void)checkInAtSpot:(SpotModel *)spot success:(void(^)(CheckInModel *checkin))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;
+ (Promise *)checkInAtSpot:(SpotModel *)spot;

@end
