//
//  SHButtonLatoLightLocation.m
//  SpotHopper
//
//  Created by Josh Holtz on 2/19/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHButtonLatoLightLocation.h"

#import "TellMeMyLocation.h"
#import "ErrorModel.h"
#import "Tracker.h"

#import "LocationChooserViewController.h"

@interface SHButtonLatoLightLocation() <LocationChooserViewControllerDelegate>

@property (nonatomic, strong) TellMeMyLocation *tellMeMyLocation;

@end

@implementation SHButtonLatoLightLocation

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLatoLightLocation];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupLatoLightLocation];
    }
    return self;
}

- (void)setupLatoLightLocation {
    _tellMeMyLocation = [[TellMeMyLocation alloc] init];
    
    [self setImage:[UIImage imageNamed:@"img_arrow_east.png"] forState:UIControlStateNormal];
    [self addTarget:self action:@selector(onClickSelf:) forControlEvents:UIControlEventTouchUpInside];

#ifdef STAGING
    NSLog(@"%@ - %@", kTellMeMyLocationChangedNotification, NSStringFromClass([self class]));
    NSCAssert([self respondsToSelector:@selector(tellMeMyLocationChangedNotification:)], @"Current instance must implement tellMeMyLocationChangedNotification:");
#endif
    
    if ([self isKindOfClass:[SHButtonLatoLightLocation class]] && [self respondsToSelector:@selector(tellMeMyLocationChangedNotification:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tellMeMyLocationChangedNotification:)
                                                     name:kTellMeMyLocationChangedNotification
                                                   object:nil];
    }
    else {
        NSLog(@"self: %@", NSStringFromClass([self class]));
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTellMeMyLocationChangedNotification object:nil];
    [self removeTarget:self action:@selector(onClickSelf:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kTellMeMyLocationChangedNotification
                                                  object:nil];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:[NSString stringWithFormat:@"%@", title] forState:UIControlStateNormal];
    
    CGFloat textWidth = [self widthForString:title font:self.titleLabel.font maxWidth:CGFLOAT_MAX];
    self.imageEdgeInsets = UIEdgeInsetsMake(0, (textWidth + 10), 0, 0);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, -7, 0, 0);
}

- (void)updateTitle:(NSString*)locationName location:(CLLocation*)location {
    if (locationName.length == 0) {
        [self setTitle:@"<no location selected>" forState:UIControlStateNormal];
    } else {
        [self setTitle:locationName forState:UIControlStateNormal];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(locationUpdate:location:name:)]) {
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
    [_tellMeMyLocation findMe:kCLLocationAccuracyKilometer found:^(CLLocation *newLocation) {
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
        [Tracker logError:error.description class:[self class] trace:NSStringFromSelector(_cmd)];
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
            if ([_delegate respondsToSelector:@selector(locationDidChooseLocation:)]) {
                [_delegate locationDidChooseLocation:location];
            }
        }];
        
    }];
}

#pragma mark - Private

- (CGFloat)widthForString:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxHeight {
    if (![text isKindOfClass:[NSString class]] || !text.length) {
        // no text means no height
        return 0;
    }
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    CGSize size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, maxHeight) options:options attributes:attributes context:nil].size;
    CGFloat width = ceilf(size.width) + 1; // add 1 point as padding
    
    return width;
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

#pragma mark - Notifications

- (void)tellMeMyLocationChangedNotification:(NSNotification *)notification {
    [self updateWithLastLocation];
}

@end
