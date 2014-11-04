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
#import "UserModel.h"
#import "SpotModel.h"

#import <JSONAPI/JSONAPI.h>

@implementation ReviewModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@/%@ [%@]", self.ID, self.user.name, self.spot.name, NSStringFromClass([self class])];
}

#pragma mark -

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'created_at' to 'Date:createdAt' property
    // Maps values in JSON key 'updated_at' to 'Date:updatedAt' property
    return @{
             @"created_at" : @"Date:createdAt",
             @"updated_at" : @"Date:updatedAt"
             };
    
}

#pragma mark - API

+ (Promise*)getReviews:(NSDictionary*)params success:(void(^)(NSArray *reviewModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:@"/api/reviews" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil, nil);
            }
            
            // Resolves promise
            [deferred resolve];
        }
        else if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"reviews"];
            successBlock(models, jsonApi);
            
            // Resolves promise
            [deferred resolve];
        }
        else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
            
            // Rejects promise
            [deferred rejectWith:errorModel];
        }
    }];
    
    return deferred.promise;
}

- (Promise *)postReviews:(void (^)(ReviewModel *, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    
    // Creating params
    NSArray *jsonSliders = [self createJSONSliderParams:_sliders];
    NSDictionary *params = @{
                             @"drink_id" : _drink.ID != nil ? _drink.ID : [NSNull null],
                             @"spot_id" : _spot.ID != nil ? _spot.ID : [NSNull null],
                             @"rating" : _rating,
                             @"sliders" : jsonSliders
                             };
    
    [[ClientSessionManager sharedClient] POST:@"/api/reviews" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil, nil);
            }
            
            // Resolves promise
            [deferred resolve];
        }
        else if (operation.response.statusCode == 200) {
            ReviewModel *model = [jsonApi resourceForKey:@"reviews"];
            successBlock(model, jsonApi);
            
            // Resolves promise
            [deferred resolve];
        }
        else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
            
            // Rejects promise
            [deferred rejectWith:errorModel];
        }
    }];
    
    return deferred.promise;
}

- (Promise*)putReviews:(NSArray*)sliders successBlock:(void(^)(ReviewModel *reviewModel, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    // Creating params
    NSArray *jsonSliders = [self createJSONSliderParams:sliders];
    NSDictionary *params = @{
                             @"drink_id" : self.drink.ID != nil ? self.drink.ID : [NSNull null],
                             @"spot_id" : self.spot.ID != nil ? self.spot.ID : [NSNull null],
                             @"rating" : self.rating,
                             @"sliders" : jsonSliders
                             };
    
    [[ClientSessionManager sharedClient] PUT:[NSString stringWithFormat:@"/api/reviews/%ld", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil, nil);
            }
            
            // Resolves promise
            [deferred resolve];
        }
        else if (operation.response.statusCode == 200) {
            ReviewModel *model = [jsonApi resourceForKey:@"reviews"];
            successBlock(model, jsonApi);
            
            // Resolves promise
            [deferred resolve];
        }
        else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
            
            // Rejects promise
            [deferred rejectWith:errorModel];
        }
    }];
    
    return deferred.promise;
}

- (NSArray*)createJSONSliderParams:(NSArray*)sliders {
    // Creating params
    NSMutableArray *jsonSliders = [NSMutableArray array];
    for (SliderModel *slider in _sliders) {
        
        // Only send up slider if value is not nil
        if (slider.value != nil) {
            [jsonSliders addObject:@{
                                     @"slider_template_id" : slider.sliderTemplate.ID,
                                     @"value" : slider.value
                                     }];
        }
    }
    
    return jsonSliders;
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
    if (_rating != nil) return _rating;
    _rating = [self objectForKey:@"rating"];
    return _rating;
}

- (NSArray *)sliders {
    if (_sliders == nil) {
        _sliders = [self linkedResourceForKey:@"sliders"];
    }
    
    return [_sliders sortedArrayUsingComparator:^NSComparisonResult(SliderModel *obj1, SliderModel *obj2) {
        return [obj1.sliderTemplate.ID compare:obj2.sliderTemplate.ID];
    }];
}

#pragma mark - SliderModel for rating

// Creates a slider model for review
+ (SliderModel *)ratingSliderModel {
    SliderTemplateModel *sliderTemplateModel = [[SliderTemplateModel alloc] init];
    [sliderTemplateModel setMinLabel:@"Rating"];
    [sliderTemplateModel setDefaultValue:@5];
    
    SliderModel *sliderModel = [[SliderModel alloc] init];
    [sliderModel setSliderTemplate:sliderTemplateModel];
    
    return sliderModel;
}

- (SliderModel *)ratingSliderModel {
    // Don't create rating slider model if spot
    if (_spot != nil) {
        return nil;
    }
    
    // Creates rating slider model if doesn't exist yet
    if (_ratingSliderModel == nil) {
        _ratingSliderModel = [ReviewModel ratingSliderModel];
        
        // Sets rating
        if ([self rating] != nil) {
            [_ratingSliderModel setValue:[self rating]];
        }
        else {
            [_ratingSliderModel setValue:@5];
        }
    }
    
    return _ratingSliderModel;
}

@end
