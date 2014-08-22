//
//  LikeModel.h
//  SpotHopper
//
//  Created by Brennan Stehling on 8/20/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHJSONAPIResource.h"

@class UserModel, DrinkModel, SpotModel, SpecialModel, ErrorModel;

@interface LikeModel : SHJSONAPIResource

@property (strong, nonatomic) SpecialModel *special;
@property (strong, nonatomic) DrinkModel *drink;
@property (strong, nonatomic) SpotModel *spot;

+ (void)fetchLikesForUser:(UserModel *)user success:(void(^)(NSArray *likes))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)fetchLikesForUser:(UserModel *)user;

+ (void)likeSpecial:(SpecialModel *)special success:(void(^)(LikeModel *like))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)likeSpecial:(SpecialModel *)special;

+ (void)unlikeSpecial:(SpecialModel *)special success:(void(^)(BOOL success))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)unlikeSpecial:(SpecialModel *)special;

+ (void)likeForSpecial:(SpecialModel *)special success:(void(^)(LikeModel *like))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)likeForSpecial:(SpecialModel *)special;

+ (void)addLike:(LikeModel *)like;

+ (void)removeLike:(LikeModel *)like;

@end
