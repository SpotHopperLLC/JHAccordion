//
//  SHDrinksCollectionViewManager.h
//  SpotHopper
//
//  Created by Brennan Stehling on 6/2/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHBaseCollectionViewManager.h"

@class DrinkListModel;
@class DrinkModel;

@protocol SHDrinksCollectionViewManagerDelegate;

@interface SHDrinksCollectionViewManager : SHBaseCollectionViewManager <UICollectionViewDataSource, UICollectionViewDelegate>

- (void)updateDrinkList:(DrinkListModel *)drinkList;
- (void)changeIndex:(NSUInteger)index;
- (void)changeDrink:(DrinkModel *)drink;

- (NSUInteger)indexForViewInCollectionViewCell:(UIView *)view;

- (BOOL)hasPrevious;
- (BOOL)hasNext;

- (void)goPrevious;
- (void)goNext;

@end

@protocol SHDrinksCollectionViewManagerDelegate <NSObject>

@optional


- (void)drinksCollectionViewManager:(SHDrinksCollectionViewManager *)manager didChangeToDrinkAtIndex:(NSUInteger)index;
- (void)drinksCollectionViewManager:(SHDrinksCollectionViewManager *)manager didSelectDrinkAtIndex:(NSUInteger)index;

@end
