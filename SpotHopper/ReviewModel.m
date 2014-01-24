//
//  ReviewModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "ReviewModel.h"

#import "ClientSessionManager.h"
#import "DrinkModel.h"
#import "ErrorModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"
#import "SpotModel.h"

#import <JSONAPI/JSONAPI.h>

@implementation ReviewModel

#pragma mark - API

+ (Promise*)getReviews:(NSDictionary*)params success:(void(^)(NSArray *reviewModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:@"/api/reviews" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"reviews"];
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

- (Promise *)postReviews:(void (^)(ReviewModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    NSLog(@"JSON Sliders - %@", _sliders);
    
    // Creating params
    NSMutableArray *jsonSliders = [NSMutableArray array];
    for (SliderModel *slider in _sliders) {
        [jsonSliders addObject:@{
                                 @"slider_template_id" : slider.sliderTemplate.ID,
                                 @"value" : slider.value
                                 }];
    }
    NSLog(@"JSON Sliders - %@", jsonSliders);
    NSLog(@"Drink - %@", _drink);
    NSLog(@"Spot - %@", _spot);
    NSLog(@"Rating - %@", _rating);
    NSDictionary *params = @{
                             @"drink_id" : _drink.ID != nil ? _drink.ID : [NSNull null],
                             @"spot_id" : _spot.ID != nil ? _spot.ID : [NSNull null],
                             @"rating" : _rating,
                             @"sliders" : jsonSliders
                             };
    NSLog(@"Params - %@", params);
    
    [[ClientSessionManager sharedClient] POST:@"/api/reviews" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            ReviewModel *model = [jsonApi resourceForKey:@"reviews"];
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

- (Promise*)putReviews:(void(^)(ReviewModel *reviewModel, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    // Creating params
    NSMutableArray *jsonSliders = [NSMutableArray array];
    for (SliderModel *slider in self.sliders) {
        [jsonSliders addObject:@{
                                 @"slider_template_id" : slider.sliderTemplate.ID,
                                 @"value" : slider.value
                                 }];
    }
    NSDictionary *params = @{
                             @"drink_id" : self.drink.ID != nil ? self.drink.ID : [NSNull null],
                             @"spot_id" : self.spot.ID != nil ? self.spot.ID : [NSNull null],
                             @"rating" : self.rating,
                             @"sliders" : jsonSliders
                             };
    
    [[ClientSessionManager sharedClient] PUT:[NSString stringWithFormat:@"/api/reviews/%d", self.ID.integerValue] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            ReviewModel *model = [jsonApi resourceForKey:@"reviews"];
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

- (UserModel *)user {
    return [self linkedResourceForKey:@"user"];
}

- (NSNumber *)userId {
    return [self objectForKey:@"user_id"];
}

- (SpotModel *)spot {
    return [self linkedResourceForKey:@"spot"];
}

- (NSNumber *)spotId {
    return [self objectForKey:@"spot_id"];
}

- (DrinkModel *)drink {
    return [self linkedResourceForKey:@"drink"];
}

- (NSNumber *)drinkId {
    return [self objectForKey:@"drink_id"];
}

- (NSNumber *)rating {
    return [self objectForKey:@"rating"];
}

- (NSArray *)sliders {
    return [self linkedResourceForKey:@"sliders"];
}

- (NSDate *)createdAt {
    return [self formatDateTimestamp:[self objectForKey:@"created_at"]];
}

- (NSDate *)updatedAt {
    return [self formatDateTimestamp:[self objectForKey:@"updated_at"]];
}

@end
