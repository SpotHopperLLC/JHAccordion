//
//  CheckinViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/27/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseViewController.h"

@class SpotModel;
@class CheckInModel;

@protocol CheckinViewControllerDelegate;

@interface CheckinViewController : BaseViewController

@property (nonatomic, weak) id<CheckinViewControllerDelegate> delegate;

@end

@protocol CheckinViewControllerDelegate <NSObject>

- (void)checkinViewController:(CheckinViewController*)viewController checkedIn:(CheckInModel*)checkIn;

@end