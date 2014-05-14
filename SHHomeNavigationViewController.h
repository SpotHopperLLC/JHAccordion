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

- (void)homeNavigationViewControllerDidRequestSpots:(SHHomeNavigationViewController *)vc;
- (void)homeNavigationViewControllerDidRequestSpecials:(SHHomeNavigationViewController *)vc;
- (void)homeNavigationViewControllerDidRequestBeers:(SHHomeNavigationViewController *)vc;
- (void)homeNavigationViewControllerDidRequestCocktails:(SHHomeNavigationViewController *)vc;
- (void)homeNavigationViewControllerDidRequestWines:(SHHomeNavigationViewController *)vc;

@end