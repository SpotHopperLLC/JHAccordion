//
//  CheckInModel.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/5/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "CheckInModel.h"

@implementation CheckInModel

- (Promise *)postCheckIn:(NSDictionary *)params success:(void(^)(CheckInModel *checkInModel, JSONAPI* jsonAPI))successBlock failure:(void(^)(ErrorModel* errorModel))failureBlock {
    // Creating deferred for promises
//    Deferred *deferred = [Deferred deferred];
//    
//    [[ClientSessionManager sharedClient] POST:@"/api/drinks" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        // Parses response with JSONAPI
//        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
//        
//        if (operation.response.statusCode == 200) {
//            DrinkModel *model = [jsonApi resourceForKey:@"drinks"];
//            successBlock(model, jsonApi);
//            
//            // Resolves promise
//            [deferred resolve];
//        } else {
//            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
//            failureBlock(errorModel);
//            
//            // Rejects promise
//            [deferred rejectWith:errorModel];
//        }
//    }];
//    
//    return deferred.promise;
    return nil;
}

@end
