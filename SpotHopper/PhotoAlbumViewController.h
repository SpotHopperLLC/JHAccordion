//
//  PhotoAlbumViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 4/30/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

#import "PhotoViewerViewController.h"

@interface PhotoAlbumViewController : BaseViewController <PhotoViewerDelegate>

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) UIImage *placeholderImage;

@end
