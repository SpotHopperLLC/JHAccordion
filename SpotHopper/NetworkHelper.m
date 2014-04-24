//
//  NetworkHelper.m
//  SpotHopper
//
//  Created by Brennan Stehling on 4/23/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "NetworkHelper.h"

#import "Tracker.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation NetworkHelper

+ (void)loadImageProgressively:(ImageModel *)imageModel imageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage {
    if (!imageModel.thumbUrl.length || !imageModel.fullUrl.length) {
        // do nothing since there is no image to load
        return;
    }
    
    __weak UIImageView *weakSelf = imageView;
    
    // first load the thum image
    NSMutableURLRequest *thumbImageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageModel.thumbUrl]];
    [thumbImageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [weakSelf setImageWithURLRequest:thumbImageRequest placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *thumbImage) {
        
        weakSelf.image = thumbImage;
        
        // then load the large image
        NSMutableURLRequest *fullImageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageModel.fullUrl]];
        [fullImageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        [weakSelf setImageWithURLRequest:fullImageRequest placeholderImage:thumbImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *fullImage) {
            
            weakSelf.image = fullImage;
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [Tracker track:@"Error Loading Image" properties:@{@"URL" : imageModel.fullUrl}];
        }];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [Tracker track:@"Error Loading Image" properties:@{@"URL" : imageModel.thumbUrl}];
    }];
}

+ (void)preloadImageModels:(NSArray *)imageModels {
    [self preloadImageModels:imageModels index:0];
}

// allow image to be loaded before loading the next image
+ (void)preloadImageModels:(NSArray *)imageModels index:(NSUInteger)index {
    if (index < imageModels.count) {
        ImageModel *imageModel = (ImageModel *)imageModels[index];
        
        // pre-download all thumb images
        NSString *thumbUrl = imageModel.thumbUrl;
        if (thumbUrl.length) {
            NSMutableURLRequest *thumbImageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:thumbUrl]];
            [thumbImageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
            UIImageView *imgView = [[UIImageView alloc] init];
            [imgView setImageWithURLRequest:thumbImageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                
                [self preloadImageModels:imageModels index:index+1];
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [Tracker track:@"Error Loading Image" properties:@{@"URL" : thumbUrl}];
            }];
        }
    }
}

@end
