//
//  SHCheckinCollectionViewManager.h
//  SpotHopper
//
//  Created by Brennan Stehling on 10/2/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SHBaseCollectionViewManager.h"

@class SpotListModel, SpotModel, CheckInModel;

@protocol SHCheckinCollectionViewManagerDelegate;

@interface SHCheckinCollectionViewManager : SHBaseCollectionViewManager <UICollectionViewDataSource, UICollectionViewDelegate>

- (void)setCheckin:(CheckInModel *)checkin andSpot:(SpotModel *)spot;

@end

@protocol SHCheckinCollectionViewManagerDelegate <SHBaseCollectionViewManagerDelegate>

// do nothing

@end
