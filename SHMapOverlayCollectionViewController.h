//
//  SHMapOverlayCollectionViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/16/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

#import "SHSpotsCollectionViewManager.h"

@class SpotListModel;

@protocol SHMapOverlayCollectionDelegate;

@interface SHMapOverlayCollectionViewController : BaseViewController

@property (weak, nonatomic) id<SHMapOverlayCollectionDelegate> delegate;

- (void)displaySpotList:(SpotListModel *)spotList;

- (void)displaySpot:(SpotModel *)spot;

@end

@protocol SHMapOverlayCollectionDelegate <NSObject>

@optional

- (void)mapOverlayCollectionViewController:(SHMapOverlayCollectionViewController *)vc didChangeToSpotAtIndex:(NSUInteger)index;

@end
