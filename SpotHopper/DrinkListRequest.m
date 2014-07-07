//
//  DrinkListRequest.m
//  SpotHopper
//
//  Created by Brennan Stehling on 6/4/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "DrinkListRequest.h"

@implementation DrinkListRequest

- (id)copyWithZone:(NSZone *)zone {
	DrinkListRequest *copy = [[[self class] alloc] init];
    
    copy.drinkListId = self.drinkListId;
    copy.name = self.name;
    copy.isFeatured = self.isFeatured;
    copy.coordinate = self.coordinate;
    copy.sliders = self.sliders;
    copy.drinkId = self.drinkId;
    copy.drinkTypeId = self.drinkTypeId;
    copy.drinkSubTypeId = self.drinkSubTypeId;
    copy.baseAlcoholId = self.baseAlcoholId;
    copy.spotId = self.spotId;

    return copy;
}

@end
