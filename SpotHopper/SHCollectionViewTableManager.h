//
//  SHCollectionViewTableManager.h
//  SpotHopper
//
//  Created by Brennan Stehling on 9/17/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpotModel, DrinkModel;

@protocol SHCollectionViewTableManagerDelegate;

@interface SHCollectionViewTableManager : NSObject

@property (weak, nonatomic) id<SHCollectionViewTableManagerDelegate> delegate;

- (void)manageTableView:(UITableView *)tableView forTodaysSpecialAtSpot:(SpotModel *)spot;

- (void)manageTableView:(UITableView *)tableView forSpot:(SpotModel *)spot;

- (void)manageTableView:(UITableView *)tableView forDrink:(DrinkModel *)drink;

- (void)prepareForReuse;

@end

@protocol SHCollectionViewTableManagerDelegate <NSObject>

@required

- (void)collectionViewTableManagerShouldCollapse:(SHCollectionViewTableManager *)mgr;

@optional

- (void)collectionViewTableManager:(SHCollectionViewTableManager *)mgr displaySpot:(SpotModel *)spot;

- (void)collectionViewTableManager:(SHCollectionViewTableManager *)mgr displayDrink:(DrinkModel *)drink;

@end