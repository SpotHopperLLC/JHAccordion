//
//  SHAppContext.m
//  SpotHopper
//
//  Created by Brennan Stehling on 9/18/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHAppContext.h"

@implementation SHAppContext

+ (instancetype)defaultInstance {
    static SHAppContext *defaultInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        defaultInstance = [[SHAppContext alloc] init];
    });
    return defaultInstance;
}

- (void)changeContextToMode:(SHMode)mode specialsSpotlist:(SpotListModel *)spotlist {
    self.mode = mode;
    self.spotlist = spotlist;
    
    self.spotlistRequest = nil;
    self.drinkListRequest = nil;
    self.drinklist = nil;
}

- (void)changeContextToMode:(SHMode)mode spotlistRequest:(SpotListRequest *)spotlistRequest spotlist:(SpotListModel *)spotlist {
    self.mode = mode;
    self.spotlistRequest = spotlistRequest;
    self.spotlist = spotlist;
    
    self.drinkListRequest = nil;
    self.drinklist = nil;
}

- (void)changeContextToMode:(SHMode)mode drinklistRequest:(DrinkListRequest *)drinklistRequest drinklist:(DrinkListModel *)drinklist {
    self.mode = mode;
    self.drinkListRequest = drinklistRequest;
    self.drinklist = drinklist;
    
    self.spotlistRequest = nil;
    self.spotlist = nil;
}

- (void)changeCoordinate:(CLLocationCoordinate2D)coordinate andRadius:(CLLocationDistance)radius {
    self.coordinate = coordinate;
    self.radius = radius;
}

@end
