//
//  SHMapFooterNavigationViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/16/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

@protocol SHSpotDetailFooterNavigationDelegate;

@interface SHSpotDetailFooterNavigationViewController : BaseViewController

@property (weak, nonatomic) id<SHSpotDetailFooterNavigationDelegate> delegate;

@end

@protocol SHSpotDetailFooterNavigationDelegate <NSObject>

@optional

- (void)footerNavigationViewController:(SHSpotDetailFooterNavigationViewController *)vc findSimilarButtonTapped:(id)sender;
- (void)footerNavigationViewController:(SHSpotDetailFooterNavigationViewController *)vc spotReviewButtonTapped:(id)sender;
- (void)footerNavigationViewController:(SHSpotDetailFooterNavigationViewController *)vc drinkMenuButtonTapped:(id)sender;

@end