//
//  ReviewModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

#import "NSDictionary+Slider.h"

@class DrinkModel;
@class ErrorModel;
@class SpotModel;
@class UserModel;

@interface ReviewModel : SHJSONAPIResource

@property (nonatomic, strong) UserModel *user;
@property (nonatomic, strong) NSNumber *userId;

@property (nonatomic, strong) SpotModel *spot;
@property (nonatomic, strong) NSNumber *spotId;

@property (nonatomic, strong) DrinkModel *drink;
@property (nonatomic, strong) NSNumber *drinkId;

@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSArray *sliders;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;

+ (void)getReviews:(NSDictionary*)params success:(void(^)(NSArray *reviewModels))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

@end
