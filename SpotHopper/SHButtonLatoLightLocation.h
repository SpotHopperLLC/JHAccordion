//
//  SHButtonLatoLightLocation.h
//  SpotHopper
//
//  Created by Josh Holtz on 2/19/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHButtonLatoLight.h"

#import "LocationChooserViewController.h"

@class CLLocation;

@protocol SHButtonLatoLightLocationDelegate;

@interface SHButtonLatoLightLocation : SHButtonLatoLight

@property (nonatomic, assign) id<SHButtonLatoLightLocationDelegate> delegate;

- (void)updateWithLocation:(CLLocation*)location;
- (void)updateWithLastLocation;
- (void)updateWithCurrentLocation;

@end

@protocol SHButtonLatoLightLocationDelegate <NSObject>

- (void)locationRequestsUpdate:(SHButtonLatoLightLocation*)button location:(LocationChooserViewController*)viewController;
- (void)locationUpdate:(SHButtonLatoLightLocation*)button location:(CLLocation*)location name:(NSString*)name;
- (void)locationError:(SHButtonLatoLightLocation*)button error:(NSError*)error;

@end