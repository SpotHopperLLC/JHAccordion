//
//  SHLocationMenuBarViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/13/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

@protocol SHLocationMenuBarDelegate;

@interface SHLocationMenuBarViewController : BaseViewController

@property (weak, nonatomic) id<SHLocationMenuBarDelegate> delegate;

- (void)updateLocationTitle:(NSString *)locationTitle;

@end

@protocol SHLocationMenuBarDelegate <NSObject>

@optional

- (void)locationMenuBarViewControllerDidRequestLocationChange:(SHLocationMenuBarViewController *)vc;

@end