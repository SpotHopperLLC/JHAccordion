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

#define kPageSize @25

@implementation SpotModel

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
        
        if (operation.response.statusCode == 200) {
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
    NSInteger dayOfWeek = [comps weekday] -1;
    
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
        
        if (operation.response.statusCode == 200) {
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
        
        if (operation.response.statusCode == 200) {
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

- (Promise *)getSpot:(NSDictionary *)params success:(void (^)(SpotModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/spots/%ld", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
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

- (Promise *)getMenuItems:(NSDictionary *)params success:(void (^)(NSArray *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/spots/%ld/menu_items", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
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

#pragma mark - Getters

- (NSString *)name {
    return [self objectForKey:@"name"];
}

- (NSString *)imageUrl {
    return [self objectForKey:@"image_url"];
}

- (NSString *)address {
    return [self objectForKey:@"address"];
}

-(NSString *)city {
    return [self objectForKey:@"city"];
}

- (NSString *)state {
    return [self objectForKey:@"state"];
}

- (NSString *)zip {
    return [self objectForKey:@"zip"];
}

- (NSString*)addressCityState {
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

- (NSString*)fullAddress {
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

- (NSString*)cityState {
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

- (NSString *)phoneNumber {
    return [self objectForKey:@"phone_number"];
}

- (NSArray *)hoursOfOperation {
    return [self objectForKey:@"hours_of_operation"];
}

- (NSNumber *)latitude {
    return [self objectForKey:@"latitude"];
}

- (NSNumber *)longitude {
    return [self objectForKey:@"longitude"];
}

- (NSArray *)sliders {
    return [self objectForKey:@"sliders"];
}

- (NSArray *)sliderTemplates {
    return [[self linkedResourceForKey:@"slider_templates"] sortedArrayUsingComparator:^NSComparisonResult(SliderTemplateModel *obj1, SliderTemplateModel *obj2) {
        return [obj1.order compare:obj2.order];
    }];
}

- (NSString *)foursquareId {
    return [self objectForKey:@"foursquare_id"];
}

- (SpotTypeModel *)spotType {
    return [self linkedResourceForKey:@"spot_type"];
}

- (AverageReviewModel *)averageReview {
    return [self linkedResourceForKey:@"average_review"];
}

- (NSNumber *)match {
    return [self objectForKey:@"match"];
}

- (NSNumber *)relevance {
    NSNumber *rel = [self objectForKey:@"relevance"];
    return ( rel == nil ? @0 : rel );
}

- (NSArray *)images {
    return [self linkedResourceForKey:@"images"];
}

- (NSArray *)dailySpecials {
    return [self objectForKey:@"daily_specials"];
}

- (NSArray *)liveSpecials {
    return [self linkedResourceForKey:@"live_specials"];
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
