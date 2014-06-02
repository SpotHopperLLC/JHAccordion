//
//  BaseSlidersSearchTableViewManager.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/23/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DrinkListModel;
@class ErrorModel;

@protocol SHSlidersSearchTableViewManagerDelegate;

@interface SHSlidersSearchTableViewManager : NSObject <UITableViewDataSource, UITableViewDelegate>

- (void)prefetchData;

- (void)prepareForMode:(SHMode)mode;

- (void)prepareTableViewForDrinkType:(NSString *)drinkTypeName;

- (void)prepareTableViewForDrinkType:(NSString *)drinkTypeName andWineSubType:(NSString *)wineSubTypeName;

- (void)fetchDrinkListResultsWithCompletionBlock:(void (^)(DrinkListModel *drinkListModel, ErrorModel *errorModel))completionBlock;

@end

@protocol SHSlidersSearchTableViewManagerDelegate <NSObject>

@optional

- (void)slidersSearchTableViewManagerDidChangeSlider:(SHSlidersSearchTableViewManager *)manager;

@end