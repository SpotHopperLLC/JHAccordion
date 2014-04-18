//
//  CheckinConfirmationViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/28/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"

@class SpotModel;

@protocol CheckinConfirmationViewControllerDelegate;

@interface CheckinConfirmationViewController : BaseViewController

@property (nonatomic, strong) SpotModel *spot;
@property (nonatomic, weak) id<CheckinConfirmationViewControllerDelegate> delegate;

@end

@protocol CheckinConfirmationViewControllerDelegate <NSObject>

- (void)checkinConfirmationViewControllerClickedClose:(CheckinConfirmationViewController*)viewController;
- (void)checkinConfirmationViewControllerClickedDrinkList:(CheckinConfirmationViewController*)viewController;
- (void)checkinConfirmationViewControllerClickedFullMenu:(CheckinConfirmationViewController*)viewController;

@end