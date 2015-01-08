//
//  SHUserProfile.h
//  SpotHopper
//
//  Created by Brennan Stehling on 11/25/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SHBaseModel.h"

@interface SHUserProfileModel : SHBaseModel <NSCopying, NSCoding>

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSNumber *facebookId;
@property (strong, nonatomic) NSNumber *spotHopperUserId;

- (BOOL)isEqualToUserProfileModel:(SHUserProfileModel *)other;

@end
