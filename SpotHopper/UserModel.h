//
//  UserModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 12/26/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#define kUserModelUsers @"users"

#define kUserModelParamEmail @"email"
#define kUserModelParamPassword @"password"
#define kUserModelParamRole @"role"
#define kUserModelParamName @"name"
#define kUserModelParamGender @"gender"
#define kUserModelParamBirthday @"birthday"
#define kUserModelParamSettings @"settings"
#define kUserModelParamLatitude @"latitude"
#define kUserModelParamLongitude @"longitude"
#define kUserModelParamFacebookAccessToken @"facebook_access_token"
#define kUserModelParamsTwitterAccessToken @"twitter_access_token"
#define kUserModelParamsTwitterAccessTokenSecret @"twitter_access_token_secret"

#define kReviewModelParamsSpotId @"spot_id"
#define kReviewModelParamsDrinkId @"drink_id"

#define kUserModelRoleUser @"user"

#import "SHJSONAPIResource.h"

#import <JSONAPI/JSONAPI.h>

@class ErrorModel, ReviewModel;

@interface UserModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *facebookId;
@property (nonatomic, strong) NSString *twitterId;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSDictionary *settings;
@property (nonatomic, strong) NSString *gender;

+ (Promise*)registerUser:(NSDictionary*)params success:(void(^)(UserModel *userModel, NSHTTPURLResponse *response))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;
+ (Promise*)loginUser:(NSDictionary*)params success:(void(^)(UserModel *userModel, NSHTTPURLResponse *response))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

- (Promise*)getUser:(NSDictionary*)params success:(void(^)(UserModel *userModel, NSHTTPURLResponse *response))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;
- (Promise*)putUser:(NSDictionary*)params success:(void(^)(UserModel *userModel, NSHTTPURLResponse *response))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

- (Promise*)getReviews:(NSDictionary*)params success:(void(^)(NSArray *reviewModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;
- (Promise*)getReview:(NSDictionary*)params success:(void(^)(ReviewModel *reviewModel, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

- (Promise *)getSpotLists:(NSDictionary *)params success:(void (^)(NSArray *, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock;
- (Promise *)getDrinkLists:(NSDictionary *)params success:(void (^)(NSArray *, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock;

- (Promise *)getCheckIns:(NSDictionary *)params success:(void(^)(NSArray *checkInModels, JSONAPI* jsonAPI))successBlock failure:(void(^)(ErrorModel* errorModel))failureBlock;

#pragma mark - Revised Code for 2.0

+ (BOOL)isLoggedIn;
+ (UserModel *)currentUser;

+ (void)updateUser:(UserModel *)user success:(void(^)(UserModel *updatedUser))successBlock failure:(void(^)(ErrorModel* errorModel))failureBlock;
+ (Promise *)updateUser:(UserModel *)user;

+ (void)fetchSpotsForUser:(UserModel *)user query:(NSString *)query page:(NSNumber *)page pageSize:(NSNumber *)pageSize success:(void(^)(NSArray *spots))successBlock failure:(void(^)(ErrorModel* errorModel))failureBlock;
+ (Promise *)fetchSpotsForUser:(UserModel *)user query:(NSString *)query page:(NSNumber *)page pageSize:(NSNumber *)pageSize;

@end
