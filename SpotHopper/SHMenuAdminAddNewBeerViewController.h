//
//  SHMenuAdminAddNewBeerViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 11/7/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

#import "DrinkModel.h"

@protocol SHMenuAdminAddNewBeerDelegate;

@interface SHMenuAdminAddNewBeerViewController : BaseViewController

@property (weak, nonatomic) id<SHMenuAdminAddNewBeerDelegate> delegate;

@end

@protocol SHMenuAdminAddNewBeerDelegate <NSObject>

- (void)addNewBeerViewControllerDidCancel:(SHMenuAdminAddNewBeerViewController *)vc;

- (void)addNewBeerViewController:(SHMenuAdminAddNewBeerViewController *)vc didCreateDrink:(DrinkModel *)drink;

@end