//
//  TellMeMyLocation.h
//  PatronApp
//
//  Created by Josh Holtz on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface TellMeMyLocation : NSObject<CLLocationManagerDelegate>

- (void)findMe:(CLLocationAccuracy)accuracy found:(void(^)(CLLocation *newLocation))foundBlock failure:(void(^)())failureBlock;

@end
