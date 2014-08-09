//
//  SHLocationPickerViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 7/8/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol SHLocationPickerDelegate;

@interface SHLocationPickerViewController : BaseViewController

@property (nonatomic, assign) MKCoordinateRegion initialRegion;

@property (nonatomic, weak) id<SHLocationPickerDelegate> delegate;

- (void)setTopContentInset:(CGFloat)topContentInset;

- (void)searchWithText:(NSString *)text;

@end

@protocol SHLocationPickerDelegate <NSObject>

- (void)locationPickerViewController:(SHLocationPickerViewController *)viewController didSelectPlacemark:(CLPlacemark *)placemark;

@end
