//
//  SHAppContext.h
//  SpotHopper
//
//  Created by Brennan Stehling on 9/18/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Constants.h"

#import "SpotListRequest.h"
#import "DrinkListRequest.h"
#import "SpotListModel.h"
#import "DrinkListModel.h"

@interface SHAppContext : NSObject

@property (assign, nonatomic) SHMode mode;

@property (strong, nonatomic) SpotListRequest *spotlistRequest;
@property (strong, nonatomic) DrinkListRequest *drinkListRequest;
@property (strong, nonatomic) SpotListModel *spotlist;
@property (strong, nonatomic) DrinkListModel *drinklist;

+ (instancetype)defaultInstance;

- (void)changeContextToMode:(SHMode)mode specialsSpotlist:(SpotListModel *)spotlist;

- (void)changeContextToMode:(SHMode)mode spotlistRequest:(SpotListRequest *)spotlistRequest spotlist:(SpotListModel *)spotlist;

- (void)changeContextToMode:(SHMode)mode drinklistRequest:(DrinkListRequest *)drinklistRequest drinklist:(DrinkListModel *)drinklist;

@end
