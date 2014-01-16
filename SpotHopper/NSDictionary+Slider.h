//
//  NSDictionary+Slider.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/15/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Slider)

- (NSString*)ID;
- (NSString*)name;
- (NSString*)min;
- (NSString*)max;
- (NSNumber*)value;

@end
