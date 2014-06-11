//
//  DrinkListModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "DrinkListModel.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"
#import "DrinkTypeModel.h"
#import "SpotModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"
#import "DrinkModel.h"

#import "DrinkListRequest.h"

#import <CoreLocation/CoreLocation.h>

@implementation DrinkListModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ [%@]", self.ID, self.href, NSStringFromClass([self class])];
}

#pragma mark -

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'name' to 'name' property
    // Maps values in JSON key 'featured' to 'featured' property
    // Maps values in JSON key 'latitude' to 'latitude' property
    // Maps values in JSON key 'longitude' to 'longitude' property
    // Maps linked resource in JSON key 'drinks' to 'drinks' property
    // Maps linked resource in JSON key 'spot' to 'spot' property
    return @{
             @"name" : @"name",
             @"featured" : @"featured",
             @"latitude" : @"latitude",
             @"longitude" : @"longitude",
             @"links.drinks" : @"drinks",
             @"links.spot" : @"spot"
             };
    
}

//- (SpotModel *)spot {
//    if (_spot != nil) return _spot;
//    _spot = [self linkedResourceForKey:@"spot"];
//    return _spot;
//}

- (CLLocation *)location {
    if (_latitude != nil && _longitude != nil) {
        return [[CLLocation alloc] initWithLatitude:_latitude.floatValue longitude:_longitude.floatValue];
    }
    return nil;
}

#pragma mark - API

+ (Promise *)getFeaturedDrinkLists:(NSDictionary *)params success:(void (^)(NSArray *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock {
    
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:@"/api/drink_lists/featured" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"drink_lists"];
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

+ (Promise *)postDrinkList:(NSString*)name latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude sliders:(NSArray*)sliders drinkId:(NSNumber*)drinkId drinkTypeId:(NSNumber*)drinkTypeId drinkSubtypeId:(NSNumber*)drinkSubtypeId baseAlcoholId:(NSNumber*)baseAlcoholId spotId:(NSNumber*)spotId successBlock:(void (^)(DrinkListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    // Creating params
    NSMutableArray *jsonSliders = [NSMutableArray array];
    for (SliderModel *slider in sliders) {
        if (slider.value != nil) {
            [jsonSliders addObject:@{
                                     @"slider_template_id" : slider.sliderTemplate.ID,
                                     @"value" : slider.value,
                                     }];
        }
    }
    
    NSMutableDictionary *params = @{
                                    @"name" : name,
                                    @"sliders" : jsonSliders,
                                    kDrinkListModelParamBasedOnSlider : [NSNumber numberWithBool:YES]
                                    }.mutableCopy;
    
    if (drinkId != nil) {
        [params setObject:drinkId forKey:@"drink_id"];
    }
    if (drinkTypeId != nil) {
        [params setObject:drinkTypeId forKey:@"drink_type_id"];
    }
    if (drinkSubtypeId != nil) {
        [params setObject:drinkSubtypeId forKey:@"drink_subtype_id"];
    }
    if (baseAlcoholId != nil) {
        [params setObject:baseAlcoholId forKey:@"base_alcohol_id"];
    }
    if (spotId != nil) {
        [params setObject:spotId forKey:@"spot_id"];
    }
    
    if (latitude != nil && longitude != nil) {
        [params setObject:latitude forKey:kDrinkListModelParamLatitude];
        [params setObject:longitude forKey:kDrinkListModelParamLongitude];
    }
    
    [[ClientSessionManager sharedClient] POST:@"/api/drink_lists" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            DrinkListModel *model = [jsonApi resourceForKey:@"drink_lists"];
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

- (Promise *)getDrinkList:(NSDictionary *)params success:(void (^)(DrinkListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock {
    
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/drink_lists/%ld", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            DrinkListModel *model = [jsonApi resourceForKey:@"drink_lists"];
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

- (Promise *)putDrinkList:(NSString*)name latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude spotId:(NSNumber*)spotId sliders:(NSArray*)sliders success:(void (^)(DrinkListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock {
    
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    NSMutableDictionary *params = @{  }.mutableCopy;
    
    if (name.length > 0) {
        [params setObject:name forKey:@"name"];
    }
    
    if (spotId != nil) {
        [params setObject:spotId forKey:@"spot_id"];
    } else if (spotId == nil) {
        [params setObject:[NSNull null] forKey:@"spot_id"];
    }
    
    if (latitude != nil && longitude != nil) {
        [params setObject:latitude forKey:kDrinkListModelParamLatitude];
        [params setObject:longitude forKey:kDrinkListModelParamLongitude];
    }
    
    // Creating params
    if (sliders != nil) {
        NSMutableArray *jsonSliders = [NSMutableArray array];
        for (SliderModel *slider in sliders) {
            [jsonSliders addObject:@{
                                     @"slider_template_id" : slider.sliderTemplate.ID,
                                     @"value" : slider.value
                                     }];
        }
        
        [params setObject:jsonSliders forKey:@"sliders"];
    }
    
    
    
    [[ClientSessionManager sharedClient] PUT:[NSString stringWithFormat:@"/api/drink_lists/%ld", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200 || operation.response.statusCode == 204) {
            DrinkListModel *model = [jsonApi resourceForKey:@"drink_lists"];
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

- (Promise *)deleteDrinkList:(NSDictionary *)params success:(void (^)(DrinkListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock {
    
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] DELETE:[NSString stringWithFormat:@"/api/drink_lists/%ld", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200 || operation.response.statusCode == 204) {
            DrinkListModel *model = [jsonApi resourceForKey:@"drink_lists"];
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

#pragma mark - Revised Code for 2.0

+ (void)fetchDrinkListWithRequest:(DrinkListRequest *)request success:(void (^)(DrinkListModel *drinkListModel, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    // Creating params
    NSMutableArray *jsonSliders = [NSMutableArray array];
    for (SliderModel *slider in request.sliders) {
        if (slider.value != nil) {
            [jsonSliders addObject:@{
                                     @"slider_template_id" : slider.sliderTemplate.ID,
                                     @"value" : slider.value,
                                     }];
        }
    }
    
    NSMutableDictionary *params = @{
                                    kSpotModelParamPage : @1,
                                    kSpotModelParamsPageSize : @10,
                                    @"name" : request.name,
                                    @"sliders" : jsonSliders,
                                    kDrinkListModelParamBasedOnSlider : [NSNumber numberWithBool:YES]
                                    }.mutableCopy;
    
    if (request.drinkId != nil) {
        [params setObject:request.drinkId forKey:@"drink_id"];
    }
    if (request.drinkTypeId != nil) {
        [params setObject:request.drinkTypeId forKey:@"drink_type_id"];
    }
    if (request.drinkSubTypeId != nil) {
        [params setObject:request.drinkSubTypeId forKey:@"drink_subtype_id"];
    }
    if (request.baseAlcoholId != nil) {
        [params setObject:request.baseAlcoholId forKey:@"base_alcohol_id"];
    }
    if (request.spotId != nil) {
        [params setObject:request.spotId forKey:@"spot_id"];
    }
    
    if (CLLocationCoordinate2DIsValid(request.coordinate)) {
        [params setObject:[NSNumber numberWithFloat:request.coordinate.latitude] forKey:kDrinkListModelParamLatitude];
        [params setObject:[NSNumber numberWithFloat:request.coordinate.longitude] forKey:kDrinkListModelParamLongitude];
    }
    
    [[ClientSessionManager sharedClient] POST:@"/api/drink_lists" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            DrinkListModel *model = [jsonApi resourceForKey:@"drink_lists"];
            
            if (model.drinks.count > 10) {
                model.drinks = [model.drinks subarrayWithRange:NSMakeRange(0, 10)];
            }
            
            if (successBlock) {
                successBlock(model, jsonApi);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

+ (Promise *)fetchDrinkListWithRequest:(DrinkListRequest *)request {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];

    [self fetchDrinkListWithRequest:request success:^(DrinkListModel *drinkListModel, JSONAPI *jsonApi) {
        // Resolves promise
        [deferred resolveWith:drinkListModel];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

#pragma mark -

@end
