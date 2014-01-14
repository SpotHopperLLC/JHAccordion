//
//  SHJSONAPIResource.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/12/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "JSONAPIResource.h"

@interface SHJSONAPIResource : JSONAPIResource<NSCoding>

- (NSDate*)formatBirthday:(NSString*)string;
- (NSDate*)formatDateTimestamp:(NSString*)string;

@end
