//
//  UserModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 12/26/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#define kUserModelParamEmail @"email"
#define kUserModelParamPassword @"password"

#import "JSONAPIResource.h"

@class ErrorModel;

@interface UserModel : JSONAPIResource<NSCoding>

@property (nonatomic, strong, readonly) NSString *email;
@property (nonatomic, strong, readonly) NSString *role;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSDate *birthday;
@property (nonatomic, strong, readonly) NSDictionary *settings;

+ (void)registerUser:(NSDictionary*)params success:(void(^)(UserModel *userModel, NSHTTPURLResponse *response))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;
+ (void)loginUser:(NSDictionary*)params success:(void(^)(UserModel *userModel, NSHTTPURLResponse *response))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

@end
