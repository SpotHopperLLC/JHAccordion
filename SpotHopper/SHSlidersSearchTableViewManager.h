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
@class ErrorModel;

@protocol SHSlidersSearchTableViewManagerDelegate;

@interface SHSlidersSearchTableViewManager : NSObject <UITableViewDataSource, UITableViewDelegate>

- (void)prepare;

- (void)prepareForMode:(SHMode)mode;

- (void)prepareTableViewForDrinkType:(NSString *)drinkTypeName;

- (void)prepareTableViewForDrinkType:(NSString *)drinkTypeName andWineSubType:(NSString *)wineSubTypeName;

- (void)fetchSpotListResultsWithCompletionBlock:(void (^)(SpotListModel *spotListModel, SpotListRequest *request, ErrorModel *errorModel))completionBlock;

- (void)fetchDrinkListResultsWithCompletionBlock:(void (^)(DrinkListModel *drinkListModel, DrinkListRequest *request, ErrorModel *errorModel))completionBlock;

@end

@protocol SHSlidersSearchTableViewManagerDelegate <NSObject>

@required

- (UIStoryboard *)slidersSearchTableViewManagerStoryboard:(SHSlidersSearchTableViewManager *)manager;

@optional

- (void)slidersSearchTableViewManagerDidChangeSlider:(SHSlidersSearchTableViewManager *)manager;


@end
