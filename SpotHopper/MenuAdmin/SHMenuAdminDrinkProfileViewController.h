//
//  SHSpotDetailsViewController.h
//  SpotHopper
//
//  Created by Tracee Pettigrew on 5/29/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrinkModel.h"

#import "BaseViewController.h"

@interface SHMenuAdminDrinkProfileViewController : BaseViewController

//drink model which details will be shown
@property (strong,nonatomic) DrinkModel *drink;

@end
