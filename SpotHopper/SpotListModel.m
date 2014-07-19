//
//  SpotListModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/4/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kMinRadiusFloat 0.5f
#define kMaxRadiusFloat 5.0f
#define kMaxRadius @kMaxRadiusFloat
#define kMetersPerMile 1609.344

#import "SpotListModel.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"
#import "SpotModel.h"
#import "SpotListRequest.h"
#import "UserModel.h"

#import <CoreLocation/CoreLocation.h>

@interface SpotListCache : NSCache

- (NSArray *)cachedSpotlists;
- (void)cacheSpotlists:(NSArray *)spotlists;

@end

@implementation SpotListModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ [%@]", self.ID, self.name, NSStringFromClass([self class])];
}

#pragma mark - Properties
- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'name' to 'name' property
    // Maps values in JSON key 'featured' to 'featured' property
    // Maps values in JSON key 'latitude' to 'latitude' property
    // Maps values in JSON key 'longitude' to 'longitude' property
    // Maps values in JSON key 'radius' to 'radius' property
    // Maps linked resource in JSON key 'spots' to 'spots' property
    // Maps linked resource in JSON key 'sliders' to 'sliders' property
    return @{
             @"name" : @"name",
             @"featured" : @"featured",
             @"latitude" : @"latitude",
             @"longitude" : @"longitude",
             @"radius" : @"radius",
             @"links.spots" : @"spots",
             @"links.sliders" : @"sliders"
             };
}

- (CLLocation *)location {
    if (_latitude != nil && _longitude != nil) {
        return [[CLLocation alloc] initWithLatitude:_latitude.floatValue longitude:_longitude.floatValue];
    }
    return nil;
}

#pragma mark - API

+ (Promise *)getFeaturedSpotLists:(NSDictionary *)params success:(void (^)(NSArray *, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:@"/api/spot_lists/featured" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil, nil);
            }
        }
        else if (operation.response.statusCode == 200) {
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

+ (Promise *)postSpotList:(NSString*)name spotId:(NSNumber*)spotId spotTypeId:(NSNumber*)spotTypeId latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude sliders:(NSArray*)sliders successBlock:(void (^)(SpotListModel *, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
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
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil, nil);
            }
        }
        else if (operation.response.statusCode == 200) {
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

- (Promise *)getSpotList:(NSDictionary *)params success:(void (^)(SpotListModel *, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/spot_lists/%ld", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil, nil);
            }
        }
        else if (operation.response.statusCode == 200) {
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

- (Promise *)putSpotList:(NSString*)name latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude radius:(NSNumber*)radius sliders:(NSArray*)sliders success:(void (^)(SpotListModel *, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    
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

- (Promise *)deleteSpotList:(NSDictionary *)params success:(void (^)(SpotListModel *, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    
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

#pragma mark - Caching

+ (SpotListCache *)sh_sharedCache {
    static SpotListCache *_sh_Cache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sh_Cache = [[SpotListCache alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_sh_Cache removeAllObjects];
        }];
    });
    
    return _sh_Cache;
}

#pragma mark - Revised Code for 2.0

+ (void)refreshSpotlistCache {
    [[self sh_sharedCache] cacheSpotlists:nil];
    if ([UserModel isLoggedIn]) {
        [[self fetchMySpotLists] then:^(NSArray *spotlists) {
            DebugLog(@"Refreshed spotlist cache");
        } fail:nil always:nil];
    }
}

+ (void)fetchMySpotLists:(void (^)(NSArray *spotlists))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    NSArray *spotlists = [[SpotListModel sh_sharedCache] cachedSpotlists];
    if (spotlists.count && successBlock) {
        successBlock(spotlists);
        return;
    }
    
    UserModel *user = [UserModel currentUser];
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/users/%ld/spot_lists", (long)[user.ID integerValue]] parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            NSArray *spotlists = [jsonApi resourcesForKey:@"spot_lists"];
            NSMutableArray *filteredSpotlists = @[].mutableCopy;
            for (SpotListModel *spotlist in spotlists) {
                // delete spotlists with default names (temporary measure)
                if ([kSpotListModelDefaultName isEqualToString:spotlist.name]) {
                    [[spotlist purgeSpotList] then:^(id value) {
                        DebugLog(@"Deleted spotlist %@", spotlist.ID);
                    } fail:nil always:nil];
                }
                else {
                    [filteredSpotlists addObject:spotlist];
                }
            }
            
            // Note: The last modified appears to be last, so reversing the order would be better
            // At this time the updated_at value for a spotlist is not provided.
            NSArray *reversedArray = [[filteredSpotlists reverseObjectEnumerator] allObjects];
            
            if (reversedArray.count) {
                [[SpotListModel sh_sharedCache] cacheSpotlists:reversedArray];
            }
            
            if (successBlock) {
                successBlock(reversedArray);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

+ (Promise *)fetchMySpotLists {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self fetchMySpotLists:^(NSArray *spotlists) {
        [deferred resolveWith:spotlists];
    } failure:^(ErrorModel *errorModel) {
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

+ (NSDictionary *)prepareSearchParametersWithRequest:(SpotListRequest *)request {
    
    NSMutableArray *jsonSliders = @[].mutableCopy;
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
                                    kSpotListModelParamBasedOnSlider : [NSNumber numberWithBool:request.isBasedOnSliders],
                                    @"sliders" : jsonSliders,
                                    @"spot_id" : request.spotId ? request.spotId : [NSNull null],
                                    @"spot_type_id" : request.spotTypeId ? request.spotTypeId : [NSNull null],
                                    }.mutableCopy;

    if (CLLocationCoordinate2DIsValid(request.coordinate)) {
        params[kSpotListModelParamLatitude] = [NSNumber numberWithFloat:request.coordinate.latitude];
        params[kSpotListModelParamLongitude] = [NSNumber numberWithFloat:request.coordinate.longitude];
    }
    
    if (request.radius) {
        CGFloat miles = request.radius / kMetersPerMile;
        NSNumber *radiusParam = [NSNumber numberWithFloat:MAX(MIN(kMaxRadiusFloat, miles), kMinRadiusFloat)];
        params[kSpotListModelParamRadius] = radiusParam;
    }
    
    return params;
}

+ (void)createSpotListWithRequest:(SpotListRequest *)request success:(void (^)(SpotListModel *spotListModel))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    NSDictionary *params = [self prepareSearchParametersWithRequest:request];
    
    [[ClientSessionManager sharedClient] POST:@"/api/spot_lists" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            SpotListModel *model = [jsonApi resourceForKey:@"spot_lists"];
            
            // limit to 10
            if (model.spots.count > 10) {
                model.spots = [model.spots subarrayWithRange:NSMakeRange(0, 10)];
            }
            
            [SpotListModel refreshSpotlistCache];
            
            successBlock(model);
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
        }
    }];
}

+ (void)updateSpotListWithRequest:(SpotListRequest *)request success:(void (^)(SpotListModel *spotListModel))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    NSDictionary *params = [self prepareSearchParametersWithRequest:request];
    
    [[ClientSessionManager sharedClient] PUT:[NSString stringWithFormat:@"/api/spot_lists/%ld", (long)[request.spotListId integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            SpotListModel *model = [jsonApi resourceForKey:@"spot_lists"];
            
            // limit to 10
            if (model.spots.count > 10) {
                model.spots = [model.spots subarrayWithRange:NSMakeRange(0, 10)];
            }
            
            [SpotListModel refreshSpotlistCache];
            
            successBlock(model);
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
        }
    }];
}

+ (void)fetchFeaturedSpotListWithRequest:(SpotListRequest *)request success:(void (^)(SpotListModel *spotListModel))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    NSDictionary *params = [self prepareSearchParametersWithRequest:request];
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/spot_lists/%ld", (long)[request.spotListId integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            SpotListModel *spotlist = [jsonApi resourceForKey:@"spot_lists"];
            if (successBlock) {
                successBlock(spotlist);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            if (errorModel) {
                failureBlock(errorModel);
            }
        }
    }];
}

+ (void)fetchSpotListWithRequest:(SpotListRequest *)request success:(void (^)(SpotListModel *spotListModel))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    // if request has a spotlist id then it is an updated (PUT) otherwise it is a create (POST) action and both should return a result set with an identical structure
    if (!request.spotListId) {
        [self createSpotListWithRequest:request success:successBlock failure:failureBlock];
    }
    else if (request.spotListId && request.isFeatured) {
        [self fetchFeaturedSpotListWithRequest:request success:successBlock failure:failureBlock];
    }
    else {
        [self updateSpotListWithRequest:request success:successBlock failure:failureBlock];
    }
}

+ (Promise *)fetchSpotListWithRequest:(SpotListRequest *)request {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self fetchSpotListWithRequest:request success:^(SpotListModel *spotListModel) {
        // Resolves promise
        [deferred resolveWith:spotListModel];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

- (void)fetchSpotList:(void (^)(SpotListModel *spotlist))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/spot_lists/%ld", (long)[self.ID integerValue]] parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            SpotListModel *model = [jsonApi resourceForKey:@"spot_lists"];
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

- (Promise *)fetchSpotList {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self fetchSpotList:^(SpotListModel *spotlist) {
        // Resolves promise
        [deferred resolveWith:spotlist];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

- (void)purgeSpotList:(void (^)(BOOL success))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    [[ClientSessionManager sharedClient] DELETE:[NSString stringWithFormat:@"/api/spot_lists/%ld", (long)[self.ID integerValue]] parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200 || operation.response.statusCode == 204) {
            // update the cache
            NSMutableArray *cachedSpotlists = [[SpotListModel sh_sharedCache] cachedSpotlists].mutableCopy;
            [cachedSpotlists removeObject:self];
            [[SpotListModel sh_sharedCache] cacheSpotlists:cachedSpotlists];
            
            successBlock(TRUE);
        }
        else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
        }
    }];
}

- (Promise *)purgeSpotList {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];

    [self purgeSpotList:^(BOOL success) {
        // Resolves promise
        [deferred resolveWith:[NSNumber numberWithBool:success]];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

@end

@implementation SpotListCache

NSString * const SpotlistsKey = @"Spotlists";

- (NSArray *)cachedSpotlists {
    return [self objectForKey:SpotlistsKey];
}

- (void)cacheSpotlists:(NSArray *)spotlists {
    if (spotlists.count) {
        [self setObject:spotlists forKey:SpotlistsKey];
        
        // automatically expire the cache after 90 seconds to ensure it does not get stale
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(expireSpotlistsCache) object:nil];
        [self performSelector:@selector(expireSpotlistsCache) withObject:self afterDelay:90];
    }
    else {
        [self removeObjectForKey:SpotlistsKey];
    }
}

- (void)expireSpotlistsCache {
    [self cacheSpotlists:nil];
}

@end
