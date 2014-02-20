//
//  TellMeMyLocation.h
//  PatronApp
//
//  Created by Josh Holtz on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define kTellMeMyLocationDomain @"TellMeMyLocationDomain"

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

typedef void(^FoundBlock)(CLLocation *newLocation);
typedef void(^FailureBlock)(NSError *error);

typedef void (^TellMeMyLocationCompletionHandler)();

@interface TellMeMyLocation : NSObject<CLLocationManagerDelegate>

- (void)findMe:(CLLocationAccuracy)accuracy found:(FoundBlock)foundBlock failure:(FailureBlock)failureBlock;

+ (void)setLastLocation:(CLLocation*)location completionHandler:(TellMeMyLocationCompletionHandler)completionHandler;
+ (void)setLastLocationName:(NSString*)name;

+ (CLLocation*)lastLocation;
+ (NSString*)lastLocationName;

@end
