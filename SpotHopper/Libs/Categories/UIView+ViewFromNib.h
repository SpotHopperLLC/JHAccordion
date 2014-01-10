//
//  UIView+ViewFromNib.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/8/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ViewFromNib)

+ (id)viewFromNibNamed:(NSString *)name withOwner:(id)owner;

@end
