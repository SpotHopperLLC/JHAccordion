//
//  SHAdjustSpotListSliderViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/14/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

@protocol SHAdjustSliderListSliderDelegate;

@class SpotListModel, CLLocation;

@interface SHAdjustSpotListSliderViewController : BaseViewController

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, weak) id<SHAdjustSliderListSliderDelegate> delegate;
@property (nonatomic, strong) SpotListModel *spotListModel;

@end

@protocol SHAdjustSliderListSliderDelegate <NSObject>

@optional

-(void)adjustSpotListSliderViewController:(SHAdjustSpotListSliderViewController*)vc didCreateSpotList:(SpotListModel*)spotList;

@end
