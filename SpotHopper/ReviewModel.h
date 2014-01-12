//
//  ReviewModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

//{
//    "id": 1,
//    "user_id" 5,
//    "spot_id": null,
//    "drink_id": 1,
//    "rating": 10,
//    "sliders": [
//                {"id": "radness", "name": "Radness", "min": "UnRad", "max": "Super Rad!", "value": 10}
//                ],
//    "created_at": "2014-01-01T15:12:43+00:00",
//    "updated_at": "2014-01-01T15:12:43+00:00"
//}

#import "SHJSONAPIResource.h"

@class UserModel;
@class SpotModel;
@class DrinkModel;

@interface ReviewModel : SHJSONAPIResource

@property (nonatomic, strong) UserModel *user;
@property (nonatomic, strong) NSNumber *userId;

@property (nonatomic, strong) SpotModel *spot;
@property (nonatomic, strong) NSNumber *spotId;

@property (nonatomic, strong) DrinkModel *drink;
@property (nonatomic, strong) NSNumber *drinkId;

@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSDictionary *sliders;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;

@end
