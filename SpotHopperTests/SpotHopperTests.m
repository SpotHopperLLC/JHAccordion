//
//  SpotHopperTests.m
//  SpotHopperTests
//
//  Created by Josh Holtz on 12/26/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MockData.h"

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

- (void)testParsingUserModel
{
    // Creates response
    NSDictionary *meta = @{};
    NSArray *users = @[
                       [MockData userForId:@1 withLinks:nil]
                       ];
    NSDictionary *linked = @{
                             };
    NSDictionary *jsonResponse = @{
                                   @"meta" : meta,
                                   @"users" : users,
                                   @"linked" : linked
                                   };
    
    // Parses
    JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:jsonResponse];
    
    NSArray *userModels = [jsonApi resourcesForKey:@"users"];
    for (NSInteger i = 0; i < userModels.count; ++i) {
        
        // Gets model and dictionary from response
        UserModel *userModel = [userModels objectAtIndex:i];
        NSDictionary *userFromResposne = [users objectAtIndex:i];
        
        // Assert id
        NSNumber *ID = [userFromResposne objectForKey:@"id"];
        XCTAssertEqualObjects(userModel.ID, ID, @"Should equal %@", ID);
        
        // Assert email
        NSString *email = [userFromResposne objectForKey:@"email"];
        XCTAssertEqualObjects(userModel.email, email, @"Should equal %@", email);
        
        // Assert role
        NSString *role = [userFromResposne objectForKey:@"role"];
        XCTAssertEqualObjects(userModel.role, role, @"Should equal %@", role);
        
        // Assert name
        NSString *name = [userFromResposne objectForKey:@"name"];
        XCTAssertEqualObjects(userModel.name, name, @"Should equal %@", name);
        
        // Assert birthday
        NSString *birthday = [userFromResposne objectForKey:@"birthday"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *birthdayAsString = [dateFormatter stringFromDate: userModel.birthday];
        XCTAssertEqualObjects(birthdayAsString, birthday, @"Should equal %@", birthday);
        
        // Assert settings
        NSString *settings = [userFromResposne objectForKey:@"settings"];
        XCTAssertEqualObjects(userModel.settings, settings, @"Should equal %@", settings);
        
    }
}

- (void)testParsingDrinkModel
{
    // Creates response
    NSDictionary *meta = @{};
    NSArray *drinks = @[
                        [MockData drinkForId:@1 withLinks:@{@"spot":@1}]
                        ];
    NSArray *linkedSpots = @[
                            [MockData spotForId:@1 withLinks:nil]
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
        
        // Assert spot
        NSDictionary *linkedSpot = nil;
        NSNumber *spotId = [[drinkFromResposne objectForKey:@"links"] objectForKey:@"spot"];
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
                        [MockData spotForId:@1 withLinks:nil]
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

- (void)testParsingReviewModel
{
    // Creates response
    NSDictionary *meta = @{};
    NSArray *reviews = @[
                        [MockData reviewForId:@1 withLinks:@{@"spot":@1,@"user":@1}]
                        ];
    NSArray *linkedDrinks = @[
                              [MockData drinkForId:@1 withLinks:nil]
                              ];
    NSArray *linkedSpots = @[
                             [MockData spotForId:@1 withLinks:nil]
                             ];
    NSArray *linkedUsers = @[
                             [MockData userForId:@1 withLinks:nil]
                             ];
    NSDictionary *linked = @{
                             @"drinks" : linkedDrinks,
                             @"users" : linkedUsers,
                             @"spots" : linkedSpots
                             };
    NSDictionary *jsonResponse = @{
                                   @"meta" : meta,
                                   @"reviews" : reviews,
                                   @"linked" : linked
                                   };
    
    // Parses
    JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:jsonResponse];
    
    NSArray *reviewModels = [jsonApi resourcesForKey:@"reviews"];
    for (NSInteger i = 0; i < reviewModels.count; ++i) {
        
        // Gets model and dictionary from response
        ReviewModel *reviewModel = [reviewModels objectAtIndex:i];
        NSDictionary *reviewFromResposne = [reviews objectAtIndex:i];
        
        // Assert id
        NSNumber *ID = [reviewFromResposne objectForKey:@"id"];
        XCTAssertEqualObjects(reviewModel.ID, ID, @"Should equal %@", ID);
        
        // Assert rating
        NSNumber *rating = [reviewFromResposne objectForKey:@"rating"];
        XCTAssertEqualObjects(reviewModel.rating, rating, @"Should equal %@", rating);
        
        // Asset sliders
        NSDictionary *sliders = [reviewFromResposne objectForKey:@"sliders"];
        XCTAssertEqualObjects(reviewModel.sliders, sliders, @"Should equal %@", sliders);
        
        // Assert drink
        NSDictionary *linkedDrink = nil;
        NSNumber *drinkId = [[reviewFromResposne objectForKey:@"links"] objectForKey:@"drink"];
        for (NSDictionary *dict in [linked objectForKey:@"drinks"]) {
            // Finds the linked dictionary that matches the linked id
            if ([[dict objectForKey:@"ID"] isEqualToNumber:drinkId] == YES) {
                linkedDrink = dict;
                break;
            }
        }
        XCTAssertEqualObjects(reviewModel.drink.ID, drinkId, @"Should equal %@", drinkId);
        
        // Assert spot
        NSDictionary *linkedSpot = nil;
        NSNumber *spotId = [[reviewFromResposne objectForKey:@"links"] objectForKey:@"spot"];
        for (NSDictionary *dict in [linked objectForKey:@"spots"]) {
            // Finds the linked dictionary that matches the linked id
            if ([[dict objectForKey:@"ID"] isEqualToNumber:spotId] == YES) {
                linkedSpot = dict;
                break;
            }
        }
        XCTAssertEqualObjects(reviewModel.spot.ID, spotId, @"Should equal %@", spotId);
        
        // Assert user
        NSDictionary *linkedUser = nil;
        NSNumber *userId = [[reviewFromResposne objectForKey:@"links"] objectForKey:@"user"];
        for (NSDictionary *dict in [linked objectForKey:@"users"]) {
            // Finds the linked dictionary that matches the linked id
            if ([[dict objectForKey:@"ID"] isEqualToNumber:userId] == YES) {
                linkedUser = dict;
                break;
            }
        }
        XCTAssertEqualObjects(reviewModel.user.ID, userId, @"Should equal %@", userId);
    }
}

@end
