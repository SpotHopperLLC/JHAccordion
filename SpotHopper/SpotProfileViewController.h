//
//  SpotProfileViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 2/20/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseViewController.h"

#import "SpotModel.h"
#import "CheckInModel.h"

@interface SpotProfileViewController : BaseViewController

@property (nonatomic, strong) SpotModel *spot;
@property (nonatomic, strong) CheckInModel *checkIn;
@property (nonatomic, assign) BOOL isCheckin;

@end
