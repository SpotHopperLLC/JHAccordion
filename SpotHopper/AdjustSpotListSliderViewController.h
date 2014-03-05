//
//  AdjustSpotListSliderViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/5/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseViewController.h"

@protocol AdjustSliderListSliderViewControllerDelegate;

@class SpotListModel;

@interface AdjustSpotListSliderViewController : BaseViewController

@property (nonatomic, assign) id<AdjustSliderListSliderViewControllerDelegate> delegate;

@end

@protocol AdjustSliderListSliderViewControllerDelegate <NSObject>

-(void)adjustSliderListSliderViewControllerDelegateClickClose:(AdjustSpotListSliderViewController*)viewController;
-(void)adjustSliderListSliderViewControllerDelegate:(AdjustSpotListSliderViewController*)viewController createdSpotList:(SpotListModel*)spotList;

@end