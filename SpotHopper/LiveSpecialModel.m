//
//  LiveSpecialModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/26/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "LiveSpecialModel.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"

@implementation LiveSpecialModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", self.ID, self.href];
}

#pragma mark -

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'text' to 'text' property
    // Maps values in JSON key 'start_date' to 'startDateStr' property
    // Maps values in JSON key 'end_date' to 'endDateStr' property
    // Maps linked resource in JSON key 'spot' to 'spot' property
    return @{
             @"text" : @"text",
             @"start_date" : @"startDateStr",
             @"end_date" : @"endDateStr",
             @"links.spot" : @"spot"
             };
}

- (NSDate *)startDate {
    return [self formatDateTimestamp:[self startDateStr]];
}

- (NSDate *)endDate {
    return [self formatDateTimestamp:[self endDateStr]];
}

#pragma mark - API

- (Promise *)getLiveSpecial:(NSDictionary *)params success:(void (^)(LiveSpecialModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock {
    
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [[ClientSessionManager sharedClient] GET:[NSString stringWithFormat:@"/api/live_specials/%li", (long)[self.ID integerValue]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            LiveSpecialModel *model = [jsonApi resourceForKey:@"live_specials"];
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
