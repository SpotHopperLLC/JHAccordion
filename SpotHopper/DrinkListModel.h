//
//  DrinkListModel.h
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

@interface DrinkListModel : SHJSONAPIResource

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL featured;
@property (nonatomic, strong) NSArray *spots;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

@end
