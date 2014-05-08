//
//  PhotoViewerViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/7/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

@interface PhotoViewerViewController : BaseViewController

@property (strong, nonatomic) NSArray *images;
@property (assign, nonatomic) NSUInteger index;

@end
