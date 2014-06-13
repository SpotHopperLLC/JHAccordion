//
//  SpotListRequest.m
//  SpotHopper
//
//  Created by Brennan Stehling on 6/13/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SpotListRequest.h"

@implementation SpotListRequest

- (id)copyWithZone:(NSZone *)zone {
	SpotListRequest *copy = [[[self class] alloc] init];
    
    copy.name = self.name;
    copy.coordinate = self.coordinate;
    copy.sliders = self.sliders;
    copy.spotId = self.spotId;
    copy.spotTypeId = self.spotTypeId;
    
    return copy;
}

@end
