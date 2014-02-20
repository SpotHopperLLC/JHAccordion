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
#define kUserModelParamFacebookAccessToken @"facebook_access_token"
#define kUserModelParamsTwitterAccessToken @"twitter_access_token"
#define kUserModelParamsTwitterAccessTokenSecret @"twitter_access_token_secret"

#define kReviewModelParamsSpotId @"spot_id"
#define kReviewModelParamsDrinkId @"drink_id"

#define kUserModelRoleUser @"user"

#import "SHJSONAPIResource.h"

#import <JSONAPI/JSONAPI.h>

@class ErrorModel;

@interface UserModel : SHJSONAPIResource

@property (nonatomic, strong, readonly) NSString *email;
@property (nonatomic, strong, readonly) NSString *role;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *facebookId;
@property (nonatomic, strong, readonly) NSString *twitterId;
@property (nonatomic, strong, readonly) NSDate *birthday;
@property (nonatomic, strong, readonly) NSDictionary *settings;

+ (Promise*)registerUser:(NSDictionary*)params success:(void(^)(UserModel *userModel, NSHTTPURLResponse *response))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;
+ (Promise*)loginUser:(NSDictionary*)params success:(void(^)(UserModel *userModel, NSHTTPURLResponse *response))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

- (Promise*)getReviews:(NSDictionary*)params success:(void(^)(NSArray *reviewModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

@end
