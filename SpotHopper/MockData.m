//
//  MockData.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/18/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "MockData.h"

@implementation MockData

+ (Mockery*)startTheMockery {
    Mockery *mockery = [Mockery mockeryWithURL:kBaseUrl];
    
    /*
     * DRINKS
     */
    [Mockery get:@"/api/drinks" block:^MockeryHTTPURLResponse *(NSString *path, NSURLRequest *request, NSDictionary *queryParams, NSArray *routeParams) {
        sleep(1.5f);
        
        NSLog(@"Query params - %@", queryParams);
        NSDictionary *d1 = [self drinkForId:@1 withLinks:@{@"spot":@1}];
        
        NSArray *ds = @[d1];
        
        NSDictionary *jsonApi = @{
                                  @"drinks" : ds,
                                  @"linked" : @{
                                          @"spots" : @[
                                                  [self spotForId:@1 withLinks:nil]
                                                  ]
                                          },
                                  @"meta" : @{
                                          @"page" : [queryParams objectForKey:@"page"],
                                          @"total_records" : @500
                                          }
                                  };
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonApi options:0 error:nil];
        
        return [MockeryHTTPURLResponse mockeryWithURL:request.URL statusCode:200 data:jsonData headerFields:[NSDictionary dictionary]];
    }];
    
    /*
     * REVIEWS
     */
    [Mockery get:@"/api/reviews" block:^MockeryHTTPURLResponse *(NSString *path, NSURLRequest *request, NSDictionary *queryParams, NSArray *routeParams) {
        sleep(1.5f);
        
        NSDictionary *r1 = [self reviewForId:@1 withLinks:@{@"spot":@1}];
        NSDictionary *r2 = [self reviewForId:@2 withLinks:@{@"drink":@1}];
        
        NSArray *rs = @[r1, r2];
        
        NSDictionary *jsonApi = @{
                                  @"reviews" : rs,
                                  @"linked" : @{
                                          @"spots" : @[
                                                  [self spotForId:@1 withLinks:nil]
                                                  ]
                                          ,
                                          @"drinks" : @[
                                                  [self drinkForId:@1 withLinks:@{@"spot":@1}]
                                                  ]
                                          }
                                  };
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonApi options:0 error:nil];
        
        return [MockeryHTTPURLResponse mockeryWithURL:request.URL statusCode:200 data:jsonData headerFields:[NSDictionary dictionary]];
    }];
    
    /*
     * REVIEWS/<ID>
     */
    [Mockery post:[NSRegularExpression regularExpressionWithPattern:@"^/reviews/(\\d+)" options:NSRegularExpressionCaseInsensitive error:nil] block:^MockeryHTTPURLResponse *(NSString *path, NSURLRequest *request, NSDictionary *queryParams, NSArray *routeParams) {
        sleep(1.5f);
        
        NSNumber *reviewId = [routeParams objectAtIndex:0];
        NSDictionary *r = [self reviewForId:reviewId withLinks:@{@"spot":@1}];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:r options:0 error:nil];
        
        return [MockeryHTTPURLResponse mockeryWithURL:request.URL statusCode:200 data:jsonData headerFields:[NSDictionary dictionary]];
    }];
    
    /*
     * SPOTS
     */
    [Mockery get:@"/api/spots" block:^MockeryHTTPURLResponse *(NSString *path, NSURLRequest *request, NSDictionary *queryParams, NSArray *routeParams) {
        sleep(1.5f);
        
        NSDictionary *s1 = [self spotForId:@1 withLinks:nil];
        
        NSArray *ss = @[s1];
        
        NSDictionary *jsonApi = @{
                                  @"spots" : ss,
                                  @"linked" : @{
                                          }
                                  };
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonApi options:0 error:nil];
        
        return [MockeryHTTPURLResponse mockeryWithURL:request.URL statusCode:200 data:jsonData headerFields:[NSDictionary dictionary]];
    }];
    
    return mockery;
}

#pragma mark - Data Helpers

+ (NSDictionary*)drinkForId:(NSNumber*)ID withLinks:(NSDictionary*)links {
    if (links == nil) links = @{};
    if (ID.intValue == 1) {
        return @{
                 @"id": @1,
                 @"name": @"Boobs and Billiards Scotch",
                 @"image_url" : @"http://placekitten.com/300/300",
                 @"type": @"spirit",
                 @"subtype": @"scotch",
                 @"description": @"Super premium breasts and pool balls scotch which reeks of upper crust.",
                 @"alcohol_by_volume": @0.9,
                 @"style": @"IPA",
                 @"vintage": @1984,
                 @"region": @"Your mom's butt",
                 @"recipe": @"1 part boobs\n1part billiards",
                 @"links" : links
                 };
    }
    return nil;
}

+ (NSDictionary*)reviewForId:(NSNumber*)ID withLinks:(NSDictionary*)links {
    if (links == nil) links = @{};
    if (ID.intValue == 1) {
        return @{
                 @"id": @1,
                 @"rating": @9,
                 @"sliders": @[
                         @{@"id": @"radness", @"name": @"Radness", @"min": @"UnRad", @"max": @"Super Rad!", @"value": @9}
                         ],
                 @"created_at": @"2014-01-01T15:12:43+00:00",
                 @"updated_at": @"2014-01-01T15:12:43+00:00",
                 @"links" : links
                 
                 };
    } else if (ID.intValue == 2) {
        return @{
                 @"id": @2,
                 @"rating": @5,
                 @"sliders": @[
                         @{@"id": @"radness", @"name": @"Radness", @"min": @"UnRad", @"max": @"Super Rad!", @"value": @4}
                         ],
                 @"created_at": @"2014-01-01T15:12:43+00:00",
                 @"updated_at": @"2014-01-01T15:12:43+00:00",
                 @"links" : links
                 
                 };
    }
    return nil;
}

+ (NSDictionary*)sliderForId:(NSNumber*)ID withLinks:(NSDictionary*)links {
    if (links == nil) links = @{};
    if (ID.intValue == 1) {
        return @{
                 @"id": @1,
                 @"value": @"5",
                 @"links" : links
                 };
    }
    return nil;
}

+ (NSDictionary*)sliderTemplateForId:(NSNumber*)ID withLinks:(NSDictionary*)links {
    if (links == nil) links = @{};
    if (ID.intValue == 1) {
        return @{
                 @"id": @1,
                 @"name": @"Quality",
                 @"min_label": @"Bad",
                 @"max_label": @"Good",
                 @"default_value": @6,
                 @"required": @YES,
                 @"links" : links
                 };
    } else if (ID.intValue == 2) {
        return @{
                 @"id": @2,
                 @"name": @"Awesomeness",
                 @"min_label": @"Not awesome",
                 @"max_label": @"So awesome",
                 @"default_value": @7,
                 @"required": @YES,
                 @"links" : links
                 };
    } else if (ID.intValue == 3) {
        return @{
                 @"id": @3,
                 @"name": @"Okayness",
                 @"min_label": @"Not okay",
                 @"max_label": @"So okay",
                 @"default_value": @9,
                 @"required": @NO,
                 @"links" : links
                 };
    }
    return nil;
}

+ (NSDictionary*)spotForId:(NSNumber*)ID withLinks:(NSDictionary*)links {
    if (links == nil) links = @{};
    if (ID.intValue == 1) {
        return @{
                 @"id": @1,
                 @"name": @"Oatmeal Junction",
                 @"image_url" : @"http://placekitten.com/300/300",
                 @"type": @"Restaurant",
                 @"address": @"229 E Wisconsin Ave\nSuite #1102\nMilwaukee, WI 53202",
                 @"phone_number": @"715-539-8911",
                 @"hours_of_operation":@[
                         @[@"8:30-0500",@"16:00-0500"],
                         @[@"8:00-0500",@"20:00-0500"],
                         @[@"8:00-0500",@"20:00-0500"],
                         @[@"8:00-0500",@"20:00-0500"],
                         @[@"8:00-0500",@"20:00-0500"],
                         @[@"8:00-0500",@"20:00-0500"],
                         @[@"8:30-0500",@"18:00-0500"]
                         ],
                 @"latitude": @43.038513,
                 @"longitude": @-87.908913,
                 @"sliders":@[
                         @{@"id": @"radness", @"name": @"Radness", @"min": @"UnRad", @"max": @"Super Rad!", @"value": @10}
                         ],
                 @"links" : links
                 };
    }
    return nil;
}

+ (NSDictionary*)userForId:(NSNumber*)ID withLinks:(NSDictionary*)links {
    if (links == nil) links = @{};
    if (ID.intValue == 1) {
        return @{
                 @"id": @1,
                 @"email": @"placeholder@rokkincat.com",
                 @"role": @"admin",
                 @"name": @"Nick Gartmann",
                 @"birthday": @"1989-02-03",
                 @"settings": @{},
                 @"links" : links
                 };
    }
    return nil;
}

@end
