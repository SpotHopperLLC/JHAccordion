//
//  CLGeocoder+DoubleLookup.h
//  SpotHopper
//
//  Created by Josh Holtz on 2/6/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

typedef void (^DoubleLookupGeocodeCompletionHandler)(NSArray *singleLookupPlacemarks, NSArray *doubleLookupPlacemarks, NSError *error);

@interface CLGeocoder (DoubleLookup)

- (void)doubleGeocodeAddressDictionary:(NSDictionary *)addressDictionary completionHandler:(DoubleLookupGeocodeCompletionHandler)completionHandler;
- (void)doubleGeocodeAddressString:(NSString *)addressString completionHandler:(DoubleLookupGeocodeCompletionHandler)completionHandler;
- (void)doubleGeocodeAddressString:(NSString *)addressString inRegion:(CLRegion *)region completionHandler:(DoubleLookupGeocodeCompletionHandler)completionHandler;

@end
