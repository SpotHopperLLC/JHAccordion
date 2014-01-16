//
//  SpotModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

#import "NSArray+HoursOfOperation.h"
#import "NSDictionary+Slider.h"

@interface SpotModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSArray *hoursOfOperation; // Returns array (7 in size, SMTWTFS) of arrays (2 in size, open to close)
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSArray *sliders;

+ (void)getSpots:(NSDictionary*)params success:(void(^)(NSArray *spotModels))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock;

@end
