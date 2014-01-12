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

#define kUserModelRoleUser @"user"

#import "SHJSONAPIResource.h"

@class ErrorModel;

@interface UserModel : SHJSONAPIResource

@property (nonatomic, strong, readonly) NSString *email;
@property (nonatomic, strong, readonly) NSString *role;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSDate *birthday;
@property (nonatomic, strong, readonly) NSDictionary *settings;

+ (void)registerUser:(NSDictionary*)params success:(void(^)(UserModel *userModel, NSHTTPURLResponse *response))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;
+ (void)loginUser:(NSDictionary*)params success:(void(^)(UserModel *userModel, NSHTTPURLResponse *response))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

@end
