//
//  SpotListRequest.m
//  SpotHopper
//
//  Created by Brennan Stehling on 6/13/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SpotListRequest.h"

@implementation SpotListRequest

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
	SpotListRequest *copy = [[[self class] alloc] init];
    
    copy.spotListId = self.spotListId;
    copy.name = self.name;
    copy.featured = self.isFeatured;
    copy.basedOnSliders = self.isBasedOnSliders;
    copy.transient = self.transient;
    copy.coordinate = self.coordinate;
    copy.radius = self.radius;
    copy.sliders = self.sliders;
    copy.spotId = self.spotId;
    copy.spotTypeId = self.spotTypeId;
    
    return copy;
}

@end
