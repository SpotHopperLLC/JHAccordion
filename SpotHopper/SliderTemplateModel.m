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

#pragma mark - API

+ (Promise*)getSliderTemplates:(NSDictionary*)params success:(void(^)(NSArray *sliderTemplates, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:@"/api/slider_templates" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            NSArray *models = [jsonApi resourcesForKey:@"slider_templates"];
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