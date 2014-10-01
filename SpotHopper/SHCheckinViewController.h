//
//  SHCheckinViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 10/1/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

@protocol SHCheckinViewControllerDelegate;

@interface SHCheckinViewController : BaseViewController

@property (weak, nonatomic) id<SHCheckinViewControllerDelegate> delegate;

@end

@protocol SHCheckinViewControllerDelegate <NSObject>

- (void)checkInViewControllerCancelButtonTapped:(SHCheckinViewController *)vc;

@end
