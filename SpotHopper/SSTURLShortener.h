//
//  SSTURLShortener.h
//  BitlyForiOS
//
//  Created by Brennan Stehling on 7/10/13.
//  Copyright (c) 2013 SmallSharpTools LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"

@interface SSTURLShortener : AFHTTPSessionManager

+ (void)shortenURL:(NSURL *)url username:(NSString *)username apiKey:(NSString *)apiKey withCompletionBlock:(void (^)(NSURL *shortenedURL, NSError *error))completionBlock;

@end
