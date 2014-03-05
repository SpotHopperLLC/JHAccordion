//
//  AverageReviewModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/5/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

@class DrinkModel, SpotModel;

@interface AverageReviewModel : SHJSONAPIResource

@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSArray *sliders;

@property (nonatomic, strong) DrinkModel *drink;
@property (nonatomic, strong) SpotModel *spot;

@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;

@end
