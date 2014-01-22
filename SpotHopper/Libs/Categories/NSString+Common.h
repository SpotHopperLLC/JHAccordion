//
//  NSString+Common.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/22/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Common)

-(BOOL)isBlank;
-(BOOL)contains:(NSString *)string;
-(NSArray *)splitOnChar:(char)ch;
-(NSString *)substringFrom:(NSInteger)from to:(NSInteger)to;
-(NSString *)stringByStrippingWhitespace;

@end
