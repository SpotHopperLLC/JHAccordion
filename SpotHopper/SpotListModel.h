//
//  SpotListModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/4/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

#import <JSONAPI/JSONAPI.h>

@class ErrorModel, SpotModel;

@interface SpotListModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL featured;
@property (nonatomic, strong) NSArray *spots;

+ (Promise*)getSpotLists:(NSDictionary*)params success:(void(^)(NSArray *spotListModels, JSONAPI *jsonApi))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

+ (Promise *)postSpotList:(NSString*)name sliders:(NSArray*)sliders successBlock:(void (^)(SpotListModel *, JSONAPI *))successBlock failure:(void (^)(ErrorModel *))failureBlock;

@end
