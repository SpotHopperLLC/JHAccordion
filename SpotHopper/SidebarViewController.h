//
//  SidebarViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseViewController.h"

#import <JHSidebar/JHSidebarViewController.h>

@protocol SidebarViewControllerDelegate;

@interface SidebarViewController : BaseViewController<JHSidebarDelegate>

@property (nonatomic, assign) id<SidebarViewControllerDelegate> delegate;

@end

@protocol SidebarViewControllerDelegate <NSObject>

- (void)sidebarViewControllerClickedSearch:(SidebarViewController*)sidebarViewController;
- (void)sidebarViewControllerClickedSpots:(SidebarViewController*)sidebarViewController;
- (void)sidebarViewControllerClickedDrinks:(SidebarViewController*)sidebarViewController;
- (void)sidebarViewControllerClickedSpecials:(SidebarViewController*)sidebarViewController;
- (void)sidebarViewControllerClickedReview:(SidebarViewController*)sidebarViewController;
- (void)sidebarViewControllerClickedCheckin:(SidebarViewController*)sidebarViewController;
- (void)sidebarViewControllerClickedAccount:(SidebarViewController*)sidebarViewController;

@end