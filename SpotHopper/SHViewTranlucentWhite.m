//
//  SHViewTranlucentWhite.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHViewTranlucentWhite.h"

#import <QuartzCore/QuartzCore.h>

@implementation SHViewTranlucentWhite

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
    [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_bar_background_ios6"]]];
    
    CAGradientLayer *topShadow = [CAGradientLayer layer];
    topShadow.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 10);
    topShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.1f] CGColor], (id)[[UIColor colorWithWhite:0.0 alpha:0.0f] CGColor], nil];
    [self.layer insertSublayer:topShadow atIndex:0];
}

@end
