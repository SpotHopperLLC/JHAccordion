//
//  DrinkSubTypeModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

@interface DrinkSubTypeModel : SHJSONAPIResource<NSCopying>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;

@end
