//
//  LocationChooserViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 2/19/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseViewController.h"

@class CLLocation;

@protocol LocationChooserViewControllerDelegate;

@interface LocationChooserViewController : BaseViewController

@property (nonatomic, strong) CLLocation *initialLocation;
@property (nonatomic, assign) id<LocationChooserViewControllerDelegate> delegate;

+ (LocationChooserViewController*)locationChooser;

@end

@protocol LocationChooserViewControllerDelegate <NSObject>

- (void)locationChooserViewController:(LocationChooserViewController*)viewController updateLocation:(CLLocation*)location;

@end
