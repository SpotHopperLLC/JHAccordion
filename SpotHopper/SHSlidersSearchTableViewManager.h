//
//  BaseSlidersSearchTableViewManager.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/23/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DrinkListRequest;
@class DrinkListModel;
@class SpotListRequest;
@class SpotListModel;
@class DrinkTypeModel;
@class DrinkSubTypeModel;
@class ErrorModel;

#import <CoreLocation/CoreLocation.h>

@protocol SHSlidersSearchTableViewManagerDelegate;

@interface SHSlidersSearchTableViewManager : NSObject <UITableViewDataSource, UITableViewDelegate>

- (void)prepare;

- (void)prepareForMode:(SHMode)mode;

- (void)prepareTableViewForDrinkType:(DrinkTypeModel *)drinkTypeName;

//- (void)prepareTableViewForDrinkType:(DrinkTypeModel *)drinkTypeName andDrinkSubType:(DrinkSubTypeModel *)drinkSubTypeName;

- (void)fetchSpotListResultsWithCompletionBlock:(void (^)(SpotListModel *spotListModel, SpotListRequest *request, ErrorModel *errorModel))completionBlock;

- (void)fetchDrinkListResultsWithCompletionBlock:(void (^)(DrinkListModel *drinkListModel, DrinkListRequest *request, ErrorModel *errorModel))completionBlock;

@end

@protocol SHSlidersSearchTableViewManagerDelegate <NSObject>

@required

- (UIStoryboard *)slidersSearchTableViewManagerStoryboard:(SHSlidersSearchTableViewManager *)manager;

@optional

- (void)slidersSearchTableViewManagerDidChangeSlider:(SHSlidersSearchTableViewManager *)manager;

// TODO: use these methods to indicate when the sliders search screen is animating to avoid performance issues with the blurred background
- (void)slidersSearchTableViewManagerWillAnimate:(SHSlidersSearchTableViewManager *)manager;
- (void)slidersSearchTableViewManagerDidAnimate:(SHSlidersSearchTableViewManager *)manager;

- (void)slidersSearchTableViewManagerIsBusy:(SHSlidersSearchTableViewManager *)manager;
- (void)slidersSearchTableViewManagerIsFree:(SHSlidersSearchTableViewManager *)manager;

@required

- (CLLocationCoordinate2D)searchCoordinateForSlidersSearchTableViewManager:(SHSlidersSearchTableViewManager *)manager;
- (CLLocationDistance)searchRadiusForSlidersSearchTableViewManager:(SHSlidersSearchTableViewManager *)manager;

@end
