//
//  SpecialsCollectionViewManager.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/20/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SHBaseCollectionViewManager.h"

@protocol SHSpecialsCollectionViewManagerDelegate;

@class SpotModel;

@interface SHSpecialsCollectionViewManager : SHBaseCollectionViewManager <UICollectionViewDataSource, UICollectionViewDelegate>

- (void)updateSpots:(NSArray *)spots;

- (void)changeIndex:(NSUInteger)index;

- (void)changeSpot:(SpotModel *)spot;

- (UICollectionViewCell *)cellForViewInCollectionViewCell:(UIView *)view;

- (NSUInteger)indexForViewInCollectionViewCell:(UIView *)view;

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath;

- (SpotModel *)spotAtIndex:(NSUInteger)index;

- (BOOL)hasPrevious;

- (BOOL)hasNext;

- (void)goPrevious;

- (void)goNext;

@end

@protocol SHSpecialsCollectionViewManagerDelegate <SHBaseCollectionViewManagerDelegate>

@optional

- (void)specialsCollectionViewManager:(SHSpecialsCollectionViewManager *)manager didChangeToSpotAtIndex:(NSUInteger)index;
- (void)specialsCollectionViewManager:(SHSpecialsCollectionViewManager *)manager didSelectSpotAtIndex:(NSUInteger)index;

@end