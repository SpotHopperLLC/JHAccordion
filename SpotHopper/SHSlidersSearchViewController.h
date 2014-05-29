//
//  SHSearchViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/22/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

@protocol SHSlidersSearchDelegate;

@interface SHSlidersSearchViewController : BaseViewController

@property (weak, nonatomic) id<SHSlidersSearchDelegate> delegate;

- (void)prepareForMode:(SHMode)mode;

@end

@protocol SHSlidersSearchDelegate <NSObject>

@optional

@end