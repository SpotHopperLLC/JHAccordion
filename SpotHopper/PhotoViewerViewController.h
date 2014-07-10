//
//  PhotoViewerViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 5/7/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

@protocol PhotoViewerDelegate;

@interface PhotoViewerViewController : BaseViewController

@property (weak, nonatomic) IBOutlet id<PhotoViewerDelegate> delegate;
@property (strong, nonatomic) NSArray *images;
@property (assign, nonatomic) NSUInteger selectedIndex;

@end

@protocol PhotoViewerDelegate <NSObject>

@optional

- (void)photoViewer:(PhotoViewerViewController *)photoViewer didChangeIndex:(NSUInteger)index;

@end
