//
//  MockData.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/18/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Mockery.h"

@interface MockData : NSObject

+ (Mockery*)startTheMockery;

+ (NSDictionary*)drinkForId:(NSNumber*)ID withLinks:(NSDictionary*)links;
+ (NSDictionary*)spotForId:(NSNumber*)ID withLinks:(NSDictionary*)links;
+ (NSDictionary*)userForId:(NSNumber*)ID withLinks:(NSDictionary*)links;
+ (NSDictionary*)reviewForId:(NSNumber*)ID withLinks:(NSDictionary*)links;

@end
