//
//  BaseSlidersSearchTableViewManager.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/23/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SHSlidersSearchTableViewDelegate;

@interface SHSlidersSearchTableViewManager : NSObject <UITableViewDataSource, UITableViewDelegate>

- (void)prepareForMode:(SHMode)mode;

- (void)prepareTableViewForDrinkType:(NSString *)drinkTypeName;

- (void)prepareTableViewForDrinkType:(NSString *)drinkTypeName andWineSubType:(NSString *)wineSubTypeName;

@end

@protocol SHSlidersSearchTableViewDelegate <NSObject>

@optional

@end