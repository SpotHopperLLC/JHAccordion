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

- (NSUInteger)indexForViewInCollectionViewCell:(UIView *)view;

- (BOOL)hasPrevious;

- (BOOL)hasNext;

- (void)goPrevious;

- (void)goNext;

@end

@protocol SHSpecialsCollectionViewManagerDelegate <NSObject>

@optional

- (void)specialsCollectionViewManager:(SHSpecialsCollectionViewManager *)manager didChangeToSpotAtIndex:(NSUInteger)index;
- (void)specialsCollectionViewManager:(SHSpecialsCollectionViewManager *)manager didSelectSpotAtIndex:(NSUInteger)index;

@end