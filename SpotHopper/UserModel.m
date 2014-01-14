//
//  UserModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/26/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "UserModel.h"

#import <JSONAPI/JSONAPI.h>

#import "ClientSessionManager.h"
#import "ErrorModel.h"

@implementation UserModel

#pragma mark - API

+ (void)registerUser:(NSDictionary*)params success:(void(^)(UserModel *userModel, NSHTTPURLResponse *response))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    
    [[ClientSessionManager sharedClient] logout];
    
    NSDictionary *wrappedParams = @{
               kUserModelUsers : @[params]
               };
    
    [[ClientSessionManager sharedClient] POST:@"/api/users" parameters:wrappedParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == 200) {
            [UserModel loginUser:params success:successBlock failure:failureBlock];
        } else {
            JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
            
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
        }
    }];
    
}

+ (void)loginUser:(NSDictionary*)params success:(void(^)(UserModel *userModel, NSHTTPURLResponse *response))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    
    [[ClientSessionManager sharedClient] logout];
    
    [[ClientSessionManager sharedClient] POST:@"/api/sessions" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            UserModel *userModel = [jsonApi resourceForKey:@"users"];
            
            NSLog(@"All request cookies - %@", [operation.request allHTTPHeaderFields]);
            [[ClientSessionManager sharedClient] login:operation.response user:userModel];
            
            successBlock(userModel, operation.response);
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
        }
    }];
    
}

#pragma mark - Getters

- (NSString *)email {
    return [self objectForKey:@"email"];
}

- (NSString *)role {
    return [self objectForKey:@"role"];
}

- (NSString *)name {
    return [self objectForKey:@"name"];
}

- (NSDate *)birthday {
    return [self formatBirthday:[self objectForKey:@"birthday"]];
}

- (NSDictionary *)settings {
    return [self objectForKey:@"settings"];
}

@end
