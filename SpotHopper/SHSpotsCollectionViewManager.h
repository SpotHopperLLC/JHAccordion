//
//  SHSpotsCollectionViewManager.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/16/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SHBaseCollectionViewManager.h"

@protocol SHSpotsCollectionViewManagerDelegate;

@class SpotListModel;
@class SpotModel;

@interface SHSpotsCollectionViewManager : SHBaseCollectionViewManager <UICollectionViewDataSource, UICollectionViewDelegate>

- (void)updateSpotList:(SpotListModel *)spotList;
- (void)changeIndex:(NSUInteger)index;
- (void)changeSpot:(SpotModel *)spot;

- (NSUInteger)indexForViewInCollectionViewCell:(UIView *)view;

- (BOOL)hasPrevious;
- (BOOL)hasNext;

- (void)goPrevious;
- (void)goNext;

@end

@protocol SHSpotsCollectionViewManagerDelegate <NSObject>

@optional

- (void)spotsCollectionViewManager:(SHSpotsCollectionViewManager *)manager didChangeToSpotAtIndex:(NSUInteger)index;
- (void)spotsCollectionViewManager:(SHSpotsCollectionViewManager *)manager didSelectSpotAtIndex:(NSUInteger)index;

@end