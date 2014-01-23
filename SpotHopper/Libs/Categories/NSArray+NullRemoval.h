//
//  NSArray+NullRemoval.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/23/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NullRemoval)

- (NSArray *)arrayByRemovingNulls;

@end
