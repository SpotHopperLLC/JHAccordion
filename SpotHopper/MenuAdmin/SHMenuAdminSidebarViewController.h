//
//  SidebarViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseViewController.h"

@class SpotModel;
@class UserModel;

@protocol SHMenuAdminSidebarViewControllerDelegate;

@interface SHMenuAdminSidebarViewController : BaseViewController

@property (nonatomic, weak) id<SHMenuAdminSidebarViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *spots;

- (void)refreshSidebar;

@end

@protocol SHMenuAdminSidebarViewControllerDelegate <NSObject>

- (void)closeButtonTapped:(SHMenuAdminSidebarViewController*)sidebarViewController;
- (void)spotTapped:(SHMenuAdminSidebarViewController*)sidebarViewController spot:(SpotModel*)spot;
- (void)viewAllSpotsTapped:(SHMenuAdminSidebarViewController*)sidebarViewController;
- (void)logoutTapped:(SHMenuAdminSidebarViewController*)sidebarViewController;

@end