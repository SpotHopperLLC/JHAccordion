//
//  ShareViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/28/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ShareViewControllerShareUnknown = 0,
    ShareViewControllerShareCheckin = 1,
    ShareViewControllerShareSpecial = 2
} ShareViewControllerShareType;

@class SpotModel;

@protocol ShareViewControllerDelegate;

@interface ShareViewController : UIViewController

@property (nonatomic, strong) SpotModel *spot;
@property (nonatomic, assign) ShareViewControllerShareType shareType;
@property (nonatomic, weak) id<ShareViewControllerDelegate> delegate;

@end

@protocol ShareViewControllerDelegate <NSObject>

- (void)shareViewControllerClickedClose:(ShareViewController*)viewController;
- (void)shareViewControllerDidFinish:(ShareViewController*)viewController;

@end