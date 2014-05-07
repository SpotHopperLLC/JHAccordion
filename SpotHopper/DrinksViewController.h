//
//  DrinksViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 4/29/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

@class SpotModel;

@protocol DrinksViewControllerDelegate;

@interface DrinksViewController : BaseViewController

@property (nonatomic, weak) id<DrinksViewControllerDelegate> delegate;

@end

@protocol DrinksViewControllerDelegate <NSObject>

@end
