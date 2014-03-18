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
#import "DrinkTypeModel.h"
#import "ErrorModel.h"
#import "ReviewModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"
#import "SpotModel.h"
#import "UserModel.h"

//#import "NSArray+HoursOfOperation.h"

#import <JSONAPI/JSONAPI.h>

@interface SpotHopperTests : XCTestCase

@end

@implementation SpotHopperTests

- (void)setUp
{
    [super setUp];
    
    // Initializes resource linkng for JSONAPI
    [JSONAPIResourceLinker link:@"drink" toLinkedType:@"drinks"];
    [JSONAPIResourceLinker link:@"drink_type" toLinkedType:@"drink_types"];
    [JSONAPIResourceLinker link:@"review" toLinkedType:@"reviews"];
    [JSONAPIResourceLinker link:@"slider" toLinkedType:@"sliders"];
    [JSONAPIResourceLinker link:@"slider_template" toLinkedType:@"slider_templates"];
    [JSONAPIResourceLinker link:@"spot" toLinkedType:@"spots"];
    [JSONAPIResourceLinker link:@"user" toLinkedType:@"users"];
    
    // Initializes model linking for JSONAPI
    [JSONAPIResourceModeler useResource:[DrinkModel class] toLinkedType:@"drinks"];
    [JSONAPIResourceModeler useResource:[DrinkTypeModel class] toLinkedType:@"drink_types"];
    [JSONAPIResourceModeler useResource:[ErrorModel class] toLinkedType:@"errors"];
    [JSONAPIResourceModeler useResource:[ReviewModel class] toLinkedType:@"reviews"];
    [JSONAPIResourceModeler useResource:[SliderModel class] toLinkedType:@"sliders"];
    [JSONAPIResourceModeler useResource:[SliderTemplateModel class] toLinkedType:@"slider_templates"];
    [JSONAPIResourceModeler useResource:[SpotModel class] toLinkedType:@"spots"];
    [JSONAPIResourceModeler useResource:[UserModel class] toLinkedType:@"users"];
    
}

- (void)tearDown
{
    [JSONAPIResourceLinker unlinkAll];
    [JSONAPIResourceModeler unmodelAll];
    
    [super tearDown];
}

- (void)testHoursOfOperationNormalBarHours {

    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Today will be Tuesday March, 18th
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    [comp setDay:18];
    [comp setMonth:3];
    [comp setYear:2014];
    
    // Setting time
    [comp setHour:16];
    [comp setMinute:0];
    [comp setTimeZone:[NSTimeZone timeZoneWithName:@"GST"]];
    
    NSDate *now = [calendar dateFromComponents:comp];
    
    NSArray *hoursOfOperation = @[
                                  @[ @"9:00 PM", @"1:30 AM" ],
                                  @[ @"9:00 PM", @"1:30 AM" ],
                                  @[ @"9:00 PM", @"1:30 AM" ],
                                  @[ @"9:00 PM", @"1:30 AM" ],
                                  @[ @"9:00 PM", @"1:30 AM" ],
                                  @[ @"9:00 PM", @"1:30 AM" ],
                                  @[ @"9:00 PM", @"1:30 AM" ]
                                  ];

    NSArray *hoursForToday = [hoursForToday datesForNow:now];
    
    // No asserst cause Xcode says the unit tests build "Failed" but give no errors
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
                        [MockData drinkForId:@1 withLinks:@{@"spot":@1,@"slider_templates":@[@1,@2,@3],@"drink_type":@1}]
                        ];
    NSArray *linkedSliderTemplates = @[
                             [MockData sliderTemplateForId:@1 withLinks:nil],
                             [MockData sliderTemplateForId:@2 withLinks:nil],
                             [MockData sliderTemplateForId:@3 withLinks:nil]
                             ];
    NSArray *linkedSpots = @[
                            [MockData spotForId:@1 withLinks:nil]
                             ];
    NSArray *linkedDrinkTypes = @[
                             [MockData drinkTypeForId:@1 withLinks:nil]
                             ];
    NSDictionary *linked = @{
                             @"slider_templates" : linkedSliderTemplates,
                             @"spots" : linkedSpots,
                             @"drink_types" : linkedDrinkTypes
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
        
        // Assert description
        NSString *description = [drinkFromResposne objectForKey:@"description"];
        XCTAssertEqualObjects(drinkModel.descriptionOfDrink, description, @"Should equal %@", description);
        
        // Assert alcohol by volume
        NSNumber *alcoholByVolume = [drinkFromResposne objectForKey:@"abv"];
        XCTAssertEqualObjects(drinkModel.abv, alcoholByVolume, @"Should equal %@", alcoholByVolume);
        
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
            if ([[dict objectForKey:@"id"] isEqualToNumber:spotId] == YES) {
                linkedSpot = dict;
                break;
            }
        }
        XCTAssertEqualObjects(drinkModel.spot.ID, spotId, @"Should equal %@", spotId);
        
        // Assert drink type
        NSDictionary *linkedDrinkType = nil;
        NSNumber *drinkTypeId = [[drinkFromResposne objectForKey:@"links"] objectForKey:@"drink_type"];
        for (NSDictionary *dict in [linked objectForKey:@"drink_types"]) {
            // Finds the linked dictionary that matches the linked id
            if ([[dict objectForKey:@"id"] isEqualToNumber:drinkTypeId] == YES) {
                linkedDrinkType = dict;
                break;
            }
        }
        XCTAssertEqualObjects(drinkModel.drinkType.ID, drinkTypeId, @"Should equal %@", drinkTypeId);
        
        // Assert slider templates
        NSArray *sliderTemplateIds = [[drinkFromResposne objectForKey:@"links"] objectForKey:@"slider_templates"];
        NSArray *sliderTemplateModelIds = [drinkModel.sliderTemplates valueForKey:@"ID"];
        
        sliderTemplateIds = [sliderTemplateIds sortedArrayUsingSelector:@selector(compare:)];
        sliderTemplateModelIds = [sliderTemplateModelIds sortedArrayUsingSelector:@selector(compare:)];
        
        XCTAssert([sliderTemplateIds isEqualToArray:sliderTemplateModelIds], @"Should equal %@", sliderTemplateIds);
        
        // Asset slider template model info
        for (SliderTemplateModel *sliderTemplateModel in drinkModel.sliderTemplates) {
            NSDictionary *linkedSliderTemplate = nil;
            for (NSDictionary *dict in [linked objectForKey:@"slider_templates"]) {
                // Finds the linked dictionary that matches the linked id
                if ([[dict objectForKey:@"id"] isEqualToNumber:sliderTemplateModel.ID] == YES) {
                    linkedSliderTemplate = dict;
                    break;
                }
            }
            
            // Asset name
            NSString *name = [linkedSliderTemplate objectForKey:@"name"];
            XCTAssertEqualObjects(sliderTemplateModel.name, name, @"Should equal %@", name);
            
            // Asset min label
            NSString *minLabel = [linkedSliderTemplate objectForKey:@"min_label"];
            XCTAssertEqualObjects(sliderTemplateModel.minLabel, minLabel, @"Should equal %@", minLabel);
            
            // Asset max label
            NSString *maxLabel = [linkedSliderTemplate objectForKey:@"max_label"];
            XCTAssertEqualObjects(sliderTemplateModel.maxLabel, maxLabel, @"Should equal %@", maxLabel);
            
            // Asset default value
            NSString *defaultValue = [linkedSliderTemplate objectForKey:@"default_value"];
            XCTAssertEqualObjects(sliderTemplateModel.defaultValue, defaultValue, @"Should equal %@", defaultValue);
            
            // Asset required
            BOOL required = [[linkedSliderTemplate objectForKey:@"required"] boolValue];
            XCTAssert(sliderTemplateModel.required == required, @"Should equal %@", (required ? @"true" : @"false"));
        }
    }
}

- (void)testParsingSpotModel
{
    // Creates response
    NSDictionary *meta = @{};
    NSArray *spots = @[
                        [MockData spotForId:@1 withLinks:@{@"slider_templates":@[@1,@2,@3]}]
                        ];
    NSArray *linkedSliderTemplates = @[
                                       [MockData sliderTemplateForId:@1 withLinks:nil],
                                       [MockData sliderTemplateForId:@2 withLinks:nil],
                                       [MockData sliderTemplateForId:@3 withLinks:nil]
                                       ];
    NSDictionary *linked = @{
                             @"slider_templates" : linkedSliderTemplates
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
        
        // Assert slider templates
        NSArray *sliderTemplateIds = [[spotFromResposne objectForKey:@"links"] objectForKey:@"slider_templates"];
        NSArray *sliderTemplateModelIds = [spotModel.sliderTemplates valueForKey:@"ID"];
        
        sliderTemplateIds = [sliderTemplateIds sortedArrayUsingSelector:@selector(compare:)];
        sliderTemplateModelIds = [sliderTemplateModelIds sortedArrayUsingSelector:@selector(compare:)];
        
        XCTAssert([sliderTemplateIds isEqualToArray:sliderTemplateModelIds], @"Should equal %@", sliderTemplateIds);
        
        // Asset slider template model info
        for (SliderTemplateModel *sliderTemplateModel in spotModel.sliderTemplates) {
            NSDictionary *linkedSliderTemplate = nil;
            for (NSDictionary *dict in [linked objectForKey:@"slider_templates"]) {
                // Finds the linked dictionary that matches the linked id
                if ([[dict objectForKey:@"id"] isEqualToNumber:sliderTemplateModel.ID] == YES) {
                    linkedSliderTemplate = dict;
                    break;
                }
            }
            
            // Asset name
            NSString *name = [linkedSliderTemplate objectForKey:@"name"];
            XCTAssertEqualObjects(sliderTemplateModel.name, name, @"Should equal %@", name);
            
            // Asset min label
            NSString *minLabel = [linkedSliderTemplate objectForKey:@"min_label"];
            XCTAssertEqualObjects(sliderTemplateModel.minLabel, minLabel, @"Should equal %@", minLabel);
            
            // Asset max label
            NSString *maxLabel = [linkedSliderTemplate objectForKey:@"max_label"];
            XCTAssertEqualObjects(sliderTemplateModel.maxLabel, maxLabel, @"Should equal %@", maxLabel);
            
            // Asset default value
            NSString *defaultValue = [linkedSliderTemplate objectForKey:@"default_value"];
            XCTAssertEqualObjects(sliderTemplateModel.defaultValue, defaultValue, @"Should equal %@", defaultValue);
            
            // Asset required
            BOOL required = [[linkedSliderTemplate objectForKey:@"required"] boolValue];
            XCTAssert(sliderTemplateModel.required == required, @"Should equal %@", (required ? @"true" : @"false"));
        }
        
    }
}

- (void)testParsingSliderTemplateModel
{
    // Creates response
    NSDictionary *meta = @{};
    NSArray *sliderTemplates = @[
                         [MockData sliderTemplateForId:@1 withLinks:nil]
                         ];
    NSDictionary *linked = @{
                             };
    NSDictionary *jsonResponse = @{
                                   @"meta" : meta,
                                   @"slider_templates" : sliderTemplates,
                                   @"linked" : linked
                                   };
    
    // Parses
    JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:jsonResponse];
    
    NSArray *sliderTemplateModels = [jsonApi resourcesForKey:@"slider_templates"];
    for (NSInteger i = 0; i < sliderTemplateModels.count; ++i) {
        
        // Gets model and dictionary from response
        SliderTemplateModel *sliderTemplateModel = [sliderTemplateModels objectAtIndex:i];
        NSDictionary *sliderTemplateFromResposne = [sliderTemplates objectAtIndex:i];
        
        // Assert id
        NSNumber *ID = [sliderTemplateFromResposne objectForKey:@"id"];
        XCTAssertEqualObjects(sliderTemplateModel.ID, ID, @"Should equal %@", ID);
        
        // Asset name
        NSString *name = [sliderTemplateFromResposne objectForKey:@"name"];
        XCTAssertEqualObjects(sliderTemplateModel.name, name, @"Should equal %@", name);
        
        // Asset min label
        NSString *minLabel = [sliderTemplateFromResposne objectForKey:@"min_label"];
        XCTAssertEqualObjects(sliderTemplateModel.minLabel, minLabel, @"Should equal %@", minLabel);
        
        // Asset max label
        NSString *maxLabel = [sliderTemplateFromResposne objectForKey:@"max_label"];
        XCTAssertEqualObjects(sliderTemplateModel.maxLabel, maxLabel, @"Should equal %@", maxLabel);
        
        // Asset default value
        NSString *defaultValue = [sliderTemplateFromResposne objectForKey:@"default_value"];
        XCTAssertEqualObjects(sliderTemplateModel.defaultValue, defaultValue, @"Should equal %@", defaultValue);
        
        // Asset required
        BOOL required = [[sliderTemplateFromResposne objectForKey:@"required"] boolValue];
        XCTAssert(sliderTemplateModel.required == required, @"Should equal %@", (required ? @"true" : @"false"));
    }
}


- (void)testParsingSliderModel
{
    // Creates response
    NSDictionary *meta = @{};
    NSArray *sliders = @[
                        [MockData sliderForId:@1 withLinks:@{@"slider_template":@1}]
                        ];
    NSArray *linkedSliderTemplates = @[
                                       [MockData sliderTemplateForId:@1 withLinks:nil],
                                       ];
    NSDictionary *linked = @{
                             @"slider_templates" : linkedSliderTemplates
                             };
    NSDictionary *jsonResponse = @{
                                   @"meta" : meta,
                                   @"sliders" : sliders,
                                   @"linked" : linked
                                   };
    
    // Parses
    JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:jsonResponse];
    
    NSArray *sliderModels = [jsonApi resourcesForKey:@"sliders"];
    for (NSInteger i = 0; i < sliderModels.count; ++i) {
        
        // Gets model and dictionary from response
        SliderModel *sliderModel = [sliderModels objectAtIndex:i];
        NSDictionary *sliderFromResposne = [sliders objectAtIndex:i];
        
        // Assert id
        NSNumber *ID = [sliderFromResposne objectForKey:@"id"];
        XCTAssertEqualObjects(sliderModel.ID, ID, @"Should equal %@", ID);
        
        // Assert slider templates
        XCTAssertNotNil(sliderModel.sliderTemplate, @"Should not be nil");

        // Find linked slider templtes
        NSDictionary *linkedSliderTemplate = nil;
        NSNumber *sliderTemplateId = [[sliderFromResposne objectForKey:@"links"] objectForKey:@"slider_template"];
        for (NSDictionary *dict in [linked objectForKey:@"slider_templates"]) {
            // Finds the linked dictionary that matches the linked id
            if ([[dict objectForKey:@"id"] isEqualToNumber:sliderTemplateId] == YES) {
                linkedSliderTemplate = dict;
                break;
            }
        }
        
        // Asset name
        NSString *name = [linkedSliderTemplate objectForKey:@"name"];
        XCTAssertEqualObjects(sliderModel.sliderTemplate.name, name, @"Should equal %@", name);
        
        // Asset min label
        NSString *minLabel = [linkedSliderTemplate objectForKey:@"min_label"];
        XCTAssertEqualObjects(sliderModel.sliderTemplate.minLabel, minLabel, @"Should equal %@", minLabel);
        
        // Asset max label
        NSString *maxLabel = [linkedSliderTemplate objectForKey:@"max_label"];
        XCTAssertEqualObjects(sliderModel.sliderTemplate.maxLabel, maxLabel, @"Should equal %@", maxLabel);
        
        // Asset default value
        NSString *defaultValue = [linkedSliderTemplate objectForKey:@"default_value"];
        XCTAssertEqualObjects(sliderModel.sliderTemplate.defaultValue, defaultValue, @"Should equal %@", defaultValue);
        
        // Asset required
        BOOL required = [[linkedSliderTemplate objectForKey:@"required"] boolValue];
        XCTAssert(sliderModel.sliderTemplate.required == required, @"Should equal %@", (required ? @"true" : @"false"));
    }
}

- (void)testParsingReviewModel
{
    // Creates response
    NSDictionary *meta = @{};
    NSArray *reviews = @[
                         [MockData reviewForId:@1 withLinks:@{@"drink":@1,@"spot":@1,@"user":@1,@"sliders":@[@1,@2,@3]}]
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
    NSArray *linkedSliders = @[
                             [MockData sliderForId:@1 withLinks:@{@"slider_template":@1}],
                             [MockData sliderForId:@2 withLinks:@{@"slider_template":@2}],
                             [MockData sliderForId:@3 withLinks:@{@"slider_template":@3}]
                             ];
    NSArray *linkedSliderTemplates = @[
                               [MockData sliderTemplateForId:@1 withLinks:nil],
                               [MockData sliderTemplateForId:@2 withLinks:nil],
                               [MockData sliderTemplateForId:@3 withLinks:nil]
                               ];
    NSDictionary *linked = @{
                             @"drinks" : linkedDrinks,
                             @"users" : linkedUsers,
                             @"spots" : linkedSpots,
                             @"sliders" : linkedSliders,
                             @"slider_templates" : linkedSliderTemplates
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
        
        // Assert drink
        NSDictionary *linkedDrink = nil;
        NSNumber *drinkId = [[reviewFromResposne objectForKey:@"links"] objectForKey:@"drink"];
        for (NSDictionary *dict in [linked objectForKey:@"drinks"]) {
            // Finds the linked dictionary that matches the linked id
            if ([[dict objectForKey:@"id"] isEqualToNumber:drinkId] == YES) {
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
            if ([[dict objectForKey:@"id"] isEqualToNumber:spotId] == YES) {
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
            if ([[dict objectForKey:@"id"] isEqualToNumber:userId] == YES) {
                linkedUser = dict;
                break;
            }
        }
        XCTAssertEqualObjects(reviewModel.user.ID, userId, @"Should equal %@", userId);
        
        // Assert sliders
        NSArray *sliderIds = [[reviewFromResposne objectForKey:@"links"] objectForKey:@"sliders"];
        NSArray *sliderModelIds = [reviewModel.sliders valueForKey:@"ID"];
        
        sliderIds = [sliderIds sortedArrayUsingSelector:@selector(compare:)];
        sliderModelIds = [sliderModelIds sortedArrayUsingSelector:@selector(compare:)];
        
        XCTAssert([sliderIds isEqualToArray:sliderModelIds], @"Should equal %@", sliderIds);
        
        // Asset slider model info
        for (SliderModel *sliderModel in reviewModel.sliders) {
            NSDictionary *linkedSlider = nil;
            for (NSDictionary *dict in [linked objectForKey:@"sliders"]) {
                // Finds the linked dictionary that matches the linked id
                if ([[dict objectForKey:@"id"] isEqualToNumber:sliderModel.ID] == YES) {
                    linkedSlider = dict;
                    break;
                }
            }
            
            NSLog(@"MOO1 - %@", sliderModel.sliderTemplate);
            
            NSDictionary *linkedSliderTemplate = nil;
            for (NSDictionary *dict in [linked objectForKey:@"slider_templates"]) {
                // Finds the linked dictionary that matches the linked id
                if ([[dict objectForKey:@"id"] isEqualToNumber:sliderModel.sliderTemplate.ID] == YES) {
                    linkedSliderTemplate = dict;
                    break;
                }
            }
            
            NSLog(@"MOO2 - %@", linkedSliderTemplate);
            
            // Asset name
            NSNumber *value = [linkedSlider objectForKey:@"value"];
            XCTAssertEqualObjects(sliderModel.value, value, @"Should equal %@", value);
            
            // Asset name
            NSString *name = [linkedSliderTemplate objectForKey:@"name"];
            XCTAssertEqualObjects(sliderModel.sliderTemplate.name, name, @"Should equal %@", name);
            
            // Asset min label
            NSString *minLabel = [linkedSliderTemplate objectForKey:@"min_label"];
            XCTAssertEqualObjects(sliderModel.sliderTemplate.minLabel, minLabel, @"Should equal %@", minLabel);
            
            // Asset max label
            NSString *maxLabel = [linkedSliderTemplate objectForKey:@"max_label"];
            XCTAssertEqualObjects(sliderModel.sliderTemplate.maxLabel, maxLabel, @"Should equal %@", maxLabel);
            
            // Asset default value
            NSString *defaultValue = [linkedSliderTemplate objectForKey:@"default_value"];
            XCTAssertEqualObjects(sliderModel.sliderTemplate.defaultValue, defaultValue, @"Should equal %@", defaultValue);
            
            // Asset required
            BOOL required = [[linkedSliderTemplate objectForKey:@"required"] boolValue];
            XCTAssert(sliderModel.sliderTemplate.required == required, @"Should equal %@", (required ? @"true" : @"false"));
        }
    }
}

@end
