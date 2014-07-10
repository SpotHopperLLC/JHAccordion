//
//  SHSidebarViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/19/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

@protocol SHSidebarDelegate;

@interface SHSidebarViewController : BaseViewController

@property (nonatomic, weak) IBOutlet id<SHSidebarDelegate> delegate;

@end

@protocol SHSidebarDelegate <NSObject>

@optional

- (void)sidebarViewControllerDidRequestSearch:(SHSidebarViewController*)vc;
- (void)sidebarViewControllerDidRequestClose:(SHSidebarViewController*)vc;
- (void)sidebarViewControllerDidRequestReviews:(SHSidebarViewController*)vc;
- (void)sidebarViewControllerDidRequestCheckin:(SHSidebarViewController*)vc;
- (void)sidebarViewControllerDidRequestGiveProps:(SHSidebarViewController*)vc;
- (void)sidebarViewControllerDidRequestAccount:(SHSidebarViewController*)vc;
- (void)sidebarViewControllerDidRequestLogin:(SHSidebarViewController*)vc;

@end
