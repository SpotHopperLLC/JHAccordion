//
//  SpotModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SpotModel.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"

@implementation SpotModel

#pragma mark - API

+ (Promise*)getSpots:(NSDictionary*)params success:(void(^)(NSArray *spotModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:@"/api/spots" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"spots"];
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

#pragma mark - Getters

- (NSString *)name {
    return [self objectForKey:@"name"];
}

- (NSString *)imageUrl {
    return [self objectForKey:@"image_url"];
}

- (NSString *)type {
    return [self objectForKey:@"type"];
}

- (NSString *)address {
    return [self objectForKey:@"address"];
}

- (NSString *)phoneNumber {
    return [self objectForKey:@"phone_number"];
}

- (NSArray *)hoursOfOperation {
    return [self objectForKey:@"hours_of_operation"];
}

- (NSNumber *)latitude {
    return [self objectForKey:@"latitude"];
}

- (NSNumber *)longitude {
    return [self objectForKey:@"longitude"];
}

- (NSArray *)sliders {
    return [self objectForKey:@"sliders"];
}

- (NSArray *)sliderTemplates {
    return [self linkedResourceForKey:@"slider_templates"];
}

@end
