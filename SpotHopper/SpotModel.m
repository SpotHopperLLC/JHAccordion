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
#import "SliderTemplateModel.h"

@implementation SpotModel

#pragma mark - API

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
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/spots/%d", [self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/spots/%d/menu_items", [self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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

- (NSArray *)images {
    return [self linkedResourceForKey:@"images"];
}

- (UIImage *)placeholderImage {
    return [UIImage imageNamed:@"spot_placeholder"];
}

@end
