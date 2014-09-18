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

- (void)displaySingleSpot:(SpotModel *)spot;

- (void)displaySingleDrink:(DrinkModel *)drink;

- (void)expandedViewDidAppear;

- (void)expandedViewDidDisappear;

@end

@protocol SHMapOverlayCollectionDelegate <NSObject>

@optional

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didChangeToSpotAtIndex:(NSUInteger)index;
- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didSelectSpotAtIndex:(NSUInteger)index;
- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didRequestShareSpecialForSpotAtIndex:(NSUInteger)index;
- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didChangeToDrinkAtIndex:(NSUInteger)index;
- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didSelectDrinkAtIndex:(NSUInteger)index;

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc displaySpot:(SpotModel *)spot;
- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc displayDrink:(DrinkModel *)drink;

// support for pullup UI

@required

- (UIView *)mapOverlayCollectionViewControllerPrimaryView:(SHMapOverlayCollectionViewController *)mgr;

- (UITableView *)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)mgr embedTableViewInSuperview:(UIView *)superview;

@optional

- (void)mapOverlayCollectionViewControllerDidTapHeader:(SHMapOverlayCollectionViewController *)mgr;

- (void)mapOverlayCollectionViewControllerShouldCollapse:(SHMapOverlayCollectionViewController *)mgr;

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didMoveToPoint:(CGPoint)point;

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didStopMovingAtPoint:(CGPoint)point withVelocity:(CGPoint)velocity;

@end
