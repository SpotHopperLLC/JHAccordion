//
//  UIStyleSupport.m
//  ecn-ios
//
//  Created by Tracee Pettigrew on 2/20/14.
//  Copyright (c) 2014 Tracee Pettigrew. All rights reserved.
//

#import "SHMenuAdminStyleSupport.h"


@implementation SHMenuAdminStyleSupport

+ (SHMenuAdminStyleSupport *)sharedInstance {
    static SHMenuAdminStyleSupport *constantInstance = nil;

    if (constantInstance == nil)
    {
        constantInstance = [[[self class]alloc]init];
        [constantInstance setConstants];
    }
    return constantInstance;
}

- (void)setConstants {
    
    /**
     Background (light) orange = 241, 142, 108
     Highlight (dark) orange = 236, 100, 66
     Deep dark orange = 221, 128, 98
     Gray = 224, 224, 224
     */
    _LIGHT_ORANGE = [UIColor colorWithRed:241.0f/255.0f green:142.0f/255.0f blue:108.0f/255.0f alpha:1.0f];
    _ORANGE = [UIColor colorWithRed:236.0f/255.0f green:100.0f/255.0f blue:66.0f/255.0f alpha:1.0f];
    _DARK_ORANGE = [UIColor colorWithRed:221.0f/255.0f green:128.0f/255.0f blue:98.0f/255.0f alpha:1.0f];
    _GRAY = [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1.0f];
    
    _ITALIC_LATO = [UIFont fontWithName:@"Lato-Italic" size:12.0f];
    _REG_LATO = [UIFont fontWithName:@"Lato-Regular" size:12.0f];
    _BOLD_LATO = [UIFont fontWithName:@"Lato-Bold" size:18.0f];
    _SMALL_LATO = [UIFont fontWithName:@"Lato-Regular" size:10.0f];
    
}

@end
