//
//  DrinkListRequest.m
//  SpotHopper
//
//  Created by Brennan Stehling on 6/4/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "DrinkListRequest.h"

@implementation DrinkListRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        self.basedOnSliders = FALSE;
    }
    return self;
}

- (void)setSliders:(NSArray *)sliders {
    if (sliders.count) {
        _basedOnSliders = TRUE;
        _sliders = sliders;
    }
    else {
        _basedOnSliders = FALSE;
        _sliders = nil;
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	DrinkListRequest *copy = [[[self class] alloc] init];
    
    copy.drinkListId = self.drinkListId;
    copy.name = self.name;
    copy.featured = self.isFeatured;
    copy.basedOnSliders = self.basedOnSliders;
    copy.transient = self.transient;
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
