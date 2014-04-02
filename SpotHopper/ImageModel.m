//
//  ImageModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/26/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "ImageModel.h"

@implementation ImageModel

- (NSDictionary *)mapKeysToProperties {
    // Maps values in JSON key 'url' to 'url' property
    // Maps values in JSON key 'foursquare_id' to 'foursquareId' property
    return @{
             @"url" : @"url",
             @"foursquare_id" : @"foursquareId"
             };
}

@end
