//
//  SHBaseModel.h
//  SpotHopper
//
//  Created by Brennan Stehling on 11/25/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHBaseModel : NSObject <NSCopying, NSCoding>

@property (copy, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSDate *updatedAt;

@end
