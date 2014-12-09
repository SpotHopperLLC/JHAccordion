//
//  SHAppContext.m
//  SpotHopper
//
//  Created by Brennan Stehling on 9/18/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHAppContext.h"

#import "Tracker+Events.h"
#import "SHAppUtil.h"

#define kMetersPerMile 1609.344

#pragma mark - Class Extension
#pragma mark -

@interface SHAppContext ()

@property (readwrite, strong, nonatomic) SpotListRequest *spotlistRequest;
@property (readwrite, strong, nonatomic) DrinkListRequest *drinkListRequest;
@property (readwrite, strong, nonatomic) SpotListModel *spotlist;
@property (readwrite, strong, nonatomic) DrinkListModel *drinklist;
@property (readwrite, assign, nonatomic) CLLocationCoordinate2D mapCoordinate;
@property (readwrite, assign, nonatomic) CLLocationDistance radius;

@property (readwrite, strong, nonatomic) CLLocation *deviceLocation;
@property (readwrite, strong, nonatomic) CheckInModel *checkin;

@property (readwrite, strong, nonatomic) NSString *activityName;
@property (readwrite, strong, nonatomic) NSDate *activityStartDate;

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
    if (CLLocationCoordinate2DIsValid(self.mapCoordinate)) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.mapCoordinate.latitude longitude:self.mapCoordinate.longitude];
        return location;
    }
    
    return nil;
}

- (CGFloat)radiusInMiles {
    return self.radius / kMetersPerMile;
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

- (void)changeMapCoordinate:(CLLocationCoordinate2D)mapCoordinate andRadius:(CLLocationDistance)radius {
    self.mapCoordinate = mapCoordinate;
    self.radius = radius;
}

- (void)changeDeviceLocation:(CLLocation *)deviceLocation {
    self.deviceLocation = deviceLocation;
}

- (void)changeCheckin:(CheckInModel *)checkin {
    self.checkin = checkin;
}

- (void)startActivity:(NSString *)activityName {
    DebugLog(@"%@ - %@", NSStringFromSelector(_cmd), activityName);
    self.activityName = activityName;
    self.activityStartDate = [NSDate date];
}

- (void)endActivity:(NSString *)activityName {
    DebugLog(@"%@ - %@", NSStringFromSelector(_cmd), activityName);
    if ([activityName isEqualToString:self.activityName]) {
        NSTimeInterval duration = ABS([self.activityStartDate timeIntervalSinceNow]);
        [Tracker trackActivity:activityName duration:duration];

        // reset
        self.activityName = nil;
        self.activityStartDate = nil;
    }
}

#pragma mark - User Profile
#pragma mark -

- (void)setCurrentUserProfile:(SHUserProfileModel *)currentUserProfile {
    _currentUserProfile = currentUserProfile;
    
    [[SHAppUtil defaultInstance] connectParseObjectsWithCompletionBlock:^(BOOL success, NSError *error) {
        if (error) {
            DebugLog(@"Error: %@", error);
        }
        else {
            DebugLog(@"Success: %@", success ? @"YES" : @"NO");
        }
    }];
}

@end
