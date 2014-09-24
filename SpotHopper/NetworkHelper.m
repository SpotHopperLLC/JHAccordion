//
//  NetworkHelper.m
//  SpotHopper
//
//  Created by Brennan Stehling on 4/23/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "NetworkHelper.h"

#import "Tracker.h"

#import <AFNetworking/AFNetworking.h>

@interface ThumbnailImageCache : NSCache

- (UIImage *)cachedThumbnailImageForKey:(NSString *)key;
- (void)cacheThumbnailImage:(UIImage *)thumbnailImage forKey:(NSString *)key;

@end

@implementation NetworkHelper

+ (void)loadImage:(ImageModel *)imageModel placeholderImage:(UIImage *)placeholderImage withThumbImageBlock:(void (^)(UIImage *thumbImage))thumbImageBlock withFullImageBlock:(void (^)(UIImage *fullImage))fullImageBlock withErrorBlock:(void (^)(NSError *error))errorBlock {
    
    if (!imageModel.thumbUrl || !imageModel.fullUrl) {
        // do nothing since there is no image to load
        if (placeholderImage && fullImageBlock) {
            fullImageBlock(placeholderImage);
        }
        return;
    }
    
    // 1) fetch thumbnail image (which may be cached) and run callback block
    // 2) fetch full size image and run callback block
    
    NSURL *thumbUrl = [NSURL URLWithString:imageModel.thumbUrl];
    [self fetchImageWithURL:thumbUrl cachable:TRUE withCompletionBlock:^(UIImage *image, NSError *error) {
        if (error && errorBlock) {
            errorBlock(error);
        }
        else if (image && thumbImageBlock) {
            thumbImageBlock(image);
        }
        
        NSURL *fullUrl = [NSURL URLWithString:imageModel.fullUrl];
        [self fetchImageWithURL:fullUrl cachable:FALSE withCompletionBlock:^(UIImage *image, NSError *error) {
            if (error && errorBlock) {
                errorBlock(error);
            }
            else if (image && fullImageBlock) {
                fullImageBlock(image);
            }
        }];
    }];
}

+ (void)loadThumbnailImage:(ImageModel *)imageModel imageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage {
    if (!imageModel.thumbUrl.length) {
        // do nothing since there is no image to load
        return;
    }
    
    imageView.image = placeholderImage;
    
    NSURL *url = [NSURL URLWithString:imageModel.thumbUrl];
    [self fetchImageWithURL:url cachable:TRUE withCompletionBlock:^(UIImage *image, NSError *error) {
        if (image) {
            imageView.image = image;
        }
    }];
}

+ (void)loadSmallImage:(ImageModel *)imageModel imageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage {
    if (!imageModel.smallUrl.length) {
        // do nothing since there is no image to load
        return;
    }
    
    imageView.image = placeholderImage;
    
    NSURL *url = [NSURL URLWithString:imageModel.smallUrl];
    [self fetchImageWithURL:url cachable:TRUE withCompletionBlock:^(UIImage *image, NSError *error) {
        if (image) {
            imageView.image = image;
        }
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
        if (imageModel.thumbUrl.length) {
            NSURL *url = [NSURL URLWithString:imageModel.thumbUrl];
            [self fetchImageWithURL:url cachable:TRUE withCompletionBlock:^(UIImage *image, NSError *error) {
                [self preloadImageModels:imageModels index:index+1];
            }];
        }
    }
}

+ (void)fetchImageWithURL:(NSURL *)url cachable:(BOOL)cachable withCompletionBlock:(void (^)(UIImage *image, NSError *error))completionBlock {
    if (!completionBlock) {
        return;
    }
    
    if (cachable) {
        UIImage *image = [[self sh_sharedCache] cachedThumbnailImageForKey:url.absoluteString];
        if (image) {
            completionBlock(image, nil);
            return;
        }
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 20;
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == 200 && [responseObject isKindOfClass:[NSData class]]) {
            UIImage *image = [[UIImage alloc] initWithData:responseObject];
            [[self sh_sharedCache] cachedThumbnailImageForKey:url.absoluteString];
            
            completionBlock(image, nil);
        }
        else {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Unexpected response for image request"};
            NSError *error = [NSError errorWithDomain:@"NetworkHelper" code:400 userInfo:userInfo];
            completionBlock(nil, error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
    
    [operation start];
}

#pragma mark - Caching

+ (ThumbnailImageCache *)sh_sharedCache {
    static ThumbnailImageCache *_sh_Cache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sh_Cache = [[ThumbnailImageCache alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_sh_Cache removeAllObjects];
        }];
    });
    
    return _sh_Cache;
}

@end

@implementation ThumbnailImageCache

- (UIImage *)cachedThumbnailImageForKey:(NSString *)key {
    return [self objectForKey:key];
}

- (void)cacheThumbnailImage:(UIImage *)thumbnailImage forKey:(NSString *)key {
    if (thumbnailImage) {
        [self setObject:thumbnailImage forKey:key];
    }
    else {
        [self removeObjectForKey:key];
    }
}

@end
