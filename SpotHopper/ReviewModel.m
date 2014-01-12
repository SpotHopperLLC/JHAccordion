//
//  ReviewModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "ReviewModel.h"

@implementation ReviewModel

#pragma mark - Getters

- (UserModel *)user {
    return [self linkedResourceForKey:@"user"];
}

- (NSNumber *)userId {
    return [self objectForKey:@"user_id"];
}

- (SpotModel *)spot {
    return [self linkedResourceForKey:@"spot"];
}

- (NSNumber *)spotId {
    return [self objectForKey:@"spot_id"];
}

- (DrinkModel *)drink {
    return [self linkedResourceForKey:@"drink"];
}

- (NSNumber *)drinkId {
    return [self objectForKey:@"drink_id"];
}

- (NSNumber *)rating {
    return [self objectForKey:@"rating"];
}

- (NSDictionary *)sliders {
    return [self objectForKey:@"sliders"];
}

- (NSDate *)createdAt {
    return [self formatDateTimestamp:[self objectForKey:@"created_at"]];
}

- (NSDate *)updatedAt {
    return [self formatDateTimestamp:[self objectForKey:@"updated_at"]];
}


@end
