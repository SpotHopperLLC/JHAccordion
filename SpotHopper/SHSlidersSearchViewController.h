//
//  SHSearchViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/22/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

@class DrinkListModel;

@protocol SHSlidersSearchDelegate;

@interface SHSlidersSearchViewController : BaseViewController

@property (weak, nonatomic) id<SHSlidersSearchDelegate> delegate;

@property (readonly, nonatomic) DrinkListModel *drinkListModel;

- (void)prepareForMode:(SHMode)mode;

@end

@protocol SHSlidersSearchDelegate <NSObject>

@optional

- (void)slidersSearchViewController:(SHSlidersSearchViewController *)vc didPrepareDrinklist:(DrinkListModel *)drinklist forMode:(SHMode)mode;

@end
