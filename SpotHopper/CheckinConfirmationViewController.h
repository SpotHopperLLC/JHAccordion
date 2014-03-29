//
//  CheckinConfirmationViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/28/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpotModel;

@protocol CheckinConfirmationViewControllerDelegate;

@interface CheckinConfirmationViewController : UIViewController

@property (nonatomic, strong) SpotModel *spot;
@property (nonatomic, assign) id<CheckinConfirmationViewControllerDelegate> delegate;

@end

@protocol CheckinConfirmationViewControllerDelegate <NSObject>

- (void)checkinConfirmationViewControllerClickedClose:(CheckinConfirmationViewController*)viewController;
- (void)checkinConfirmationViewControllerClickedDrinkList:(CheckinConfirmationViewController*)viewController;
- (void)checkinConfirmationViewControllerClickedFullMenu:(CheckinConfirmationViewController*)viewController;

@end