//
//  DrinkModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "DrinkModel.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"

@implementation DrinkModel

#pragma mark - API

+ (Promise*)getDrinks:(NSDictionary*)params success:(void(^)(NSArray *drinkModels, JSONAPI *jsonAPI))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
     
    [[ClientSessionManager sharedClient] GET:@"/api/drinks" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"drinks"];
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

- (NSString *)subtype {
    return [self objectForKey:@"subtype"];
}

- (NSString *)descriptionOfDrink {
    return [self objectForKey:@"description"];
}

- (NSNumber *)abv {
    return [self objectForKey:@"abv"];
}

- (NSString*)abvPercentString {
    return [NSString stringWithFormat:@"%.02f %%", (self.abv.floatValue * 100.0f)];
}

- (NSString *)style {
    return [self objectForKey:@"style"];
}

- (NSNumber *)vintage {
    return [self objectForKey:@"vintage"];
}

- (NSNumber *)region {
    return [self objectForKey:@"region"];
}

- (NSString *)recipe {
    return [self objectForKey:@"receipe"];
}

- (SpotModel *)spot {
    return [self linkedResourceForKey:@"spot"];
}

- (NSNumber *)spotId {
    return [self objectForKey:@"spot_id"];
}

- (NSArray *)sliderTemplates {
    return [self linkedResourceForKey:@"slider_templates"];
}

@end
