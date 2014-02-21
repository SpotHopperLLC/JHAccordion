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
#import "SliderTemplateModel.h"

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

+ (Promise*)postSpot:(NSDictionary*)params success:(void(^)(SpotModel *spotModel, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] POST:@"/api/spots" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            SpotModel *model = [jsonApi resourceForKey:@"spots"];
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

-(NSString *)city {
    return [self objectForKey:@"city"];
}

- (NSString *)state {
    return [self objectForKey:@"state"];
}

- (NSString *)zip {
    return [self objectForKey:@"zip"];
}

- (NSString*)cityState {
    if ([self city].length > 0 && [self state].length > 0) {
        return [NSString stringWithFormat:@"%@, %@", [self city], [self state]];
    } else if ([self city].length > 0) {
        return [self city];
    } else if ([self state].length > 0) {
        return [self state];
    }
    
    return nil;
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
    return [[self linkedResourceForKey:@"slider_templates"] sortedArrayUsingComparator:^NSComparisonResult(SliderTemplateModel *obj1, SliderTemplateModel *obj2) {
        return [obj1.ID compare:obj2.ID];
    }];
}

- (SpotTypeModel *)spotType {
    return [self linkedResourceForKey:@"spot_type"];
}

@end
