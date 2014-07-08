//
//  SpotTypeModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 2/20/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

@interface SpotTypeModel : SHJSONAPIResource<NSCopying>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updateAt;

@end
