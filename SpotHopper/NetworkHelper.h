//
//  NetworkHelper.h
//  SpotHopper
//
//  Created by Brennan Stehling on 4/23/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ImageModel.h"

@interface NetworkHelper : NSObject

+ (void)loadImageProgressively:(ImageModel *)imageModel imageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage;

+ (void)loadThumbnailImage:(ImageModel *)imageModel imageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage;

+ (void)loadSmallImage:(ImageModel *)imageModel imageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage;

+ (void)preloadImageModels:(NSArray *)imageModels;

@end
