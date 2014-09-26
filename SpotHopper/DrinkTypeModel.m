//
//  DrinkTypeModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 2/6/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "DrinkTypeModel.h"

#import "Constants.h"
#import "SHAppConfiguration.h"

@implementation DrinkTypeModel

#pragma mark - Public

- (UIImage *)placeholderImage {
    if ([self.ID isEqual:kBeerDrinkTypeID]) {
        return [UIImage imageNamed:@"beer_placeholder"];
    } else if ([self.ID isEqual:kWineDrinkTypeID]) {
        return [UIImage imageNamed:@"cocktail_placeholder"];
    } else if ([self.ID isEqual:kCocktailDrinkTypeID]) {
        return [UIImage imageNamed:@"wine_placeholder"];
    }
    
    return nil;
}

+ (instancetype)beerDrinkType {
    DrinkTypeModel *drinkType = [[DrinkTypeModel alloc] init];
    drinkType.name = kDrinkTypeNameBeer;
    drinkType.ID = kBeerDrinkTypeID;
    
    return drinkType;
}

+ (instancetype)wineDrinkType {
    DrinkTypeModel *drinkType = [[DrinkTypeModel alloc] init];
    drinkType.name = kDrinkTypeNameWine;
    drinkType.ID = kWineDrinkTypeID;
    
    return drinkType;
}

+ (instancetype)cocktailDrinkType {
    DrinkTypeModel *drinkType = [[DrinkTypeModel alloc] init];
    drinkType.name = kDrinkTypeNameCocktail;
    drinkType.ID = kCocktailDrinkTypeID;
    
    return drinkType;
}

- (BOOL)isBeer {
    return [self.ID isEqual:kBeerDrinkTypeID];
}

- (BOOL)isWine {
    return [self.ID isEqual:kWineDrinkTypeID];
}

- (BOOL)isCocktail {
    return [self.ID isEqual:kCocktailDrinkTypeID];
}

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ [%@]", self.ID, self.name, NSStringFromClass([self class])];
}

- (id)debugQuickLookObject {
    return self.name;
}

#pragma mark -

- (NSDictionary *)mapKeysToProperties {
    // Maps linked resource in JSON key 'name' to 'name' property
    // Maps values in JSON key 'created_at' to 'Date:createdAt' property
    // Maps values in JSON key 'updated_at' to 'Date:updatedAt' property
    return @{
             @"name" : @"name",
             @"created_at" : @"Date:createdAt",
             @"updated_at" : @"Date:updatedAt"
             };
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	DrinkTypeModel *copy = [super copyWithZone:zone];
    
    copy.name = self.name;
    copy.createdAt = self.createdAt;
    copy.updatedAt = self.updatedAt;
    
    copy.subtypes = self.subtypes;
    
    return copy;
}

@end
