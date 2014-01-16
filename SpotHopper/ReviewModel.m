//
//  ReviewModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "ReviewModel.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"

#import <JSONAPI/JSONAPI.h>

@implementation ReviewModel

#pragma mark - API

+ (void)getReviews:(NSDictionary*)params success:(void(^)(NSArray *reviewModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    
    [[ClientSessionManager sharedClient] GET:@"/api/reviews" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == 200) {
            JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
            
            NSArray *models = [jsonApi resourcesForKey:@"reviews"];
            successBlock(models, jsonApi);
            
        } else {
            JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
            
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
        }
    }];
    
}

#pragma mark - Getters

- (UserModel *)user {
    return [self linkedResourceForKey:@"user"];
}

- (NSNumber *)userId {
    return [self objectForKey:@"user_id"];
}

- (SpotModel *)spot {
    return [self linkedResourceForKey:@"spot"];
}

- (NSNumber *)spotId {
    return [self objectForKey:@"spot_id"];
}

- (DrinkModel *)drink {
    return [self linkedResourceForKey:@"drink"];
}

- (NSNumber *)drinkId {
    return [self objectForKey:@"drink_id"];
}

- (NSNumber *)rating {
    return [self objectForKey:@"rating"];
}

- (NSArray *)sliders {
    return [self objectForKey:@"sliders"];
}

- (NSDate *)createdAt {
    return [self formatDateTimestamp:[self objectForKey:@"created_at"]];
}

- (NSDate *)updatedAt {
    return [self formatDateTimestamp:[self objectForKey:@"updated_at"]];
}

@end
