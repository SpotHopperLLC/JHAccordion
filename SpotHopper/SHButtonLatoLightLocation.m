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
    [super setTitle:[NSString stringWithFormat:@"%@ >", title] forState:UIControlStateNormal];
}

- (void)updateTitle {
    NSString *locationName =[TellMeMyLocation lastLocationName];
    if (locationName.length == 0) {
        [self setTitle:@"<no location selected>" forState:UIControlStateNormal];
    } else {
        [self setTitle:locationName forState:UIControlStateNormal];
    }
    
    if ([_delegate respondsToSelector:@selector(locationUpdate:location:name:)]) {
        NSString *locationName =[TellMeMyLocation lastLocationName];
        CLLocation *lastLocation = [TellMeMyLocation lastLocation];
        
        [_delegate locationUpdate:self location:lastLocation name:locationName];
    }
}

- (void)updateWithLastLocation {
 
    CLLocation *lastLocation = [TellMeMyLocation lastLocation];
    if (lastLocation == nil) {
        [self updateWithCurrentLocation];
    } else {
        [self updateTitle];
    }
}

- (void)updateWithCurrentLocation {
    [_tellMeMyLocation findMe:kCLLocationAccuracyThreeKilometers found:^(CLLocation *newLocation) {
        [TellMeMyLocation setLastLocation:newLocation completionHandler:^{
            [self updateTitle];
        }];
    } failure:^(NSError *error){
        [self updateTitle];
        
        if ([_delegate respondsToSelector:@selector(locationError:error:)]) {
            if ([error.domain isEqualToString:kTellMeMyLocationDomain]) {
                [_delegate locationError:self error:error];
            }
        }
    }];
}

#pragma mark - LocationChooserViewControllerDelegate

- (void)locationChooserViewController:(LocationChooserViewController *)viewController updateLocation:(CLLocation *)location {
    [viewController dismissViewControllerAnimated:YES completion:^{
        [TellMeMyLocation setLastLocation:location completionHandler:^{
            [self updateTitle];
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
