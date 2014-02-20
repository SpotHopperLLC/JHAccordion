//
//  TellMeMyLocation.h
//  PatronApp
//
//  Created by Josh Holtz on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

typedef void (^TellMeMyLocationCompletionHandler)();

@interface TellMeMyLocation : NSObject<CLLocationManagerDelegate>

- (void)findMe:(CLLocationAccuracy)accuracy found:(void(^)(CLLocation *newLocation))foundBlock failure:(void(^)())failureBlock;

+ (void)setLastLocation:(CLLocation*)location completionHandler:(TellMeMyLocationCompletionHandler)completionHandler;
+ (void)setLastLocationName:(NSString*)name;

+ (CLLocation*)lastLocation;
+ (NSString*)lastLocationName;

@end
