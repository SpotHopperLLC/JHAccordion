//
//  SHButtonLatoLightLocation.m
//  SpotHopper
//
//  Created by Josh Holtz on 2/19/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHButtonLatoLightLocation.h"

#import "TellMeMyLocation.h"

#import "LocationChooserViewController.h"

@interface SHButtonLatoLightLocation()<LocationChooserViewControllerDelegate>

@property (nonatomic, strong) TellMeMyLocation *tellMeMyLocation;

@end

@implementation SHButtonLatoLightLocation

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _tellMeMyLocation = [[TellMeMyLocation alloc] init];
    
    [self addTarget:self action:@selector(onClickSelf:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc {
    [self removeTarget:self action:@selector(onClickSelf:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:[NSString stringWithFormat:@"%@", title] forState:UIControlStateNormal];
}

- (void)updateTitle:(NSString*)locationName location:(CLLocation*)location {

    if (locationName.length == 0) {
        [self setTitle:@"<no location selected>" forState:UIControlStateNormal];
    } else {
        [self setTitle:locationName forState:UIControlStateNormal];
    }
    
    if ([_delegate respondsToSelector:@selector(locationUpdate:location:name:)]) {
        
        [_delegate locationUpdate:self location:location name:locationName];
    }
}

- (void)updateWithLocation:(CLLocation*)location {
    if (location.coordinate.latitude == 0.0f && location.coordinate.longitude == 0.0f) {
        [self updateWithLastLocation];
        return;
    }
    
    // Reverse geocodes
    [[[CLGeocoder alloc] init] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        // Saves location name
        if (!error) {
            if (placemarks.count > 0) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                
                NSString *name = nil;
                if (placemark.locality.length > 0 && placemark.administrativeArea.length > 0) {
                    name = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
                } else if (placemark.locality.length > 0) {
                    name = placemark.locality;
                } else if (placemark.administrativeArea.length > 0) {
                    name = placemark.administrativeArea;
                }
                [self updateTitle:name location:location];
                
            } else {
                [self updateTitle:nil location:nil];
            }
        } else {
            [self updateTitle:nil location:nil];
            
            if ([_delegate respondsToSelector:@selector(locationError:error:)]) {
                [_delegate locationError:self error:error];
            }
        }
        
    }];
}

- (void)updateWithLastLocation {
 
    CLLocation *lastLocation = [TellMeMyLocation lastLocation];
    if (lastLocation == nil) {
        [self updateWithCurrentLocation];
    } else {
        [self updateTitle:[TellMeMyLocation lastLocationName] location:lastLocation];
    }
}

- (void)updateWithCurrentLocation {
    [_tellMeMyLocation findMe:kCLLocationAccuracyThreeKilometers found:^(CLLocation *newLocation) {
        [TellMeMyLocation setLastLocation:newLocation completionHandler:^{
            [self updateTitle:[TellMeMyLocation lastLocationName] location:newLocation];
        }];
    } failure:^(NSError *error){
        [self updateTitle:nil location:nil];
        
        if ([_delegate respondsToSelector:@selector(locationError:error:)]) {
            if ([error.domain isEqualToString:kTellMeMyLocationDomain]) {
                [_delegate locationError:self error:error];
            }
        }
    }];
}

#pragma mark - LocationChooserViewControllerDelegate

- (void)locationChooserViewController:(LocationChooserViewController *)viewController updateLocation:(CLLocation *)location {
    // Shows hud when geocoding location to find name
    [viewController showHUD:@"Locating..."];
    
    [TellMeMyLocation setLastLocation:location completionHandler:^{
        
        // Hides da hud
        [viewController hideHUD];
        
        // Dismisses view controller
        [viewController dismissViewControllerAnimated:YES completion:^{
            [self updateTitle:[TellMeMyLocation lastLocationName] location:location];
        }];
        
    }];
}

#pragma mark - Actions

- (void)onClickSelf:(id)sender {
    if ([_delegate respondsToSelector:@selector(locationRequestsUpdate:location:)]) {
        LocationChooserViewController *viewController = [LocationChooserViewController locationChooser];
        [viewController setDelegate:self];
        [viewController setInitialLocation:[TellMeMyLocation lastLocation]];
        [_delegate locationRequestsUpdate:self location:viewController];
    }
}

@end
