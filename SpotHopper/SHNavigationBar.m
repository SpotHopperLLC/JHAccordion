//
//  SHNavigationBar.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/30/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "SHNavigationBar.h"

@implementation SHNavigationBar

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setBackgroundImage:[UIImage alloc] forBarMetrics:UIBarMetricsDefault];
    [self setShadowImage:[[UIImage alloc] init]];
}

@end
