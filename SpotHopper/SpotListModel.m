//
//  SpotListModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/4/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kMaxRadius @5.0f

#import "SpotListModel.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"
#import "SpotModel.h"
#import "SpotListRequest.h"

#import <CoreLocation/CoreLocation.h>

@implementation SpotListModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ [%@]", self.ID, self.href, NSStringFromClass([self class])];
}

#pragma mark - Properties
- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'name' to 'name' property
    // Maps values in JSON key 'featured' to 'featured' property
    // Maps values in JSON key 'latitude' to 'latitude' property
    // Maps values in JSON key 'longitude' to 'longitude' property
    // Maps values in JSON key 'radius' to 'radius' property
    // Maps linked resource in JSON key 'spots' to 'spots' property
    return @{
             @"name" : @"name",
             @"featured" : @"featured",
             @"latitude" : @"latitude",
             @"longitude" : @"longitude",
             @"radius" : @"radius",
             @"links.spots" : @"spots",
             };
    
}

- (CLLocation *)location {
    if (_latitude != nil && _longitude != nil) {
        return [[CLLocation alloc] initWithLatitude:_latitude.floatValue longitude:_longitude.floatValue];
    }
    return nil;
}

#pragma mark - API

+ (Promise *)getFeaturedSpotLists:(NSDictionary *)params success:(void (^)(NSArray *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock {
    
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:@"/api/spot_lists/featured" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"spot_lists"];
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

+ (Promise *)postSpotList:(NSString*)name spotId:(NSNumber*)spotId spotTypeId:(NSNumber*)spotTypeId latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude sliders:(NSArray*)sliders successBlock:(void (^)(SpotListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock {
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
                             kSpotListModelParamBasedOnSlider : [NSNumber numberWithBool:YES]
                             }.mutableCopy;
    
    if (spotId != nil) {
        [params setObject:spotId forKey:@"spot_id"];
    }
    
    if (spotTypeId != nil) {
        [params setObject:spotTypeId forKey:@"spot_type_id"];
    }
    
    if (latitude != nil && longitude != nil) {
        [params setObject:latitude forKey:kSpotListModelParamLatitude];
        [params setObject:longitude forKey:kSpotListModelParamLongitude];
    }
    
    [[ClientSessionManager sharedClient] POST:@"/api/spot_lists" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            SpotListModel *model = [jsonApi resourceForKey:@"spot_lists"];
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

- (Promise *)getSpotList:(NSDictionary *)params success:(void (^)(SpotListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock {
    
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/spot_lists/%ld", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            SpotListModel *model = [jsonApi resourceForKey:@"spot_lists"];
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

- (Promise *)putSpotList:(NSString*)name latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude radius:(NSNumber*)radius sliders:(NSArray*)sliders success:(void (^)(SpotListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock {
    
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    NSMutableDictionary *params = @{  }.mutableCopy;
    
    if (name.length > 0) {
        [params setObject:name forKey:@"name"];
    }
    
    if (latitude != nil && longitude != nil) {
        [params setObject:latitude forKey:kSpotListModelParamLatitude];
        [params setObject:longitude forKey:kSpotListModelParamLongitude];
    }
    
    if (radius != nil) {
        // Make sure it doesn't go above max radius
        [params setObject:( [radius compare:kMaxRadius] == NSOrderedDescending ? kMaxRadius : radius ) forKey:kSpotListModelParamRadius];
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
    
    [[ClientSessionManager sharedClient] PUT:[NSString stringWithFormat:@"/api/spot_lists/%ld", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200 || operation.response.statusCode == 204) {
            SpotListModel *model = [jsonApi resourceForKey:@"spot_lists"];
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

- (Promise *)deleteSpotList:(NSDictionary *)params success:(void (^)(SpotListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock {
    
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] DELETE:[NSString stringWithFormat:@"/api/spot_lists/%ld", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200 || operation.response.statusCode == 204) {
            SpotListModel *model = [jsonApi resourceForKey:@"spot_lists"];
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

+ (void)fetchSpotListWithRequest:(SpotListRequest *)request success:(void (^)(SpotListModel *spotListModel, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
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
                                    @"name" : request.name,
                                    @"sliders" : jsonSliders,
                                    kSpotListModelParamBasedOnSlider : [NSNumber numberWithBool:YES]
                                    }.mutableCopy;
    
    if (request.spotId != nil) {
        [params setObject:request.spotId forKey:@"spot_id"];
    }
    
    if (request.spotTypeId != nil) {
        [params setObject:request.spotTypeId forKey:@"spot_type_id"];
    }
    
    if (CLLocationCoordinate2DIsValid(request.coordinate)) {
        [params setObject:[NSNumber numberWithFloat:request.coordinate.latitude] forKey:kSpotListModelParamLatitude];
        [params setObject:[NSNumber numberWithFloat:request.coordinate.longitude] forKey:kSpotListModelParamLongitude];
    }
    
    [[ClientSessionManager sharedClient] POST:@"/api/spot_lists" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            SpotListModel *model = [jsonApi resourceForKey:@"spot_lists"];
            
            // limit to 10
            if (model.spots.count > 10) {
                model.spots = [model.spots subarrayWithRange:NSMakeRange(0, 10)];
            }
            
            successBlock(model, jsonApi);
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
        }
    }];
}

+ (Promise *)fetchSpotListWithRequest:(SpotListRequest *)request {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self fetchSpotListWithRequest:request success:^(SpotListModel *spotListModel, JSONAPI *jsonApi) {
        // Resolves promise
        [deferred resolveWith:spotListModel];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

@end
