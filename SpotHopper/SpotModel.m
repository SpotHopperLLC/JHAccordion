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
#import "LiveSpecialModel.h"
#import "SliderTemplateModel.h"
#import "MenuItemModel.h"
#import "MenuTypeModel.h"
#import "MenuModel.h"
#import "SpotTypeModel.h"

#define kPageSize @25

@interface SpotModelCache : NSCache

+ (NSString *)menuKeyForSpot:(SpotModel *)spot;

- (MenuModel *)cachedMenuForKey:(NSString *)key;
- (void)cacheMenu:(MenuModel *)menu forKey:(NSString *)key;

- (NSArray *)cachedSpotTypes;
- (void)cacheSpotTypes:(NSArray *)spotTypes;

@end

@implementation SpotModel

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'name' to 'name' property
    // Maps values in JSON key 'image_url' to 'imageUrl' property
    // Maps values in JSON key 'address' to 'address' property
    // Maps values in JSON key 'city' to 'city' property
    // Maps values in JSON key 'state' to 'state' property
    // Maps values in JSON key 'zip' to 'zip' property
    // Maps values in JSON key 'phone_number' to 'phoneNumber' property
    // Maps values in JSON key 'hours_of_operation' to 'hoursOfOperation' property
    // Maps values in JSON key 'latitude' to 'latitude' property
    // Maps values in JSON key 'longitude' to 'longitude' property
    // Maps values in JSON key 'foursquare_id' to 'foursquareId' property
    // Maps values in JSON key 'match' to 'match' property
    // Maps values in JSON key 'relevance' to 'relevance' property
    // Maps values in JSON key 'daily_specials' to 'dailySpecials' property
    // Maps linked resource in JSON key 'slider_templates' to 'sliderTemplates' property
    // Maps linked resource in JSON key 'spot_type' to 'spotType' property
    // Maps linked resource in JSON key 'images' to 'images' property
    // Maps linked resource in JSON key 'live_specials' to 'liveSpecials' property
    // Maps linked resource in JSON key 'average_review' to 'averageReview' property
    return @{
             @"name" : @"name",
             @"image_url" : @"imageUrl",
             @"address" : @"address",
             @"city" : @"city",
             @"state" : @"state",
             @"zip" : @"zip",
             @"phone_number" : @"phoneNumber",
             @"hours_of_operation" : @"hoursOfOperation",
             @"latitude" : @"latitude",
             @"longitude" : @"longitude",
             @"foursquare_id" : @"foursquareId",
             @"match" : @"match",
             @"relevance" : @"relevance",
             @"daily_specials" : @"dailySpecials",
             
             @"links.slider_templates" : @"sliderTemplates",
             @"links.spot_type" : @"spotType",
             @"links.images" : @"images",
             @"links.live_specials" : @"liveSpecials",
             @"links.average_review" : @"averageReview",
             };
}

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ [%@]", self.ID, self.name, NSStringFromClass([self class])];
}

#pragma mark - API

+ (void)cancelGetSpots {
    [[ClientSessionManager sharedClient] cancelAllHTTPOperationsWithMethod:@"GET" path:@"/api/spots" parameters:nil ignoreParams:YES];
}

+ (Promise*)getSpots:(NSDictionary*)params success:(void(^)(NSArray *spotModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:@"/api/spots" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil, nil);
            }
        }
        else if (operation.response.statusCode == 200) {
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

+ (Promise*)getSpotsWithSpecialsTodayForCoordinate:(CLLocationCoordinate2D)coordinate success:(void(^)(NSArray *spotModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    
    // Day of week
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSDayCalendarUnit|NSTimeZoneCalendarUnit fromDate:[NSDate date]];
    
    // Get open and close time
    NSInteger dayOfWeek = [comps weekday] - 1;
    
    /*
     * Searches spots for specials
     */
    NSDictionary *params = @{
                             kSpotModelParamPage : @1,
                             kSpotModelParamQueryVisibleToUsers : @"true",
                             kSpotModelParamsPageSize : @10,
                             kSpotModelParamSources : kSpotModelParamSourcesSpotHopper,
                             kSpotModelParamQueryDayOfWeek : [NSNumber numberWithInteger:dayOfWeek],
                             kSpotModelParamQueryLatitude : [NSNumber numberWithFloat:coordinate.latitude],
                             kSpotModelParamQueryLongitude : [NSNumber numberWithFloat:coordinate.longitude]
                             };
    
    return [SpotModel getSpotsWithSpecials:params success:successBlock failure:failureBlock];
}

+ (Promise*)getSpotsWithSpecials:(NSDictionary*)params success:(void(^)(NSArray *spotModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:@"/api/spots/specials" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil, nil);
            }
        }
        else if (operation.response.statusCode == 200) {
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
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil, nil);
            }
        }
        else if (operation.response.statusCode == 200) {
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

- (Promise *)getSpot:(NSDictionary *)params success:(void (^)(SpotModel *spotModel, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/spots/%ld", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil, nil);
            }
        }
        else if (operation.response.statusCode == 200) {
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

- (Promise *)getMenuItems:(NSDictionary *)params success:(void (^)(NSArray *menuItems, JSONAPI *jsonApi))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/spots/%ld/menu_items", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil, nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"menu_items"];
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

#pragma mark - Revised Code for 2.0

+ (void)fetchSpotsNearLocation:(CLLocation *)location success:(void (^)(NSArray *spots))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    NSMutableDictionary *params = @{
                                         kSpotModelParamQuery : @"",
                                         kSpotModelParamQueryVisibleToUsers : @"true",
                                         kSpotModelParamPage : @1,
                                         kSpotModelParamsPageSize : @10,
                                         kSpotModelParamSources : kSpotModelParamSourcesSpotHopper
                                         }.mutableCopy;
    
    if (location != nil && CLLocationCoordinate2DIsValid(location.coordinate)) {
        [params setObject:[NSNumber numberWithFloat:location.coordinate.latitude] forKey:kSpotModelParamQueryLatitude];
        [params setObject:[NSNumber numberWithFloat:location.coordinate.longitude] forKey:kSpotModelParamQueryLongitude];
    }
    
    [[ClientSessionManager sharedClient] GET:@"/api/spots" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"spots"];
            if (successBlock) {
                successBlock(models);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

+ (Promise *)fetchSpotsNearLocation:(CLLocation *)location {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self fetchSpotsNearLocation:location success:^(NSArray *spots) {
        // Resolves promise
        [deferred resolveWith:spots];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

- (void)fetchSpot:(void (^)(SpotModel *spotModel))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/spots/%ld", (long)[self.ID integerValue]] parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            SpotModel *model = [jsonApi resourceForKey:@"spots"];
            
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

- (Promise *)fetchSpot {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];

    [self fetchSpot:^(SpotModel *spotModel) {
        // Resolves promise
        [deferred resolveWith:spotModel];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

+ (void)fetchSpotTypes:(void (^)(NSArray *spotTypes))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    // TODO: add caching
    
    [SpotModel getSpots:@{kSpotModelParamsPageSize:@0} success:^(NSArray *spotModels, JSONAPI *jsonApi) {
        NSDictionary *forms = [jsonApi objectForKey:@"form"];
        if (forms != nil) {
            // Get spot types only user can see
            NSMutableArray *userSpotTypes = [@[] mutableCopy];
            
            NSArray *allSpotTypes = [forms objectForKey:@"spot_types"];
            
            // Add an Any item
            NSDictionary *anyDictionary = @{@"id" : [NSNull null], @"name" : @"Any"};
            SpotTypeModel *anySpotType = [SHJSONAPIResource jsonAPIResource:anyDictionary withLinked:jsonApi.linked withClass:[SpotTypeModel class]];
            [userSpotTypes addObject:anySpotType];
            
            for (NSDictionary *spotTypeDictionary in allSpotTypes) {
                if ([[spotTypeDictionary objectForKey:@"visible_to_users"] boolValue] == YES) {
                    SpotTypeModel *spotType = [SHJSONAPIResource jsonAPIResource:spotTypeDictionary withLinked:jsonApi.linked withClass:[SpotTypeModel class]];
                    [userSpotTypes addObject:spotType];
                }
            }
            
            // TODO: cache value
            
            if (successBlock) {
                successBlock(userSpotTypes);
            }
        }
    } failure:^(ErrorModel *errorModel) {
        if (failureBlock) {
            failureBlock(errorModel);
        }
    }];
}

+ (Promise *)fetchSpotTypes {
    Deferred *deferred = [Deferred deferred];
    
    [SpotModel fetchSpotTypes:^(NSArray *spotTypes) {
        [deferred resolveWith:spotTypes];
    } failure:^(ErrorModel *errorModel) {
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

- (void)fetchMenu:(void (^)(MenuModel *menu))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    NSString *cacheKey = [SpotModelCache menuKeyForSpot:self];
    MenuModel *menu = [[SpotModel sh_sharedCache] cachedMenuForKey:cacheKey];
    if (menu && successBlock) {
        successBlock(menu);
    }
    else {
        NSDictionary *params = @{ kMenuItemParamsInStock : @"true" };
        
        [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/spots/%ld/menu_items", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // Parses response with JSONAPI
            JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
            
            if (operation.isCancelled || operation.response.statusCode == 204) {
                if (successBlock) {
                    successBlock(nil);
                }
            }
            else if (operation.response.statusCode == 200) {
                MenuModel *menu = [[MenuModel alloc] init];
                menu.items = [jsonApi resourcesForKey:@"menu_items"];
                menu.types = [[jsonApi linked] objectForKey:@"menu_types"];
                
                [[SpotModel sh_sharedCache] cacheMenu:menu forKey:cacheKey];
                
                if (successBlock) {
                    successBlock(menu);
                }
            }
            else {
                ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
                if (failureBlock) {
                    failureBlock(errorModel);
                }
            }
        }];
    }
}

- (Promise *)fetchMenu {
    Deferred *deferred = [Deferred deferred];
    
    [self fetchMenu:^(MenuModel *menu) {
        [deferred resolveWith:menu];
    } failure:^(ErrorModel *errorModel) {
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

#pragma mark - Caching

+ (SpotModelCache *)sh_sharedCache {
    static SpotModelCache *_sh_Cache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sh_Cache = [[SpotModelCache alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_sh_Cache removeAllObjects];
        }];
    });
    
    return _sh_Cache;
}

#pragma mark - Getters

- (NSString *)addressCityState {
    NSMutableArray *parts = [NSMutableArray array];
    if ([self address].length > 0 && [self cityState].length > 0) {
        [parts addObject:[NSString stringWithFormat:@"%@, %@", [self address], [self cityState]]];
    } else if ([self address].length > 0) {
        [parts addObject:[self address]];
    } else if ([self cityState].length > 0) {
        [parts addObject:[self cityState]];
    }
    
    return [parts componentsJoinedByString:@", "];
}

- (NSString *)fullAddress {
    NSMutableArray *parts = [NSMutableArray array];
    if ([self address].length > 0 && [self cityState].length > 0) {
        [parts addObject:[NSString stringWithFormat:@"%@, %@", [self address], [self cityState]]];
    } else if ([self address].length > 0) {
        [parts addObject:[self address]];
    } else if ([self cityState].length > 0) {
        [parts addObject:[self cityState]];
    }
    
    if ([self zip].length > 0) {
        [parts addObject:[self zip]];
    }
    
    return [parts componentsJoinedByString:@", "];
}

- (NSString *)cityState {
    if ([self city].length > 0 && [self state].length > 0) {
        return [NSString stringWithFormat:@"%@, %@", [self city], [self state]];
    } else if ([self city].length > 0) {
        return [self city];
    } else if ([self state].length > 0) {
        return [self state];
    }
    
    return nil;
}

- (NSString *)matchPercent {
    if ([self match] == nil) {
        return nil;
    }
    return [NSString stringWithFormat:@"%d%%", (int)([self match].floatValue * 100)];
}

- (NSArray *)sliderTemplates {
    return [_sliderTemplates sortedArrayUsingComparator:^NSComparisonResult(SliderTemplateModel *obj1, SliderTemplateModel *obj2) {
        return [obj1.order compare:obj2.order];
    }];
}

- (NSNumber *)relevance {
    return _relevance ?: @0;
}

- (LiveSpecialModel*)currentLiveSpecial {
    LiveSpecialModel *currentLiveSpecial = nil;
    
    NSDate *now = [NSDate date];
    for (LiveSpecialModel *liveSpecial in [self liveSpecials]) {
        
        NSLog(@"LS Start date - %@", [liveSpecial startDate]);
        NSLog(@"LS End date - %@", [liveSpecial endDate]);
        
        // Checks if currents special start BEFORE now and ends AFTER now
        if ( [liveSpecial.startDate timeIntervalSinceDate:now] < 0
            && [liveSpecial.endDate timeIntervalSinceDate:now] > 0) {
            currentLiveSpecial = liveSpecial;
            break;
        }
    }
    
    return currentLiveSpecial;
}

- (UIImage *)placeholderImage {
    return [UIImage imageNamed:@"spot_placeholder"];
}

@end

@implementation SpotModelCache

NSString * const SpotTypesKey = @"SpotTypesKey";

+ (NSString *)menuKeyForSpot:(SpotModel *)spot {
    return [NSString stringWithFormat:@"key-menu-%@", spot.ID];
}

- (MenuModel *)cachedMenuForKey:(NSString *)key {
    return [self objectForKey:key];
}

- (void)cacheMenu:(MenuModel *)menu forKey:(NSString *)key {
    if (menu) {
        [self setObject:menu forKey:key];
    }
    else {
        [self removeObjectForKey:key];
    }
}

- (NSArray *)cachedSpotTypes {
    return [self objectForKey:SpotTypesKey];
}

- (void)cacheSpotTypes:(NSArray *)spotTypes {
    if (spotTypes.count) {
        [self setObject:spotTypes forKey:SpotTypesKey];
    }
    else {
        [self removeObjectForKey:SpotTypesKey];
    }
}

@end
