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

- (void)selectSpot:(SpotModel *)spot;

- (void)deselectSpot:(SpotModel *)spot;

- (void)selectSpotDrinkListForSpot:(SpotModel *)spot;

- (void)deselectSpotDrinkList;

@end

@protocol SHLocationMenuBarDelegate <NSObject>

@optional

- (void)locationMenuBarViewControllerDidRequestLocationChange:(SHLocationMenuBarViewController *)vc;

- (void)locationMenuBarViewController:(SHLocationMenuBarViewController *)vc didSelectSpot:(SpotModel *)spot;

- (void)locationMenuBarViewController:(SHLocationMenuBarViewController *)vc didDeselectSpot:(SpotModel *)spot;


@end
