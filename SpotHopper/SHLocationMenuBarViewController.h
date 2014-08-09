//
//  SHLocationMenuBarViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/13/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

@protocol SHLocationMenuBarDelegate;

@class SpotModel;

@interface SHLocationMenuBarViewController : BaseViewController

@property (weak, nonatomic) id<SHLocationMenuBarDelegate> delegate;

- (void)updateLocationTitle:(NSString *)locationTitle;

- (void)selectSpot:(SpotModel *)spot withCompletionBlock:(void (^)())completionBlock;
- (void)deselectSpot:(SpotModel *)spot withCompletionBlock:(void (^)())completionBlock;

- (void)scopeToSpot:(SpotModel *)spot withCompletionBlock:(void (^)())completionBlock;
- (void)descopeFromSpot:(SpotModel *)spot withCompletionBlock:(void (^)())completionBlock;

- (void)dismissSearch:(BOOL)animated withCompletionBlock:(void (^)())completionBlock;

@end

@protocol SHLocationMenuBarDelegate <NSObject>

@optional

- (void)locationMenuBarViewController:(SHLocationMenuBarViewController *)vc didScopeToSpot:(SpotModel *)spot;

- (void)locationMenuBarViewControllerDidDescope:(SHLocationMenuBarViewController *)vc;

- (void)locationMenuBarViewControllerDidStartSearch:(SHLocationMenuBarViewController *)vc;

- (void)locationMenuBarViewController:(SHLocationMenuBarViewController *)vc didSearchWithText:(NSString *)searchText;

- (void)locationMenuBarViewControllerDidCancelSearch:(SHLocationMenuBarViewController *)vc;

@end
