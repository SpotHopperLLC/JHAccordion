//
//  LiveSpecialViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/27/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"

@class LiveSpecialModel;

@protocol LiveSpecialViewControllerDelegate;

@interface LiveSpecialViewController : BaseViewController

@property (nonatomic, strong) LiveSpecialModel *liveSpecial;
@property (nonatomic, assign) BOOL needToFetch;
@property (nonatomic, strong) id<LiveSpecialViewControllerDelegate> delegate;

@end

@protocol LiveSpecialViewControllerDelegate <NSObject>

- (void)liveSpecialViewControllerClickedClose:(LiveSpecialViewController*)viewController;
- (void)liveSpecialViewControllerClickedShare:(LiveSpecialViewController*)viewController;

@end
