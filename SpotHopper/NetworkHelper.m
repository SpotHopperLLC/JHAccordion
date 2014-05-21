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

+ (void)loadImage:(ImageModel *)imageModel placeholderImage:(UIImage *)placeholderImage withThumbImageBlock:(void (^)(UIImage *thumbImage))thumbImageBlock withFullImageBlock:(void (^)(UIImage *fullImage))fullImageBlock withErrorBlock:(void (^)(NSError *error))errorBlock {
    
    if (!imageModel.thumbUrl.length || !imageModel.fullUrl.length) {
        // do nothing since there is no image to load
        return;
    }
    
    UIImageView *thumbImageView = [[UIImageView alloc] init];
    UIImageView *fullImageView = [[UIImageView alloc] init];
    
    // first load the thumb image
    NSMutableURLRequest *thumbImageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageModel.thumbUrl]];
    [thumbImageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [thumbImageView setImageWithURLRequest:thumbImageRequest placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *thumbImage) {
        
        if (thumbImageBlock) {
            thumbImageBlock(thumbImage);
        }
        
        // then load the large image
        NSMutableURLRequest *fullImageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageModel.fullUrl]];
        [fullImageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        [fullImageView setImageWithURLRequest:fullImageRequest placeholderImage:thumbImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *fullImage) {
            
            if (fullImage && fullImageBlock) {
                fullImageBlock(fullImage);
            }
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [Tracker track:@"Error Loading Image" properties:@{@"URL" : imageModel.fullUrl}];
            
            if (errorBlock) {
                errorBlock(error);
            }
        }];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [Tracker track:@"Error Loading Image" properties:@{@"URL" : imageModel.thumbUrl}];
        
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

+ (void)loadThumbnailImage:(ImageModel *)imageModel imageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage {
    if (!imageModel.thumbUrl.length) {
        // do nothing since there is no image to load
        return;
    }
    
    __weak UIImageView *weakImageView = imageView;
    
    // first load the thumb image
    NSMutableURLRequest *thumbImageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageModel.thumbUrl]];
    [thumbImageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [weakImageView setImageWithURLRequest:thumbImageRequest placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *thumbImage) {
        
        weakImageView.image = thumbImage;
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [Tracker track:@"Error Loading Image" properties:@{@"URL" : imageModel.thumbUrl}];
    }];
}

+ (void)loadSmallImage:(ImageModel *)imageModel imageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage {
    if (!imageModel.smallUrl.length) {
        // do nothing since there is no image to load
        return;
    }
    
    __weak UIImageView *weakImageView = imageView;
    
    // first load the small image
    NSMutableURLRequest *smallImageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:imageModel.smallUrl]];
    [smallImageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [weakImageView setImageWithURLRequest:smallImageRequest placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
        
        weakImageView.image = smallImage;
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [Tracker track:@"Error Loading Image" properties:@{@"URL" : imageModel.smallUrl}];
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
