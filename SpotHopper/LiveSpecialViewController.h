//
//  LiveSpecialViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/27/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LiveSpecialModel;

@protocol LiveSpecialViewControllerDelegate;

@interface LiveSpecialViewController : UIViewController

@property (nonatomic, strong) LiveSpecialModel *liveSpecial;
@property (nonatomic, strong) id<LiveSpecialViewControllerDelegate> delegate;

@end

@protocol LiveSpecialViewControllerDelegate <NSObject>

- (void)liveSpecialViewControllerClickedClose:(LiveSpecialViewController*)viewController;
- (void)liveSpecialViewControllerClickedShare:(LiveSpecialViewController*)viewController;

@end