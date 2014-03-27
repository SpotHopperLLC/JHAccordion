//
//  LiveSpecialModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/26/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

@class SpotModel;

@interface LiveSpecialModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) SpotModel *spot;

@property (nonatomic, strong) NSString *startDateStr;
@property (nonatomic, strong) NSString *endDateStr;

@end
