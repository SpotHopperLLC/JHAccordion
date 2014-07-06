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
#import "UserModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubTypeModel.h"

#import "DrinkListRequest.h"

#import <CoreLocation/CoreLocation.h>

@interface DrinkListCache : NSCache

- (NSArray *)cachedDrinklists;
- (void)cacheDrinklists:(NSArray *)drinklists;

@end

@implementation DrinkListModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ (%@) [%@]", self.ID, self.name, self.drinkType.name, NSStringFromClass([self class])];
}

#pragma mark -

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'name' to 'name' property
    // Maps values in JSON key 'featured' to 'featured' property
    // Maps values in JSON key 'latitude' to 'latitude' property
    // Maps values in JSON key 'longitude' to 'longitude' property
    // Maps linked resource in JSON key 'drinks' to 'drinks' property
    // Maps linked resource in JSON key 'spot' to 'spot' property
    // Maps linked resource in JSON key 'sliders' to 'sliders' property
    // Maps linked resource in JSON key 'drink_type' to 'drinkType' property
    // Maps linked resource in JSON key 'drink_subtype' to 'drinkSubtype' property
    return @{
             @"name" : @"name",
             @"featured" : @"featured",
             @"latitude" : @"latitude",
             @"longitude" : @"longitude",
             @"links.drinks" : @"drinks",
             @"links.spot" : @"spot",
             @"links.sliders" : @"sliders",
             @"links.drink_type" : @"drinkType",
             @"links.drink_subtype" : @"drinkSubtype"
             };
}

- (CLLocation *)location {
    if (_latitude != nil && _longitude != nil) {
        return [[CLLocation alloc] initWithLatitude:_latitude.floatValue longitude:_longitude.floatValue];
    }
    return nil;
}

#pragma mark - API

+ (Promise *)getFeaturedDrinkLists:(NSDictionary *)params success:(void (^)(NSArray *drinklists, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    
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

+ (Promise *)postDrinkList:(NSString*)name latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude sliders:(NSArray*)sliders drinkId:(NSNumber*)drinkId drinkTypeId:(NSNumber*)drinkTypeId drinkSubtypeId:(NSNumber*)drinkSubtypeId baseAlcoholId:(NSNumber*)baseAlcoholId spotId:(NSNumber*)spotId successBlock:(void (^)(DrinkListModel *, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
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

- (Promise *)getDrinkList:(NSDictionary *)params success:(void (^)(DrinkListModel *drinkListModel, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    
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

- (Promise *)putDrinkList:(NSString*)name latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude spotId:(NSNumber*)spotId sliders:(NSArray*)sliders success:(void (^)(DrinkListModel *drinklist, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    
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

- (Promise *)deleteDrinkList:(NSDictionary *)params success:(void (^)(DrinkListModel *drinkListModel, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    
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

#pragma mark - Caching

+ (DrinkListCache *)sh_sharedCache {
    static DrinkListCache *_sh_Cache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sh_Cache = [[DrinkListCache alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_sh_Cache removeAllObjects];
        }];
    });
    
    return _sh_Cache;
}

#pragma mark - Revised Code for 2.0

+ (void)refreshSpotlistCache {
    [[self sh_sharedCache] cacheDrinklists:nil];
    if ([UserModel isLoggedIn]) {
        [[self fetchMyDrinkLists] then:^(NSArray *spotlists) {
            DebugLog(@"Refreshed drinklist cache");
        } fail:nil always:nil];
    }
}

+ (void)fetchMyDrinkLists:(void (^)(NSArray *spotlists))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    NSArray *drinklists = [[DrinkListModel sh_sharedCache] cachedDrinklists];
    if (drinklists.count && successBlock) {
        successBlock(drinklists);
        return;
    }
    
    UserModel *user = [UserModel currentUser];
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/users/%ld/drink_lists", (long)[user.ID integerValue]] parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            NSArray *drinklists = [jsonApi resourcesForKey:@"drink_lists"];
            NSMutableArray *filteredDrinklist = @[].mutableCopy;
            for (DrinkListModel *drinklist in drinklists) {
                // delete spotlists with default names (temporary measure)
                if ([kDrinkListModelDefaultName isEqualToString:drinklist.name]) {
                    [[drinklist purgeDrinkList] then:^(id value) {
                        DebugLog(@"Deleted spotlist %@", drinklist.ID);
                    } fail:nil always:nil];
                }
                else {
                    [filteredDrinklist addObject:drinklist];
                }
            }
            
            [[DrinkListModel sh_sharedCache] cacheDrinklists:filteredDrinklist];
            if (successBlock) {
                successBlock(filteredDrinklist);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

+ (Promise *)fetchMyDrinkLists {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self fetchMyDrinkLists:^(NSArray *drinklists) {
        [deferred resolveWith:drinklists];
    } failure:^(ErrorModel *errorModel) {
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

+ (NSDictionary *)prepareSearchParametersWithRequest:(DrinkListRequest *)request {
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
    
    return params;
}

+ (void)createDrinkListWithRequest:(DrinkListRequest *)request success:(void (^)(DrinkListModel *drinkListModel))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    NSDictionary *params = [self prepareSearchParametersWithRequest:request];
    
    [[ClientSessionManager sharedClient] POST:@"/api/drink_lists" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            DrinkListModel *model = [jsonApi resourceForKey:@"drink_lists"];
            
            // limit to 10
            if (model.drinks.count > 10) {
                model.drinks = [model.drinks subarrayWithRange:NSMakeRange(0, 10)];
            }
            
            if (successBlock) {
                successBlock(model);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

+ (void)updateDrinkListWithRequest:(DrinkListRequest *)request success:(void (^)(DrinkListModel *drinkListModel))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    NSDictionary *params = [self prepareSearchParametersWithRequest:request];
    
    [[ClientSessionManager sharedClient] PUT:[NSString stringWithFormat:@"/api/drink_lists/%ld", (long)[request.drinkListId integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            DrinkListModel *model = [jsonApi resourceForKey:@"drink_lists"];
            
            // limit to 10
            if (model.drinks.count > 10) {
                model.drinks = [model.drinks subarrayWithRange:NSMakeRange(0, 10)];
            }
            
            if (successBlock) {
                successBlock(model);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

+ (void)fetchFeaturedDrinkListWithRequest:(DrinkListRequest *)request success:(void (^)(DrinkListModel *drinkListModel))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    NSDictionary *params = [self prepareSearchParametersWithRequest:request];

    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/drink_lists/%ld", (long)[request.drinkListId integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            DrinkListModel *model = [jsonApi resourceForKey:@"drink_lists"];
            if (successBlock) {
                successBlock(model);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

+ (void)fetchDrinkListWithRequest:(DrinkListRequest *)request success:(void (^)(DrinkListModel *drinkListModel))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    // if request has a drinklist id then it is an updated (PUT) otherwise it is a create (POST) action and both should return a result set with an identical structure
    if (!request.drinkListId) {
        [self createDrinkListWithRequest:request success:successBlock failure:failureBlock];
    }
    else if (request.drinkListId && request.isFeatured) {
        [self fetchFeaturedDrinkListWithRequest:request success:successBlock failure:failureBlock];
    }
    else {
        [self updateDrinkListWithRequest:request success:successBlock failure:failureBlock];
    }
}

+ (Promise *)fetchDrinkListWithRequest:(DrinkListRequest *)request {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];

    [self fetchDrinkListWithRequest:request success:^(DrinkListModel *drinkListModel) {
        // Resolves promise
        [deferred resolveWith:drinkListModel];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

- (void)fetchDrinkList:(void (^)(DrinkListModel *spotlist))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/drink_lists/%ld", (long)[self.ID integerValue]] parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            DrinkListModel *model = [jsonApi resourceForKey:@"drink_lists"];
            if (successBlock) {
                successBlock(model);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

- (Promise *)fetchDrinkList {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self fetchDrinkList:^(DrinkListModel *drinklist) {
        // Resolves promise
        [deferred resolveWith:drinklist];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

- (void)purgeDrinkList:(void (^)(BOOL success))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    [[ClientSessionManager sharedClient] DELETE:[NSString stringWithFormat:@"/api/drink_lists/%ld", (long)[self.ID integerValue]] parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200 || operation.response.statusCode == 204) {
            // update the cache
            NSMutableArray *cachedSpotlists = [[DrinkListModel sh_sharedCache] cachedDrinklists].mutableCopy;
            [cachedSpotlists removeObject:cachedSpotlists];
            [[DrinkListModel sh_sharedCache] cacheDrinklists:cachedSpotlists];
            
            successBlock(TRUE);
        }
        else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
        }
    }];
}

- (Promise *)purgeDrinkList {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self purgeDrinkList:^(BOOL success) {
        // Resolves promise
        [deferred resolveWith:[NSNumber numberWithBool:success]];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

#pragma mark -

@end

@implementation DrinkListCache

NSString * const DrinklistsKey = @"Drinklists";

- (NSArray *)cachedDrinklists {
    return [self objectForKey:DrinklistsKey];
}

- (void)cacheDrinklists:(NSArray *)spotlists {
    if (spotlists.count) {
        [self setObject:spotlists forKey:DrinklistsKey];
        
        // automatically expire the cache after 90 seconds to ensure it does not get stale
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(expireSpotlistsCache) object:nil];
        [self performSelector:@selector(expireSpotlistsCache) withObject:self afterDelay:90];
    }
    else {
        [self removeObjectForKey:DrinklistsKey];
    }
}

- (void)expireSpotlistsCache {
    [self cacheDrinklists:nil];
}

@end
