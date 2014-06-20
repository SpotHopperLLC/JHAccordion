//
//  LiveSpecialModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/26/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

#import <JSONAPI/JSONAPI.h>
#import <Promises/Promise.h>

@class ErrorModel, SpotModel;

@interface LiveSpecialModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) SpotModel *spot;

@property (nonatomic, strong) NSString *startDateStr;
@property (nonatomic, strong) NSString *endDateStr;

- (Promise *)getLiveSpecial:(NSDictionary *)params success:(void (^)(LiveSpecialModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock;

@end
