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
@class SpotModel;
@class ErrorModel;

#import <CoreLocation/CoreLocation.h>

@protocol SHSlidersSearchTableViewManagerDelegate;

@interface SHSlidersSearchTableViewManager : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (readonly, nonatomic) BOOL isCustomRequest;
@property (readonly, nonatomic) NSString *customListName;

- (void)prepare;

- (void)prepareForMode:(SHMode)mode;

- (void)prepareTableViewForDrinkType:(DrinkTypeModel *)drinkTypeName withCompletionBlock:(void (^)())completionBlock;

- (void)fetchSpotListResultsWithListName:(NSString *)listName withCompletionBlock:(void (^)(SpotListModel *spotListModel, SpotListRequest *request, ErrorModel *errorModel))completionBlock;

- (void)fetchDrinkListResultsWithListName:(NSString *)listName withCompletionBlock:(void (^)(DrinkListModel *drinkListModel, DrinkListRequest *request, ErrorModel *errorModel))completionBlock;

@end

@protocol SHSlidersSearchTableViewManagerDelegate <NSObject>

@required

- (UIStoryboard *)slidersSearchTableViewManagerStoryboard:(SHSlidersSearchTableViewManager *)manager;

@optional

- (void)slidersSearchTableViewManagerDidChangeSlider:(SHSlidersSearchTableViewManager *)manager;

- (void)slidersSearchTableViewManagerWillAnimate:(SHSlidersSearchTableViewManager *)manager;
- (void)slidersSearchTableViewManagerDidAnimate:(SHSlidersSearchTableViewManager *)manager;

- (void)slidersSearchTableViewManagerIsBusy:(SHSlidersSearchTableViewManager *)manager text:(NSString *)text;
- (void)slidersSearchTableViewManagerIsFree:(SHSlidersSearchTableViewManager *)manager;

- (SpotModel *)slidersSearchTableViewManagerScopedSpot:(SHSlidersSearchTableViewManager *)manager;

@required

- (CLLocationCoordinate2D)searchCoordinateForSlidersSearchTableViewManager:(SHSlidersSearchTableViewManager *)manager;
- (CLLocationDistance)searchRadiusForSlidersSearchTableViewManager:(SHSlidersSearchTableViewManager *)manager;

@end
