//
//  SHMenuAdminLoginViewController.h
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 7/2/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"

@protocol SHMenuAdminLoginDelegate;

@interface SHMenuAdminLoginViewController : BaseViewController

@property (nonatomic, weak) id<SHMenuAdminLoginDelegate> delegate;

@end

@protocol SHMenuAdminLoginDelegate <NSObject>

- (void)loginDidFinish:(SHMenuAdminLoginViewController *)loginViewController;

@end
