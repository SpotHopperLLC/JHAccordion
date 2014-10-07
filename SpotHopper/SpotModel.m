//
//  SpotModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SpotModel.h"

#import "SHAppConfiguration.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"
#import "LiveSpecialModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"
#import "AverageReviewModel.h"
#import "MenuItemModel.h"
#import "MenuTypeModel.h"
#import "MenuModel.h"
#import "DrinkTypeModel.h"
#import "SpotTypeModel.h"
#import "SpecialModel.h"
#import "LikeModel.h"
#import "UserModel.h"
#import "SpotListModel.h"
#import "ImageModel.h"

#import "Tracker.h"

#define kPageSize @25
#define kMetersPerMile 1609.344

@interface SpotModelCache : NSCache

+ (NSString *)menuKeyForSpot:(SpotModel *)spot;

- (MenuModel *)cachedMenuForKey:(NSString *)key;
- (void)cacheMenu:(MenuModel *)menu forKey:(NSString *)key;

- (NSArray *)cachedSpotTypes;
- (void)cacheSpotTypes:(NSArray *)spotTypes;

- (SpotModel *)cachedSpotForKey:(NSString *)key;
- (void)cacheSpot:(SpotModel *)spot withKey:(NSString *)key;

@end

@implementation SpotModel

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'name' to 'name' property
    // Maps values in JSON key 'description' to 'descriptionOfSpot' property
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
    // Maps linked resource in JSON key 'specials' to 'specials' property
    return @{
             @"name" : @"name",
             @"description" : @"descriptionOfSpot",
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
             @"links.highlight_images" : @"highlightImages",
             @"links.live_specials" : @"liveSpecials",
             @"links.average_review" : @"averageReview",
             @"links.specials" : @"specials"
             };
}

#pragma mark - Read-only properties
#pragma mark -

- (ImageModel *)highlightImage {
    if (self.highlightImages.count) {
        return self.highlightImages[0];
    }
    else if (self.images.count) {
        return self.images[0];
    }
    
    return nil;
}

- (NSString *)formattedPhoneNumber {
    return [self formatPhoneNumber:self.phoneNumber];
}

- (NSString *)hoursForToday {
    NSString *closeTime = nil;
    NSArray *hoursForToday = [self.hoursOfOperation datesForToday];
    
    if (hoursForToday) {
        // Creates formatter
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        
        // Gets open and close dates
        NSDate *dateOpen = hoursForToday.firstObject;
        NSDate *dateClose = hoursForToday.lastObject;
        
        NSAssert(dateOpen, @"Date must be defined");
        NSAssert(dateClose, @"Date must be defined");
        
        // Sets the stuff
        NSDate *now = [NSDate date];
        if ([now timeIntervalSinceDate:dateOpen] > 0 && [now timeIntervalSinceDate:dateClose] < 0) {
            closeTime = [NSString stringWithFormat:@"Open until %@", [dateFormatter stringFromDate:dateClose]];
        } else {
            closeTime = [NSString stringWithFormat:@"Opens at %@", [dateFormatter stringFromDate:dateOpen]];
        }
    }
    
    return closeTime;
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude.floatValue, self.longitude.floatValue);
}

- (NSString *)closeTimeForToday {
    
    // Sets "Opens at <some time>" or "Open until <some time>"
    NSString *closeTime = nil;
    NSArray *hoursForToday = [self.hoursOfOperation datesForToday];
    
    if (hoursForToday) {
        // Creates formatter
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        
        // Gets open and close dates
        NSDate *dateOpen = hoursForToday.firstObject;
        NSDate *dateClose = hoursForToday.lastObject;
        
        NSAssert(dateOpen, @"Date must be defined");
        NSAssert(dateClose, @"Date must be defined");
        
        // Sets the stuff
        NSDate *now = [NSDate date];
        if ([now timeIntervalSinceDate:dateOpen] > 0 && [now timeIntervalSinceDate:dateClose] < 0) {
            closeTime = [NSString stringWithFormat:@"Open until %@", [dateFormatter stringFromDate:dateClose]];
        } else {
            closeTime = [NSString stringWithFormat:@"Opens at %@", [dateFormatter stringFromDate:dateOpen]];
        }
    }
    
    return closeTime;
}

- (DrinkTypeModel *)preferredDrinkType {
    // look at each slider to get the slider value for each emphasis and compare them
    CGFloat beerEmphasis = 0.0;
    CGFloat wineEmphasis = 0.0;
    CGFloat cocktailEmphasis = 0.0;
    
    for (SliderModel *slider in self.averageReview.sliders) {
        if ([slider.sliderTemplate.ID isEqual:kBeerEmphasisSliderID]) {
            beerEmphasis = slider.value.floatValue;
        }
        else if ([slider.sliderTemplate.ID isEqual:kWineEmphasisSliderID]) {
            wineEmphasis = slider.value.floatValue;
        }
        else if ([slider.sliderTemplate.ID isEqual:kCocktailEmphasisSliderID]) {
            cocktailEmphasis = slider.value.floatValue;
        }
        if (beerEmphasis && wineEmphasis && cocktailEmphasis) {
            break;
        }
    }
    
    if (cocktailEmphasis > wineEmphasis && cocktailEmphasis > beerEmphasis) {
        return [DrinkTypeModel cocktailDrinkType];
    }
    else if (wineEmphasis > beerEmphasis) {
        return [DrinkTypeModel wineDrinkType];
    }
    else {
        return [DrinkTypeModel beerDrinkType];
    }
}

- (CLLocation *)location {
    if (CLLocationCoordinate2DIsValid(self.coordinate)) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
        return location;
    }
    else {
        return nil;
    }
}

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ [%@]", self.ID, self.name, NSStringFromClass([self class])];
}

- (id)debugQuickLookObject {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.latitude.floatValue longitude:self.longitude.floatValue];
    return location;
}

#pragma mark - API

+ (void)cancelGetSpots {
    [[ClientSessionManager sharedClient] cancelAllHTTPOperationsWithMethod:@"GET" path:@"/api/spots" parameters:nil ignoreParams:YES];
}

+ (Promise *)getSpots:(NSDictionary*)params success:(void(^)(NSArray *spotModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:@"/api/spots" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
            NSArray *models = [jsonApi resourcesForKey:@"spots"];
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

+ (Promise *)getSpotsWithSpecialsTodayForCoordinate:(CLLocationCoordinate2D)coordinate success:(void(^)(NSArray *spotModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    
    // Day of week
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSDayCalendarUnit|NSTimeZoneCalendarUnit fromDate:[NSDate date]];
    
    // Get open and close time
    NSInteger dayOfWeek = [comps weekday] - 1;
    
    // TODO: add radius
    CGFloat miles = 1.0f;
    
    /*
     * Searches spots for specials
     */
    NSDictionary *params = @{
                             kSpotModelParamPage : @1,
                             kSpotModelParamQueryVisibleToUsers : @"true",
                             kSpotModelParamsPageSize : @20,
                             kSpotModelParamSources : kSpotModelParamSourcesSpotHopper,
                             kSpotModelParamQueryDayOfWeek : [NSNumber numberWithInteger:dayOfWeek],
                             kSpotModelParamQueryLatitude : [NSNumber numberWithFloat:coordinate.latitude],
                             kSpotModelParamQueryLongitude : [NSNumber numberWithFloat:coordinate.longitude],
                             kSpotModelParamQueryRadius : [NSNumber numberWithFloat:miles]
                             };
    
    return [SpotModel getSpotsWithSpecials:params success:successBlock failure:failureBlock];
}

+ (Promise *)getSpotsWithSpecials:(NSDictionary*)params success:(void(^)(NSArray *spotModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:@"/api/spots/specials" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
            NSArray *spots = [jsonApi resourcesForKey:@"spots"];
            
            if (successBlock) {
                successBlock(spots, jsonApi);
            }
            
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

+ (Promise *)postSpot:(NSDictionary*)params success:(void(^)(SpotModel *spotModel, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] POST:@"/api/spots" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
            
            // Resolves promise
            [deferred resolve];
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
            
            // Resolves promise
            [deferred resolve];
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

+ (void)fetchSpecialsSpotlistForCoordinate:(CLLocationCoordinate2D)coordinate radius:(CLLocationDistance)radius success:(void(^)(SpotListModel *spotlist))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    
    // adjust time back 4 hours to help handle the midnight boundary
    NSTimeInterval fourHoursAgo = 60 * 60 * 4 * -1;
    NSDate *offsetTime = [[NSDate date] dateByAddingTimeInterval:fourHoursAgo];
    
    // Day of week
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit units = NSHourCalendarUnit|NSMinuteCalendarUnit|NSWeekdayCalendarUnit;
    NSDateComponents *components = [calendar components:units fromDate:offsetTime];
    
    // Get open and close time
    NSInteger weekday = components.weekday - 1;

    components = [calendar components:units fromDate:[NSDate date]];
    NSString *cutOffTime = [NSString stringWithFormat:@"%02li:%02li", (long)components.hour, (long)components.minute];
    
    CGFloat radiusInMiles = radius / kMetersPerMile;
    
    /*
     * Searches spots for specials
     */
    NSDictionary *params = @{
                             kSpotModelParamPage : @1,
                             kSpotModelParamQueryVisibleToUsers : @"true",
                             kSpotModelParamsPageSize : @20,
                             kSpotModelParamSources : kSpotModelParamSourcesSpotHopper,
                             kSpotModelParamQueryDayOfWeek : [NSNumber numberWithInteger:weekday],
                             kSpotModelParamQueryLatitude : [NSNumber numberWithFloat:coordinate.latitude],
                             kSpotModelParamQueryLongitude : [NSNumber numberWithFloat:coordinate.longitude],
                             kSpotModelParamQueryRadius : [NSNumber numberWithFloat:radiusInMiles],
                             @"cut_off_time" : cutOffTime
                             };
    
    [[ClientSessionManager sharedClient] GET:@"/api/spots/specials" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            NSArray *spots = [jsonApi resourcesForKey:@"spots"];
            
            void (^finish)(NSArray *) = ^void (NSArray *likes) {
                for (SpotModel *spot in spots) {
                    SpecialModel *special = spot.specialForToday;
                    
                    [[LikeModel likeForSpecial:special] then:^(LikeModel *like) {
                        special.userLikesSpecial = like != nil;
                    } fail:nil always:nil];
                }
                
                // sort by likes count
                NSArray *sortedSpots = [spots sortedArrayUsingComparator:^NSComparisonResult(SpotModel *spot1, SpotModel *spot2) {
                    SpecialModel *special1 = spot1.specialForToday;
                    SpecialModel *special2 = spot2.specialForToday;
                    
                    NSNumber *count1 = [NSNumber numberWithInteger:special1.likeCount];
                    NSNumber *count2 = [NSNumber numberWithInteger:special2.likeCount];
                    
                    return [count2 compare:count1];
                }];
                
                // extract values from meta
                CGFloat latitude = [jsonApi.meta[@"lat"] floatValue];
                CGFloat longitude = [jsonApi.meta[@"lng"] floatValue];
                CGFloat radius = [jsonApi.meta[@"radius"] floatValue];
                
                SpotListModel *spotlist = [[SpotListModel alloc] init];
                spotlist.name = @"Specials";
                spotlist.spots = sortedSpots;
                spotlist.latitude = [NSNumber numberWithFloat:latitude];
                spotlist.longitude = [NSNumber numberWithFloat:longitude];
                spotlist.radius = [NSNumber numberWithFloat:radius];
                
                if (successBlock) {
                    successBlock(spotlist);
                }
            };

            [[LikeModel fetchLikesForUser:[UserModel currentUser]] then:^(NSArray *likes) {
                finish(likes);
            } fail:^(id error) {
                finish(nil);
            } always:nil];
        }
        else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
        }
    }];
}

+ (Promise *)fetchSpecialsSpotlistForCoordinate:(CLLocationCoordinate2D)coordinate radius:(CLLocationDistance)radius {
    Deferred *deferred = [Deferred deferred];
    
    [self fetchSpecialsSpotlistForCoordinate:coordinate radius:radius success:^(SpotListModel *spotlist) {
        // Resolves promise
        [deferred resolveWith:spotlist];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

+ (void)fetchSpotsNearLocation:(CLLocation *)location success:(void (^)(NSArray *spots))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    CLLocationDistance radius = 2.0 * kMetersPerMile;
    [self fetchSpotsNearLocation:location radius:radius success:successBlock failure:failureBlock];
}

+ (void)fetchSpotsNearLocation:(CLLocation *)location radius:(CLLocationDistance)radius success:(void (^)(NSArray *spots))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    NSMutableDictionary *params = @{
                                         kSpotModelParamQuery : @"",
                                         kSpotModelParamQueryVisibleToUsers : @"true",
                                         kSpotModelParamPage : @1,
                                         kSpotModelParamsPageSize : @10,
                                         kSpotModelParamSources : kSpotModelParamSourcesSpotHopper
                                         }.mutableCopy;
    
    if (location && CLLocationCoordinate2DIsValid(location.coordinate)) {
        [params setObject:[NSNumber numberWithFloat:location.coordinate.latitude] forKey:kSpotModelParamQueryLatitude];
        [params setObject:[NSNumber numberWithFloat:location.coordinate.longitude] forKey:kSpotModelParamQueryLongitude];
    }
    
    if (radius) {
        params[kSpotModelParamQueryRadius] = [NSNumber numberWithFloat:radius];
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
            NSArray *spots = [jsonApi resourcesForKey:@"spots"];
            
            NSArray *sortedSpots = [self sortSpots:spots forLocation:location];
            
            if (successBlock) {
                successBlock(sortedSpots);
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
    CLLocationDistance radius = 2.0 * kMetersPerMile;
    return [self fetchSpotsNearLocation:location radius:radius];
}

+ (Promise *)fetchSpotsNearLocation:(CLLocation *)location radius:(CLLocationDistance)radius {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self fetchSpotsNearLocation:location radius:radius success:^(NSArray *spots) {
        // Resolves promise
        [deferred resolveWith:spots];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

+ (void)fetchSpotsWithText:(NSString *)text page:(NSNumber *)page success:(void(^)(NSArray *spots))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    NSMutableDictionary *params = @{
                                    kSpotModelParamQuery : text,
                                    kSpotModelParamQueryVisibleToUsers : @"true",
                                    kSpotModelParamPage : page,
                                    kSpotModelParamsPageSize : @5,
                                    kSpotModelParamSources : kSpotModelParamSourcesSpotHopper
                                    }.mutableCopy;
    
    NSDate *startDate = [NSDate date];
    
    [[ClientSessionManager sharedClient] GET:@"/api/spots" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startDate];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            NSArray *spots = [jsonApi resourcesForKey:@"spots"];
            
            // only track a successful search
            [Tracker track:@"Spot Search Duration" properties:@{ @"Duration" : [NSNumber numberWithFloat:duration] }];
            
            if (successBlock) {
                successBlock(spots);
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

+ (Promise *)fetchSpotsWithText:(NSString *)text page:(NSNumber *)page {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self fetchSpotsWithText:text page:page success:^(NSArray *spots) {
        // Resolves promise
        [deferred resolveWith:spots];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

- (void)fetchSpot:(void (^)(SpotModel *spotModel))successBlock failure:(void (^)(ErrorModel *errorModel))failureBlock {
    NSString *key = [NSString stringWithFormat:@"Spot-%@", self.ID];
    SpotModel *cachedSpot = [[SpotModel sh_sharedCache] cachedSpotForKey:key];
    if (cachedSpot && successBlock) {
        successBlock(cachedSpot);
        return;
    }
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/spots/%ld", (long)[self.ID integerValue]] parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            SpotModel *spotModel = [jsonApi resourceForKey:@"spots"];
            
            [[SpotModel sh_sharedCache] cacheSpot:spotModel withKey:key];
            
            if (successBlock) {
                successBlock(spotModel);
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
    NSArray *cachedSpotTypes = [[SpotModel sh_sharedCache] cachedSpotTypes];
    if (cachedSpotTypes.count && successBlock) {
        successBlock(cachedSpotTypes);
        return;
    }
    
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
            
            [[SpotModel sh_sharedCache] cacheSpotTypes:userSpotTypes];
            
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
    if (self.menu && successBlock) {
        successBlock(self.menu);
        return;
    }

    // a cached copy of the menu may no be set on this instance of a spot while it is still cached
    NSString *cacheKey = [SpotModelCache menuKeyForSpot:self];
    MenuModel *menu = [[SpotModel sh_sharedCache] cachedMenuForKey:cacheKey];
    if (menu && successBlock) {
        self.menu = menu;
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
                menu.spot = self;
                menu.items = [jsonApi resourcesForKey:@"menu_items"];
                menu.types = [[jsonApi linked] objectForKey:@"menu_types"];
                
                [[SpotModel sh_sharedCache] cacheMenu:menu forKey:cacheKey];
                
                self.menu = menu;
                
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

#pragma mark - Sorting
#pragma mark -

+ (NSArray *)sortSpots:(NSArray *)spots forLocation:(CLLocation *)location {
    NSArray *sortedSpots = [spots sortedArrayUsingComparator:^NSComparisonResult(SpotModel *spot1, SpotModel *spot2) {
        CLLocationDistance distance1 = [location distanceFromLocation:spot1.location];
        CLLocationDistance distance2 = [location distanceFromLocation:spot2.location];
        
        NSComparisonResult result = NSOrderedSame;
        
        if (distance1 < distance2) {
            result = (NSComparisonResult)NSOrderedAscending;
        }
        else {
            result = (NSComparisonResult)NSOrderedDescending;
        }
        
        return result;
    }];

    return sortedSpots;
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
    if (self.match) {
        return [NSString stringWithFormat:@"%d%%", (int)(self.match.floatValue * 100)];
    }
    
    return nil;
}

- (NSArray *)sliderTemplates {
    return [_sliderTemplates sortedArrayUsingComparator:^NSComparisonResult(SliderTemplateModel *obj1, SliderTemplateModel *obj2) {
        return [obj1.order compare:obj2.order];
    }];
}

- (NSNumber *)relevance {
    return _relevance ?: @0;
}

- (SpecialModel *)specialForToday {
    // offset time by 4 hours so that 2am on Wednesday still looks at Tuesday
    NSTimeInterval fourHoursAgo = 60 * 60 * 4 * -1;
    NSDate *offsetTime = [[NSDate date] dateByAddingTimeInterval:fourHoursAgo];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSWeekdayCalendarUnit fromDate:offsetTime];
    
    NSInteger weekday = components.weekday - 1;
    
    for (SpecialModel *special in self.specials) {
        if (special.weekday == weekday) {
            return special;
        }
    }
    
    return nil;
}

- (LiveSpecialModel*)currentLiveSpecial {
    LiveSpecialModel *currentLiveSpecial = nil;
    
    NSDate *now = [NSDate date];
    for (LiveSpecialModel *liveSpecial in [self liveSpecials]) {
        
        //NSLog(@"LS Start date - %@", [liveSpecial startDate]);
        //NSLog(@"LS End date - %@", [liveSpecial endDate]);
        
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

- (SpotModel *)cachedSpotForKey:(NSString *)key {
    return [self objectForKey:key];
}

- (void)cacheSpot:(SpotModel *)spot withKey:(NSString *)key {
    if (spot) {
        [self setObject:spot forKey:key];
    }
    else {
        [self removeObjectForKey:key];
    }
}

@end
