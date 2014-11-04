//
//  SHMenuAdminTransloaditManager.h
//  SpotHopper
//
//  Created by Brennan Stehling on 10/31/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHMenuAdminTransloaditManager : NSObject

- (void)uploadSpotImageToTransloadit:(UIImage*)image withCompletionBlock:(void (^)(NSString *path, NSError *error))completionBlock;

- (void)uploadDrinkImageToTransloadit:(UIImage*)image withCompletionBlock:(void (^)(NSString *path, NSError *error))completionBlock;

- (void)uploadUserImageToTransloadit:(UIImage*)image withCompletionBlock:(void (^)(NSString *path, NSError *error))completionBlock;

- (void)uploadSpecialImageToTransloadit:(UIImage*)image withCompletionBlock:(void (^)(NSString *path, NSError *error))completionBlock;

@end
