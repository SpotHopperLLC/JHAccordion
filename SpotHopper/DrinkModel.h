//
//  DrinkModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

@class ErrorModel;
@class SpotModel;

@interface DrinkModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *subtype;
@property (nonatomic, strong) NSString *descriptionOfDrink;
@property (nonatomic, strong) NSNumber *alcoholByVolume;
@property (nonatomic, strong) NSString *style;
@property (nonatomic, strong) NSNumber *vintage;
@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) NSString *recipe;
@property (nonatomic, strong) SpotModel *spot;
@property (nonatomic, strong) NSNumber *spotId;

+ (void)getDrinks:(NSDictionary*)params success:(void(^)(NSArray *drinkModels))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

@end
