//
//  SHMenuAdminAddNewWineViewControllerViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 11/11/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

#import "DrinkModel.h"

@protocol SHMenuAdminAddNewWineDelegate;

@interface SHMenuAdminAddNewWineViewController : BaseViewController

@property (weak, nonatomic) id<SHMenuAdminAddNewWineDelegate> delegate;

@end

@protocol SHMenuAdminAddNewWineDelegate <NSObject>

- (void)addNewWineViewControllerDidCancel:(SHMenuAdminAddNewWineViewController *)vc;

- (void)addNewWineViewController:(SHMenuAdminAddNewWineViewController *)vc didCreateDrink:(DrinkModel *)drink;

@end