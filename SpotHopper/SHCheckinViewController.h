//
//  SHCheckinViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 10/1/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

@class SpotModel;

@protocol SHCheckinViewControllerDelegate;

@interface SHCheckinViewController : BaseViewController

@property (weak, nonatomic) id<SHCheckinViewControllerDelegate> delegate;

@end

@protocol SHCheckinViewControllerDelegate <NSObject>

@optional

- (void)checkInViewControllerCancelButtonTapped:(SHCheckinViewController *)vc;

- (void)checkInViewController:(SHCheckinViewController *)vc checkInAtSpot:(SpotModel *)spot;

@end
