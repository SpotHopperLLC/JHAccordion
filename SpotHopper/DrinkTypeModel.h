//
//  DrinkTypeModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 2/6/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

@interface DrinkTypeModel : SHJSONAPIResource<NSCopying>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;

@property (nonatomic, strong) NSArray *subtypes;

@property (nonatomic, readonly) UIImage *placeholderImage;

@property (nonatomic, readonly) BOOL isBeer;
@property (nonatomic, readonly) BOOL isWine;
@property (nonatomic, readonly) BOOL isCocktail;

+ (instancetype)beerDrinkType;
+ (instancetype)wineDrinkType;
+ (instancetype)cocktailDrinkType;

@end
