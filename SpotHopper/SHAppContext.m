//
//  SHAppContext.m
//  SpotHopper
//
//  Created by Brennan Stehling on 9/18/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHAppContext.h"

#pragma mark - Class Extension
#pragma mark -

@interface SHAppContext ()

@property (readwrite, strong, nonatomic) SpotListRequest *spotlistRequest;
@property (readwrite, strong, nonatomic) DrinkListRequest *drinkListRequest;
@property (readwrite, strong, nonatomic) SpotListModel *spotlist;
@property (readwrite, strong, nonatomic) DrinkListModel *drinklist;
@property (readwrite, assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (readwrite, assign, nonatomic) CLLocationDistance radius;

@property (readwrite, strong, nonatomic) CLLocation *deviceLocation;
@property (readwrite, strong, nonatomic) CheckInModel *checkin;

@end

@implementation SHAppContext

+ (instancetype)defaultInstance {
    static SHAppContext *defaultInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        defaultInstance = [[SHAppContext alloc] init];
    });
    return defaultInstance;
}

- (CLLocation *)mapLocation {
    if (CLLocationCoordinate2DIsValid(self.coordinate)) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
        return location;
    }
    
    return nil;
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

- (void)changeMapCoordinate:(CLLocationCoordinate2D)coordinate andRadius:(CLLocationDistance)radius {
    self.coordinate = coordinate;
    self.radius = radius;
}

- (void)changeDeviceLocation:(CLLocation *)deviceLocation {
    self.deviceLocation = deviceLocation;
}

- (void)changeCheckin:(CheckInModel *)checkin {
    self.checkin = checkin;
}

@end
