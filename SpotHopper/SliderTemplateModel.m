//
//  SliderTemplateModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/18/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SliderTemplateModel.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"

@implementation SliderTemplateModel

- (NSString *)name {
    return [self objectForKey:@"name"];
}

- (NSString *)minLabel {
    if (_minLabel != nil) return _minLabel;
    _minLabel = [self objectForKey:@"min_label"];
    return _minLabel;
}

- (NSString *)maxLabel {
    if (_maxLabel != nil) return _maxLabel;
    _maxLabel = [self objectForKey:@"max_label"];
    return _maxLabel;
}

- (NSNumber *)defaultValue {
    if (_defaultValue != nil) return _defaultValue;
    _defaultValue = [self objectForKey:@"default_value"];
    return _defaultValue;
}

- (BOOL)required {
    return [[self objectForKey:@"required"] boolValue];
}

- (NSArray *)spotTypes {
    if (_spotTypes != nil) return _spotTypes;
    _spotTypes = [self linkedResourceForKey:@"spot_types"];
    return _spotTypes;
}

- (NSArray *)drinkTypes {
    if (_drinkTypes != nil) return _drinkTypes;
    _drinkTypes = [self linkedResourceForKey:@"drink_types"];
    return _drinkTypes;
}

- (NSNumber *)order {
    return [self objectForKey:@"order"];
}

#pragma mark - API

+ (Promise*)getSliderTemplates:(NSDictionary*)params success:(void(^)(NSArray *sliderTemplates, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    // Makes page size 300 so we get all slider templates
    if (params == nil) params = @{};
    NSMutableDictionary *mutaParams = params.mutableCopy;
    [mutaParams setObject:@300 forKey:kSliderTemplateModelParamsPageSize];
    
    [[ClientSessionManager sharedClient] GET:@"/api/slider_templates" parameters:mutaParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"slider_templates"];
            models = [models sortedArrayUsingComparator:^NSComparisonResult(SliderTemplateModel *obj1, SliderTemplateModel *obj2) {
                return [obj1.ID compare:obj2.ID];
            }];
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

@end
