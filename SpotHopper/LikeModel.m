//
//  LikeModel.m
//  SpotHopper
//
//  Created by Brennan Stehling on 8/20/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "LikeModel.h"

#import "ClientSessionManager.h"

#import "SpecialModel.h"
#import "DrinkModel.h"
#import "SpotModel.h"
#import "UserModel.h"
#import "ErrorModel.h"

#import "Tracker.h"
#import "Tracker+Events.h"
#import "Tracker+People.h"

#import "SHNotifications.h"

@interface LikeModelCache : NSCache

- (NSArray *)cachedLikes;
- (void)cacheLikes:(NSArray *)likes;

@end

@implementation LikeModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ [%@]", self.ID, NSStringFromClass([self class])];
}

- (id)debugQuickLookObject {
    return @"Like";
}

#pragma mark - Mappings

- (NSDictionary *)mapKeysToProperties {
    return @{
             @"links.daily_special" : @"special",
             @"links.drink" : @"drink",
             @"links.spot" : @"spot",
             @"links.user" : @"user"
             };
}

#pragma mark - Caching

+ (LikeModelCache *)sh_sharedCache {
    static LikeModelCache *_sh_Cache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sh_Cache = [[LikeModelCache alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_sh_Cache removeAllObjects];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:SHUserDidLogOutNotificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_sh_Cache removeAllObjects];
        }];
    });
    
    return _sh_Cache;
}

////// Service Layer //////

+ (void)fetchLikesForUser:(UserModel *)user success:(void(^)(NSArray *likes))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    NSArray *likes = [[self sh_sharedCache] cachedLikes];
    if (likes.count && successBlock) {
        successBlock(likes);
        return;
    }
    
    NSDictionary *params = @{};
    NSDate *startDate = [NSDate date];
    NSString *path = [NSString stringWithFormat:@"/api/users/%ld/likes", (long)[user.ID integerValue]];
    
    [[ClientSessionManager sharedClient] GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startDate];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            NSArray *likes = [jsonApi resourcesForKey:@"likes"];
            
            [[self sh_sharedCache] cacheLikes:likes];
            
            // only track a successful search
            [Tracker track:@"Fetch User Likes" properties:@{ @"Duration" : [NSNumber numberWithInteger:duration] }];
            
            if (successBlock) {
                successBlock(likes);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

+ (Promise *)fetchLikesForUser:(UserModel *)user {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self fetchLikesForUser:user success:^(NSArray *likes) {
        // Resolves promise
        [deferred resolveWith:likes];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

+ (void)likeSpecial:(SpecialModel *)special success:(void(^)(LikeModel *like))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    NSNumber *specialId = [NSNumber numberWithInteger:[special.ID integerValue]];
    
    NSDictionary *params = @{
                             @"daily_special_id" : specialId
                             };
    NSDate *startDate = [NSDate date];
    NSString *path = [NSString stringWithFormat:@"/api/likes"];

    [[ClientSessionManager sharedClient] POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startDate];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            [Tracker trackUserLikedSpecial:special];
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            // only track a successful search
            [Tracker track:@"Post Like Special" properties:@{ @"Duration" : [NSNumber numberWithInteger:duration] }];
            
            NSArray *likes = [jsonApi resourcesForKey:@"likes"];
            LikeModel *like = likes.count ? likes[0] : nil;
            
            [self addLike:like];
            
            if (successBlock) {
                successBlock(like);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

+ (Promise *)likeSpecial:(SpecialModel *)special {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self likeSpecial:special success:^(LikeModel *like) {
        // Resolves promise
        [deferred resolveWith:like];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

+ (void)unlikeSpecial:(SpecialModel *)special success:(void(^)(BOOL success))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    NSDictionary *params = @{};
    NSDate *startDate = [NSDate date];
    NSString *path = [NSString stringWithFormat:@"/api/daily_specials/%li/likes", (long)[special.ID integerValue]];
    
    [[ClientSessionManager sharedClient] DELETE:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startDate];
        
        [[LikeModel likeForSpecial:special] then:^(LikeModel *like) {
            [self removeLike:like];
        } fail:nil always:nil];
        
        // deletes set the status code to 204
        if (operation.isCancelled || operation.response.statusCode == 204) {
            // only track a successful search
            [Tracker trackUserUnlikedSpecial:special];
            [Tracker track:@"Delete Like Special" properties:@{ @"Duration" : [NSNumber numberWithInteger:duration] }];

            if (successBlock) {
                successBlock(TRUE);
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

+ (Promise *)unlikeSpecial:(SpecialModel *)special {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self unlikeSpecial:special success:^(BOOL success) {
        // Resolves promise
        [deferred resolveWith:[NSNumber numberWithBool:success]];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

+ (void)likeForSpecial:(SpecialModel *)special success:(void(^)(LikeModel *like))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    [self fetchLikesForUser:[UserModel currentUser] success:^(NSArray *likes) {
        LikeModel *matchedLike = nil;
        for (LikeModel *like in likes) {
            if ([special isEqual:like.special]) {
                matchedLike = like;
                break;
            }
        }
        
        if (successBlock) {
            successBlock(matchedLike);
        }
    } failure:^(ErrorModel *errorModel) {
        if (failureBlock) {
            failureBlock(errorModel);
        }
    }];
}

+ (Promise *)likeForSpecial:(SpecialModel *)special {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self likeForSpecial:special success:^(LikeModel *like) {
        // Resolves promise
        [deferred resolveWith:like];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

+ (void)addLike:(LikeModel *)like {
    [self fetchLikesForUser:[UserModel currentUser] success:^(NSArray *likes) {
        NSMutableArray *updatedLikes = likes.mutableCopy;
        NSUInteger index = [updatedLikes indexOfObject:like];
        if (index != NSNotFound) {
            [updatedLikes replaceObjectAtIndex:index withObject:like];
        }
        else {
            [updatedLikes addObject:like];
        }
        
        [[self sh_sharedCache] cacheLikes:updatedLikes];
    } failure:^(ErrorModel *errorModel) {
        // do nothing
    }];
}

+ (void)removeLike:(LikeModel *)like {
    [self fetchLikesForUser:[UserModel currentUser] success:^(NSArray *likes) {
        NSMutableArray *updatedLikes = likes.mutableCopy;
        NSUInteger index = [updatedLikes indexOfObject:like];
        if (index != NSNotFound) {
            [updatedLikes removeObjectAtIndex:index];
        }
        
        [[self sh_sharedCache] cacheLikes:updatedLikes];
    } failure:^(ErrorModel *errorModel) {
        // do nothing
    }];
}

@end

#pragma mark - Caching

@implementation LikeModelCache

NSString * const LikesKey = @"LikesKey";

- (NSArray *)cachedLikes {
    return [self objectForKey:LikesKey];
}

- (void)cacheLikes:(NSArray *)likes {
    if (likes.count) {
        [self setObject:likes forKey:LikesKey];
    }
    else {
        [self removeObjectForKey:LikesKey];
    }
}

@end
