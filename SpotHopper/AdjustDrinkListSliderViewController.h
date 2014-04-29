//
//  AdjustDrinkListSliderViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseViewController.h"

@class DrinkListModel, SpotModel, CLLocation;

@protocol AdjustDrinkSliderListSliderViewControllerDelegate;

@interface AdjustDrinkListSliderViewController : BaseViewController

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) SpotModel *spot;
@property (nonatomic, weak) id<AdjustDrinkSliderListSliderViewControllerDelegate> delegate;

- (void)resetForm;

- (void)openSection:(NSInteger)section;

@end

@protocol AdjustDrinkSliderListSliderViewControllerDelegate <NSObject>

-(void)adjustDrinkSliderListSliderViewControllerDelegateClickClose:(AdjustDrinkListSliderViewController*)viewController;
-(void)adjustDrinkSliderListSliderViewControllerDelegate:(AdjustDrinkListSliderViewController*)viewController createdDrinkList:(DrinkListModel*)spotList;

@end