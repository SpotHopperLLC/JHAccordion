//
//  ImageModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/26/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "ImageModel.h"

#define kFullPath @"/full"
#define kS3Host @"spothopper-static.s3.amazonaws.com"
#define kCloudFrontHost @"static.spotapps.co"

@implementation ImageModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ [%@]", self.ID, self.url, NSStringFromClass([self class])];
}

#pragma mark -

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'url' to 'url' property
    // Maps values in JSON key 'foursquare_id' to 'foursquareId' property
    return @{
             @"url" : @"url",
             @"foursquare_id" : @"foursquareId"
             };
}

- (NSString *)url {
    return [self tweakedUrl:_url];
}

- (NSDictionary *)urls {
    return [self objectForKey:@"urls"];
}

- (NSString *)thumbUrl {
    return [self urlForImageSize:@"thumb"];
}

- (NSString *)smallUrl {
    return [self urlForImageSize:@"small"];
}

- (NSString *)fullUrl {
    return [self urlForImageSize:@"full"];
}

#pragma mark - Private

- (NSString *)urlForImageSize:(NSString *)size {
    NSString *url = (NSString *)self.urls[size];
    
    if (![@"full" isEqualToString:size] && [url hasSuffix:kFullPath]) {
        url = [url stringByReplacingOccurrencesOfString:kFullPath withString:[NSString stringWithFormat:@"/%@", size]];
    }
    
    return [self tweakedUrl:url];
}

- (NSString *)tweakedUrl:(NSString *)url {
    if ([url hasPrefix:@"//"] == YES) {
        return [NSString stringWithFormat:@"http:%@", url];
    }
    
    if ([url rangeOfString:kS3Host].location != NSNotFound) {
        url = [url stringByReplacingOccurrencesOfString:kS3Host withString:kCloudFrontHost];
    }

    return url;
}

@end
