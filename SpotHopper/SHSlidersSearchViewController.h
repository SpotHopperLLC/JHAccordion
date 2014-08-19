//
//  SHSearchViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/22/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

@class DrinkListRequest;
@class DrinkListModel;
@class SpotListRequest;
@class SpotListModel;
@class SpotModel;

#import <CoreLocation/CoreLocation.h>

@protocol SHSlidersSearchDelegate;

@interface SHSlidersSearchViewController : BaseViewController

@property (weak, nonatomic) id<SHSlidersSearchDelegate> delegate;

//@property (readonly, nonatomic) DrinkListModel *drinkListModel;

- (void)prepareForMode:(SHMode)mode;

@end

@protocol SHSlidersSearchDelegate <NSObject>

@optional

- (void)slidersSearchViewController:(SHSlidersSearchViewController *)vc didPrepareSpotlist:(SpotListModel *)spotlistModel withRequest:(SpotListRequest *)request forMode:(SHMode)mode;

- (void)slidersSearchViewController:(SHSlidersSearchViewController *)vc didPrepareDrinklist:(DrinkListModel *)drinkListModel withRequest:(DrinkListRequest *)request forMode:(SHMode)mode;

- (void)slidersSearchViewControllerWillAnimate:(SHSlidersSearchViewController *)vc;

- (void)slidersSearchViewControllerDidAnimate:(SHSlidersSearchViewController *)vc;

- (SpotModel *)slidersSearchViewControllerScopedSpot:(SHSlidersSearchViewController *)vc;

@required

- (CLLocationCoordinate2D)searchCoordinateForSlidersSearchViewController:(SHSlidersSearchViewController *)vc;
- (CLLocationDistance)searchRadiusForSlidersSearchViewController:(SHSlidersSearchViewController *)vc;

@end
