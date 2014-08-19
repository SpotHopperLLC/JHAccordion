//
//  SHBaseNavigationController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/21/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHBaseNavigationController.h"

@interface SHBaseNavigationController ()

@end

@implementation SHBaseNavigationController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.topViewController preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden {
    return [self.topViewController prefersStatusBarHidden];
}

@end
