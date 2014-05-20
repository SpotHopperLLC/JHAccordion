//
//  SHMapFooterNavigationViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/16/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

@protocol SHMapFooterNavigationDelegate;

@interface SHMapFooterNavigationViewController : BaseViewController

@property (weak, nonatomic) id<SHMapFooterNavigationDelegate> delegate;

@end

@protocol SHMapFooterNavigationDelegate <NSObject>

@optional

- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc spotsButtonTapped:(id)sender;
- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc specialsButtonTapped:(id)sender;
- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc beersButtonTapped:(id)sender;
- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc cocktailsButtonTapped:(id)sender;
- (void)footerNavigationViewController:(SHMapFooterNavigationViewController *)vc winesButtonTapped:(id)sender;

@end
