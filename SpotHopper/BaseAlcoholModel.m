//
//  BaseAlcoholModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/21/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseAlcoholModel.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"

@implementation BaseAlcoholModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", self.ID, self.href];
}

#pragma mark -

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'name' to 'name' property
    return @{
             @"name" : @"name"
             };
}

#pragma mark - API

+ (Promise *)getBaseAlcohols:(NSDictionary *)params success:(void (^)(NSArray *, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:@"/api/base_alcohols" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"base_alcohols"];
            successBlock(models, jsonApi);
            
            // Resolves promise
            [deferred resolve];
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
            
            // Rejects promise
            [deferred rejectWith:errorModel];
        }
    }];
    
    return deferred.promise;
    
}

@end
