//
//  UIView+ViewFromNib.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/8/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "UIView+ViewFromNib.h"

@implementation UIView (ViewFromNib)

+ (id)viewFromNibNamed:(NSString *)name withOwner:(id)owner {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:name owner:owner options:nil];
    return [nibContents objectAtIndex:0];
}

@end
