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

- (void)footerNavigationViewControllerDidRequestSpots:(SHMapFooterNavigationViewController *)vc;
- (void)footerNavigationViewControllerDidRequestSpecials:(SHMapFooterNavigationViewController *)vc;
- (void)footerNavigationViewControllerDidRequestBeers:(SHMapFooterNavigationViewController *)vc;
- (void)footerNavigationViewControllerDidRequestCocktails:(SHMapFooterNavigationViewController *)vc;
- (void)footerNavigationViewControllerDidRequestWines:(SHMapFooterNavigationViewController *)vc;

@end
