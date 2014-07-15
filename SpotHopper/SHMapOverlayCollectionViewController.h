//
//  SHMapOverlayCollectionViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/16/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

#import "SHSpotsCollectionViewManager.h"
#import "SHSpecialsCollectionViewManager.h"
#import "SHDrinksCollectionViewManager.h"

@class SpotListModel;
@class DrinkListModel;
@class SpotModel;
@class DrinkModel;

@protocol SHMapOverlayCollectionDelegate;

@interface SHMapOverlayCollectionViewController : BaseViewController

@property (weak, nonatomic) id<SHMapOverlayCollectionDelegate> delegate;

- (void)displaySpotList:(SpotListModel *)spotList;

- (void)displaySpot:(SpotModel *)spot;

- (void)displayDrink:(DrinkModel *)drink;

- (void)displaySpecialsForSpots:(NSArray *)spots;

- (void)displayDrinklist:(DrinkListModel *)drinklist;

@end

@protocol SHMapOverlayCollectionDelegate <NSObject>

@optional

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didChangeToSpotAtIndex:(NSUInteger)index;
- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didSelectSpotAtIndex:(NSUInteger)index;

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didChangeToDrinkAtIndex:(NSUInteger)index;
- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didSelectDrinkAtIndex:(NSUInteger)index;

@end
