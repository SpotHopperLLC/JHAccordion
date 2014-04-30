//
//  CLGeocoder+DoubleLookup.m
//  SpotHopper
//
//  Created by Josh Holtz on 2/6/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "CLGeocoder+DoubleLookup.h"

@implementation CLGeocoder (DoubleLookup)

- (void)doubleGeocodeAddressDictionary:(NSDictionary *)addressDictionary completionHandler:(DoubleLookupGeocodeCompletionHandler)completionHandler {
    [self geocodeAddressDictionary:addressDictionary completionHandler:^(NSArray *placemarks, NSError *error) {
        [self doTheDouble:placemarks error:error completionHandler:completionHandler];
    }];
}

- (void)doubleGeocodeAddressString:(NSString *)addressString completionHandler:(DoubleLookupGeocodeCompletionHandler)completionHandler {
    [self geocodeAddressString:addressString completionHandler:^(NSArray *placemarks, NSError *error) {
        [self doTheDouble:placemarks error:error completionHandler:completionHandler];
    }];
}

- (void)doubleGeocodeAddressString:(NSString *)addressString inRegion:(CLRegion *)region completionHandler:(DoubleLookupGeocodeCompletionHandler)completionHandler {
    [self geocodeAddressString:addressString inRegion:region completionHandler:^(NSArray *placemarks, NSError *error) {
        [self doTheDouble:placemarks error:error completionHandler:completionHandler];
    }];
}

#pragma mark - Private

- (void)doTheDouble:(NSArray*)singlePlacemarks error:(NSError*)error completionHandler:(DoubleLookupGeocodeCompletionHandler)completionHandler {
    if (error || singlePlacemarks.count == 0) {
        completionHandler(singlePlacemarks, nil, error);
    } else {
        CLPlacemark *placemark = [singlePlacemarks objectAtIndex:0];;
        [self reverseGeocodeLocation:placemark.location completionHandler:^(NSArray *doublePlacemarks, NSError *error) {
            completionHandler(singlePlacemarks, doublePlacemarks, error);
        }];
        
    }
}

@end
