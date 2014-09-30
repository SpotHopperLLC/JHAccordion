//
//  SHSpotDetailsViewController.h
//  SpotHopper
//
//  Created by Tracee Pettigrew on 5/29/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotModel.h"

#import "BaseViewController.h"

@interface SHSpotProfileViewController : BaseViewController

//spot model which details will be shown
@property (weak, nonatomic) SpotModel *spot;

@end
