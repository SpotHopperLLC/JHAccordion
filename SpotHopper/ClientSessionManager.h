//
//  ClientSessionManager.h
//  SpotHopper
//
//  Created by Josh Holtz on 12/12/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@class UserModel;

@interface ClientSessionManager : AFHTTPRequestOperationManager

@property (nonatomic, assign) BOOL debug;

+ (instancetype)sharedClient;

- (AFHTTPRequestOperation *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success;
- (AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block success:(void (^)(AFHTTPRequestOperation *, id))success;
- (AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success;
- (AFHTTPRequestOperation *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success;
- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success;

- (NSString *)cookie;
- (void)setCookie:(NSString *)cookie;
- (UserModel *)currentUser;
- (void)setCurrentUser:(UserModel *)currentUser;

- (BOOL)isLoggedIn;
- (void)login:(NSHTTPURLResponse*)response user:(UserModel*)user;
- (void)logout;


@end
