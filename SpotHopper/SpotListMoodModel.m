//
//  SpotListMoodModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/12/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SpotListMoodModel.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"

@implementation SpotListMoodModel

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'name' to 'rating' name
    // Maps linked resource in JSON key 'sliders' to 'sliders' property
    return @{
             @"name" : @"name",
             @"links.sliders" : @"sliders",
             };
    
}

#pragma mark - API

+ (Promise *)getSpotListMoods:(NSDictionary *)params success:(void (^)(NSArray *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock {
    
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:@"/api/spot_list_moods" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"spot_list_moods"];
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
