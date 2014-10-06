//
//  SHAppContext.h
//  SpotHopper
//
//  Created by Brennan Stehling on 9/18/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Constants.h"

#import "SpotListRequest.h"
#import "DrinkListRequest.h"
#import "SpotListModel.h"
#import "DrinkListModel.h"
#import "CheckInModel.h"

@interface SHAppContext : NSObject

@property (assign, nonatomic) SHMode mode;

@property (readonly, nonatomic) SpotListRequest *spotlistRequest;
@property (readonly, nonatomic) DrinkListRequest *drinkListRequest;
@property (readonly, nonatomic) SpotListModel *spotlist;
@property (readonly, nonatomic) DrinkListModel *drinklist;
@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;
@property (readonly, nonatomic) CLLocationDistance radius;

@property (readonly, nonatomic) CLLocation *mapLocation;

@property (readonly, nonatomic) CLLocation *deviceLocation;
@property (readonly, nonatomic) CheckInModel *checkin;

+ (instancetype)defaultInstance;

- (void)changeContextToMode:(SHMode)mode specialsSpotlist:(SpotListModel *)spotlist;

- (void)changeContextToMode:(SHMode)mode spotlistRequest:(SpotListRequest *)spotlistRequest spotlist:(SpotListModel *)spotlist;

- (void)changeContextToMode:(SHMode)mode drinklistRequest:(DrinkListRequest *)drinklistRequest drinklist:(DrinkListModel *)drinklist;

- (void)changeMapCoordinate:(CLLocationCoordinate2D)coordinate andRadius:(CLLocationDistance)radius;

- (void)changeDeviceLocation:(CLLocation *)deviceLocation;

- (void)changeCheckin:(CheckInModel *)checkin;

@end
