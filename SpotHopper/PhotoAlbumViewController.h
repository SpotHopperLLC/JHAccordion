//
//  PhotoAlbumViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 4/30/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

@interface PhotoAlbumViewController : BaseViewController

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) UIImage *placeholderImage;

@end
