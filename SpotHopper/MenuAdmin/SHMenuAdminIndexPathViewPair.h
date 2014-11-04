//
//  IndexPathViewPair.h
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 7/22/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SHMenuAdminPriceSizeRowContainerView.h"

@interface SHMenuAdminIndexPathViewPair : NSObject

@property (nonatomic, readonly) NSIndexPath *indexPath;
@property (nonatomic, readonly) SHMenuAdminPriceSizeRowContainerView *container;

- (instancetype)init:(NSIndexPath*)indexPath view:(SHMenuAdminPriceSizeRowContainerView*)container;

@end
