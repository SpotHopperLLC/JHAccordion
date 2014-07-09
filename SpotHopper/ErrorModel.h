//
//  ErrorModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/10/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

@interface ErrorModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *human;
@property (nonatomic, strong) NSString *error;
@property (nonatomic, strong) NSDictionary *validations;

- (NSString*)humanValidations;

@end