//
//  NSArray+DailySpecials.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/26/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (DailySpecials)

@property (readonly, nonatomic) NSString *specialsForToday;

// THIS SHOULD ONLY GET CALLED PUBLICLY WHEN TESTING, OKAY?
- (NSString*)specialsForNow:(NSDate*)now;

@end
