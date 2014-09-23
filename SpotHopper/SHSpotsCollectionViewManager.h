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
- (SpotModel *)spotAtIndex:(NSUInteger)index;

- (NSUInteger)indexForViewInCollectionViewCell:(UIView *)view;

- (BOOL)hasPrevious;
- (BOOL)hasNext;

- (void)goPrevious;
- (void)goNext;

@end

@protocol SHSpotsCollectionViewManagerDelegate <SHBaseCollectionViewManagerDelegate>

@optional

- (void)spotsCollectionViewManager:(SHSpotsCollectionViewManager *)manager didChangeToSpotAtIndex:(NSUInteger)index count:(NSUInteger)count;
- (void)spotsCollectionViewManager:(SHSpotsCollectionViewManager *)manager didSelectSpotAtIndex:(NSUInteger)index;

- (void)spotsCollectionViewManager:(SHSpotsCollectionViewManager *)manager displaySpot:(SpotModel *)spot;

@end
