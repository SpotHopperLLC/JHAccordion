//
//  SHMenuAdminAddNewCocktailViewControllerViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 11/11/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

#import "DrinkModel.h"

@protocol SHMenuAdminAddNewCocktailDelegate;

@interface SHMenuAdminAddNewCocktailViewController : BaseViewController

@property (weak, nonatomic) id<SHMenuAdminAddNewCocktailDelegate> delegate;

@end

@protocol SHMenuAdminAddNewCocktailDelegate <NSObject>

- (void)addNewCocktailViewControllerDidCancel:(SHMenuAdminAddNewCocktailViewController *)vc;

- (void)addNewCocktailViewController:(SHMenuAdminAddNewCocktailViewController *)vc didCreateDrink:(DrinkModel *)drink;

@end