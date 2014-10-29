//
//  IndexPathViewPair.m
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 7/22/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import "SHMenuAdminIndexPathViewPair.h"

@implementation SHMenuAdminIndexPathViewPair

- (instancetype)init:(NSIndexPath*)indexPath view:(SHMenuAdminPriceSizeRowContainerView*)container {
    if (self) {
        _indexPath = indexPath;
        _container = container;
    }
    return self;
}

@end
