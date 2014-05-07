//
//  CheckInModel.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/5/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "CheckInModel.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"

@implementation CheckInModel

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'text' to 'text' property
    // Maps values in JSON key 'created_at' to 'createdAtStr' property
    // Maps linked resource in JSON key 'user' to 'user' property
    // Maps linked resource in JSON key 'spot' to 'spot' property
    return @{
             @"text" : @"text",
             @"created_at" : @"createdAtStr",
             @"links.user" : @"user",
             @"links.spot" : @"spot"
             };
}

- (NSDate *)createdAt {
    if (_createdAt != nil) return _createdAt;
    _createdAt = [self formatDateTimestamp:[self createdAtStr]];
    return _createdAt;
}

- (Promise *)getCheckIn:(NSDictionary *)params success:(void(^)(CheckInModel *checkInModel, JSONAPI* jsonAPI))successBlock failure:(void(^)(ErrorModel* errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/checkins/%li", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            CheckInModel *model = [jsonApi resourceForKey:@"checkins"];
            successBlock(model, jsonApi);
            
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

- (Promise *)postCheckIn:(NSDictionary *)params success:(void(^)(CheckInModel *checkInModel, JSONAPI* jsonAPI))successBlock failure:(void(^)(ErrorModel* errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] POST:@"/api/checkins" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            CheckInModel *model = [jsonApi resourceForKey:@"checkins"];
            successBlock(model, jsonApi);
            
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

- (Promise *)putCheckIn:(NSDictionary *)params success:(void(^)(CheckInModel *checkInModel, JSONAPI* jsonAPI))successBlock failure:(void(^)(ErrorModel* errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] PUT:[NSString stringWithFormat:@"/api/checkins/%li", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            CheckInModel *model = [jsonApi resourceForKey:@"checkins"];
            successBlock(model, jsonApi);
            
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
