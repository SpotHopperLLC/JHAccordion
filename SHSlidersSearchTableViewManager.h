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

@end

@protocol SHSlidersSearchTableViewDelegate <NSObject>

@optional

@end