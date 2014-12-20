//
//  SHLocationManager.h
//  SpotChat
//
//  Created by Brennan Stehling on 10/9/14.
//  Copyright (c) 2014 SpotHopper LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SHLocationManager : NSObject

@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) BOOL isDenied;
@property (nonatomic, readonly) BOOL isAuthorized;
@property (nonatomic, readonly) BOOL isAuthorizationNotDetermined;

@property (assign, nonatomic, getter=isMonitoringEnabled) BOOL monitoringEnabled;

+ (instancetype)defaultInstance;

- (void)wakeUp;

@end
