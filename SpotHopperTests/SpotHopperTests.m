//
//  SpotHopperTests.m
//  SpotHopperTests
//
//  Created by Josh Holtz on 12/26/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ClientSessionManager.h"
#import "DrinkModel.h"
#import "ErrorModel.h"
#import "ReviewModel.h"
#import "SpotModel.h"
#import "UserModel.h"

#import <JSONAPI/JSONAPI.h>

@interface SpotHopperTests : XCTestCase

@end

@implementation SpotHopperTests

- (void)setUp
{
    [super setUp];
    
    // Initializes resource linkng for JSONAPI
    [JSONAPIResourceLinker link:@"drink" toLinkedType:@"drinks"];
    [JSONAPIResourceLinker link:@"spot" toLinkedType:@"spots"];
    [JSONAPIResourceLinker link:@"review" toLinkedType:@"reviews"];
    [JSONAPIResourceLinker link:@"user" toLinkedType:@"users"];

    // Initializes model linking for JSONAPI
    [JSONAPIResourceModeler useResource:[DrinkModel class] toLinkedType:@"drinks"];
    [JSONAPIResourceModeler useResource:[ErrorModel class] toLinkedType:@"errors"];
    [JSONAPIResourceModeler useResource:[ReviewModel class] toLinkedType:@"reviews"];
    [JSONAPIResourceModeler useResource:[SpotModel class] toLinkedType:@"spots"];
    [JSONAPIResourceModeler useResource:[UserModel class] toLinkedType:@"users"];
    
}

- (void)tearDown
{
    [JSONAPIResourceLinker unlinkAll];
    [JSONAPIResourceModeler unmodelAll];
    
    [super tearDown];
}

- (void)testParsingDrinkModel
{
    // Creates response
    NSDictionary *meta = @{};
    NSArray *drinks = @[
                        [self drinkForId:1]
                        ];
    NSArray *linkedSpots = @[
                            [self spotForId:1]
                             ];
    NSDictionary *linked = @{
                             @"spots" : linkedSpots
                             };
    NSDictionary *jsonResponse = @{
                                   @"meta" : meta,
                                   @"drinks" : drinks,
                                   @"linked" : linked
                                   };

    // Parses
    JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:jsonResponse];
    
    NSArray *drinkModels = [jsonApi resourcesForKey:@"drinks"];
    for (NSInteger i = 0; i < drinkModels.count; ++i) {
        
        // Gets model and dictionary from response
        DrinkModel *drinkModel = [drinkModels objectAtIndex:i];
        NSDictionary *drinkFromResposne = [drinks objectAtIndex:i];
        
        // Assert id
        NSNumber *ID = [drinkFromResposne objectForKey:@"id"];
        XCTAssertEqualObjects(drinkModel.ID, ID, @"Should equal %@", ID);
        
        // Assert name
        NSString *name = [drinkFromResposne objectForKey:@"name"];
        XCTAssertEqualObjects(drinkModel.name, name, @"Should equal %@", name);
        
        // Assert type
        NSString *type = [drinkFromResposne objectForKey:@"type"];
        XCTAssertEqualObjects(drinkModel.type, type, @"Should equal %@", type);
        
        // Assert subtype
        NSString *subtype = [drinkFromResposne objectForKey:@"subtype"];
        XCTAssertEqualObjects(drinkModel.subtype, subtype, @"Should equal %@", subtype);
        
        // Assert description
        NSString *description = [drinkFromResposne objectForKey:@"description"];
        XCTAssertEqualObjects(drinkModel.descriptionOfDrink, description, @"Should equal %@", description);
        
        // Assert alcohol by volume
        NSNumber *alcoholByVolume = [drinkFromResposne objectForKey:@"alcohol_by_volume"];
        XCTAssertEqualObjects(drinkModel.alcoholByVolume, alcoholByVolume, @"Should equal %@", alcoholByVolume);
        
        // Assert style
        NSString *style = [drinkFromResposne objectForKey:@"style"];
        XCTAssertEqualObjects(drinkModel.style, style, @"Should equal %@", style);
        
        // Assert vintage
        NSString *vintage = [drinkFromResposne objectForKey:@"vintage"];
        XCTAssertEqualObjects(drinkModel.vintage, vintage, @"Should equal %@", vintage);
        
        // Assert region
        NSString *region = [drinkFromResposne objectForKey:@"region"];
        XCTAssertEqualObjects(drinkModel.region, region, @"Should equal %@", region);
        
        // Assert receipe
        NSString *receipe = [drinkFromResposne objectForKey:@"receipe"];
        XCTAssertEqualObjects(drinkModel.recipe, receipe, @"Should equal %@", receipe);
        
        // Assert spot id
        NSNumber *spotId = [drinkFromResposne objectForKey:@"spot_id"];
        XCTAssertEqualObjects(drinkModel.spotId, spotId, @"Should equal %@", spotId);
        
        // Assert spot
        NSDictionary *linkedSpot = nil;
        for (NSDictionary *dict in [linked objectForKey:@"spots"]) {
            // Finds the linked dictionary that matches the linked id
            if ([[dict objectForKey:@"ID"] isEqualToNumber:spotId] == YES) {
                linkedSpot = dict;
                break;
            }
        }
        XCTAssertEqualObjects(drinkModel.spot.ID, spotId, @"Should equal %@", spotId);
    }
}

- (void)testParsingSpotModel
{
    // Creates response
    NSDictionary *meta = @{};
    NSArray *spots = @[
                        [self spotForId:1]
                        ];
    NSDictionary *linked = @{
                             };
    NSDictionary *jsonResponse = @{
                                   @"meta" : meta,
                                   @"spots" : spots,
                                   @"linked" : linked
                                   };
    
    // Parses
    JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:jsonResponse];
    
    NSArray *spotModels = [jsonApi resourcesForKey:@"spots"];
    for (NSInteger i = 0; i < spotModels.count; ++i) {
        
        // Gets model and dictionary from response
        SpotModel *spotModel = [spotModels objectAtIndex:i];
        NSDictionary *spotFromResposne = [spots objectAtIndex:i];
        
        // Assert id
        NSNumber *ID = [spotFromResposne objectForKey:@"id"];
        XCTAssertEqualObjects(spotModel.ID, ID, @"Should equal %@", ID);
        
        // Assert name
        NSString *name = [spotFromResposne objectForKey:@"name"];
        XCTAssertEqualObjects(spotModel.name, name, @"Should equal %@", name);
        
        // Assert type
        NSString *type = [spotFromResposne objectForKey:@"type"];
        XCTAssertEqualObjects(spotModel.type, type, @"Should equal %@", type);
        
        // Assert address
        NSString *address = [spotFromResposne objectForKey:@"address"];
        XCTAssertEqualObjects(spotModel.address, address, @"Should equal %@", address);
        
        // Assert phone number
        NSString *phoneNumber = [spotFromResposne objectForKey:@"phone_number"];
        XCTAssertEqualObjects(spotModel.phoneNumber, phoneNumber, @"Should equal %@", phoneNumber);
        
        // Assert latitude
        NSString *latitude = [spotFromResposne objectForKey:@"latitude"];
        XCTAssertEqualObjects(spotModel.latitude, latitude, @"Should equal %@", latitude);
        
        // Assert longitude
        NSString *longitude = [spotFromResposne objectForKey:@"longitude"];
        XCTAssertEqualObjects(spotModel.longitude, longitude, @"Should equal %@", longitude);
        
        // Assert hours of operation
        NSArray *hoursOfOperation = [spotFromResposne objectForKey:@"hours_of_operation"];
        XCTAssertEqualObjects(spotModel.hoursOfOperation, hoursOfOperation, @"Should equal %@", hoursOfOperation);
        
        // Asset sliders
        NSDictionary *sliders = [spotFromResposne objectForKey:@"sliders"];
        XCTAssertEqualObjects(spotModel.sliders, sliders, @"Should equal %@", sliders);
        
    }
}

#pragma mark - Data Helpers

- (NSDictionary*)drinkForId:(NSInteger)ID {
    if (ID == 1) {
        return @{
                 @"id": @1,
                 @"name": @"Boobs and Billiards Scotch",
                 @"type": @"spirit",
                 @"subtype": @"scotch",
                 @"description": @"Super premium breasts and pool balls scotch which reeks of upper crust.",
                 @"alcohol_by_volume": @0.9,
                 @"style": @"IPA",
                 @"vintage": @1984,
                 @"region": @"Your mom's butt",
                 @"recipe": @"1 part boobs\n1part billiards",
                 @"spot_id": @1,
                 @"links" : @{
                         @"spot": @1
                         }
                 
                 };
    }
    return nil;
}

- (NSDictionary*)spotForId:(NSInteger)ID {
    if (ID == 1) {
        return @{
                 @"id": @1,
                 @"name": @"Oatmeal Junction",
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
                         ]
                 };
    }
    return nil;
}

@end
