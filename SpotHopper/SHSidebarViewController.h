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

- (void)sidebarViewController:(SHSidebarViewController*)vc didTapSearchTextField:(id)sender;

- (void)sidebarViewController:(SHSidebarViewController*)vc closeButtonTapped:(id)sender;
- (void)sidebarViewController:(SHSidebarViewController*)vc spotsButtonTapped:(id)sender;
- (void)sidebarViewController:(SHSidebarViewController*)vc drinksButtonTapped:(id)sender;
- (void)sidebarViewController:(SHSidebarViewController*)vc specialsButtonTapped:(id)sender;
- (void)sidebarViewController:(SHSidebarViewController*)vc reviewButtonTapped:(id)sender;
- (void)sidebarViewController:(SHSidebarViewController*)vc checkinButtonTapped:(id)sender;
- (void)sidebarViewController:(SHSidebarViewController*)vc accountButtonTapped:(id)sender;

@end
