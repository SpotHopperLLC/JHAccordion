//
//  PriceModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/31/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

@class SizeModel;

@interface PriceModel : SHJSONAPIResource

@property (nonatomic, strong) NSNumber *cents;
@property (nonatomic, strong) SizeModel *size;

@end
