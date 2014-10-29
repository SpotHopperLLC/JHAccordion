//
//  SizeModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/31/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

@interface SizeModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *menuTypes;

@end
