//
//  NSNumber+Helpers.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/16/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Helpers)

- (NSNumber*)increment;
- (NSNumber*)decrement;
- (NSNumber*)add:(CGFloat)toAdd;
- (NSNumber*)subtract:(CGFloat)toSubtract;

@end
