//
//  CheckinViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/27/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseViewController.h"

@class SpotModel;

@protocol CheckinViewControllerDelegate;

@interface CheckinViewController : BaseViewController

@property (nonatomic, assign) id<CheckinViewControllerDelegate> delegate;

@end

@protocol CheckinViewControllerDelegate <NSObject>

- (void)checkinViewController:(CheckinViewController*)viewController checkedInToSpot:(SpotModel*)spot;

@end