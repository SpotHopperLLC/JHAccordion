//
//  NSArray+SaveLoad.h
//  GoodNightCar
//
//  Created by Josh Holtz on 6/18/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (SaveLoad)

- (void)saveWithKey:(NSString*)key;
+ (id)loadWithKey:(NSString*)key;

@end
