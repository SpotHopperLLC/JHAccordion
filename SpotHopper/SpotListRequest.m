//
//  SpotListRequest.m
//  SpotHopper
//
//  Created by Brennan Stehling on 6/13/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SpotListRequest.h"

@implementation SpotListRequest

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	SpotListRequest *copy = [[[self class] alloc] init];
    
    copy.name = self.name;
    copy.coordinate = self.coordinate;
    copy.radius = self.radius;
    copy.sliders = self.sliders;
    copy.spotListId = self.spotListId;
    copy.spotId = self.spotId;
    copy.spotTypeId = self.spotTypeId;
    
    return copy;
}

@end
