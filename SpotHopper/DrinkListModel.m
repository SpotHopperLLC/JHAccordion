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
#import "SliderModel.h"
#import "SliderTemplateModel.h"
#import "DrinkModel.h"

#import <CoreLocation/CoreLocation.h>

@implementation DrinkListModel

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'name' to 'name' property
    // Maps values in JSON key 'featured' to 'featured' property
    // Maps values in JSON key 'latitude' to 'latitude' property
    // Maps values in JSON key 'longitude' to 'longitude' property
    // Maps linked resource in JSON key 'spots' to 'spots' property
    return @{
             @"name" : @"name",
             @"featured" : @"featured",
             @"latitude" : @"latitude",
             @"longitude" : @"longitude",
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

+ (Promise *)postDrinkList:(NSString*)name latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude sliders:(NSArray*)sliders successBlock:(void (^)(DrinkListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock {
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

@end
