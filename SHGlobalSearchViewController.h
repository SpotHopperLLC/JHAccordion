//
//  SHGlobalSearchViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 7/26/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

@class DrinkModel, SpotModel;

@protocol SHGlobalSearchViewControllerDelegate;

@interface SHGlobalSearchViewController : BaseViewController

@property (weak, nonatomic) id <SHGlobalSearchViewControllerDelegate> delegate;

- (void)scheduleSearchWithText:(NSString *)text;

- (void)clearSearch;

- (void)cancelSearch;

- (void)adjustForKeyboardHeight:(CGFloat)height duration:(NSTimeInterval)duration;

@end

@protocol SHGlobalSearchViewControllerDelegate <NSObject>

@required

- (void)globalSearchViewController:(SHGlobalSearchViewController *)vc didSelectSpot:(SpotModel *)spot;
- (void)globalSearchViewController:(SHGlobalSearchViewController *)vc didSelectDrink:(DrinkModel *)drink;

- (void)globalSearchViewController:(SHGlobalSearchViewController *)vc didSelectSimilarToSpot:(SpotModel *)spot;
- (void)globalSearchViewController:(SHGlobalSearchViewController *)vc didSelectSimilarToDrink:(DrinkModel *)drink;

- (void)globalSearchViewControllerDidRequestReview:(SHGlobalSearchViewController *)vc;

- (void)globalSearchViewControllerStartedSearching:(SHGlobalSearchViewController *)vc;
- (void)globalSearchViewControllerStoppedSearching:(SHGlobalSearchViewController *)vc;

@end
