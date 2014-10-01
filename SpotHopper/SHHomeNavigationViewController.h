//
//  SHHomeNavigationViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/13/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

#import <MapKit/MapKit.h>

@protocol SHHomeNavigationDelegate;

@interface SHHomeNavigationViewController : BaseViewController <MKMapViewDelegate>

@property (weak, nonatomic) id<SHHomeNavigationDelegate> delegate;

@end

@protocol SHHomeNavigationDelegate <NSObject>

@optional

- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc checkInButtonTapped:(id)sender;
- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc spotsButtonTapped:(id)sender;
- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc specialsButtonTapped:(id)sender;
- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc beersButtonTapped:(id)sender;
- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc cocktailsButtonTapped:(id)sender;
- (void)homeNavigationViewController:(SHHomeNavigationViewController *)vc winesButtonTapped:(id)sender;

@end