//
//  SpotHopperTests.m
//  SpotHopperTests
//
//  Created by Josh Holtz on 12/26/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import <XCTest/XCTest.h>

//#import "MockData.h"

//#import "ClientSessionManager.h"

#import "SHModelResourceManager.h"
//#import "DrinkModel.h"
//#import "DrinkTypeModel.h"
//#import "ErrorModel.h"
//#import "ReviewModel.h"
//#import "SliderModel.h"
//#import "SliderTemplateModel.h"
//#import "SpotModel.h"
//#import "UserModel.h"
//#import "AverageReviewModel.h"
//#import "DrinkSubTypeModel.h"
//#import "LiveSpecialModel.h"
//#import "ReviewModel.h"
//#import "SpotTypeModel.h"

//#import "NSArray+DailySpecials.h"

#import <JSONAPI/JSONAPI.h>

@interface SpotHopperTests : XCTestCase

@end

@implementation SpotHopperTests

- (void)setUp {
    [super setUp];
    
    [JSONAPI setIsDebuggingEnabled:TRUE];
    
    [SHModelResourceManager prepareResources];
    
    JSONAPIResourceLinker *linker = [JSONAPIResourceLinker defaultInstance];
//    [linker link:@"spot" toLinkedType:@"spots"];
//    [linker link:@"drink" toLinkedType:@"drinks"];
//    [linker link:@"slider_template" toLinkedType:@"slider_templates"];
    NSLog(@"Linker: %@", linker);
    
    JSONAPIResourceModeler *modeler = [JSONAPIResourceModeler defaultInstance];
//    [modeler useResource:[SpotModel class] toLinkedType:@"spots"];
//    [modeler useResource:[DrinkModel class] toLinkedType:@"drinks"];
//    [modeler useResource:[SliderTemplateModel class] toLinkedType:@"slider_templates"];
    NSLog(@"Modeler: %@", modeler);
}

- (void)tearDown {
    [[JSONAPIResourceLinker defaultInstance] unlinkAll];
    [[JSONAPIResourceModeler defaultInstance] unmodelAll];
    [[JSONAPIResourceFormatter defaultInstance] unregisterAll];
    
    [super tearDown];
}

- (void)testModelingCore {
    NSLog(@"Linker: %@", [JSONAPIResourceLinker defaultInstance]);
    NSLog(@"Modeler: %@", [JSONAPIResourceModeler defaultInstance]);
    
    NSString *drinksType = [[JSONAPIResourceLinker defaultInstance] linkedType:@"drinks"];
    Class drinksClass = [[JSONAPIResourceModeler defaultInstance] resourceForLinkedType:drinksType];
    NSLog(@"Drinks Class: %@", NSStringFromClass(drinksClass));

    NSString *spotsType = [[JSONAPIResourceLinker defaultInstance] linkedType:@"spots"];
    Class spotsClass = [[JSONAPIResourceModeler defaultInstance] resourceForLinkedType:spotsType];
    NSLog(@"Spots Class: %@", NSStringFromClass(spotsClass));
    
    NSLog(@"Linker: %@", [JSONAPIResourceLinker defaultInstance]);
    NSLog(@"Modeler: %@", [JSONAPIResourceModeler defaultInstance]);
    
    JSONAPIResourceLinker *linker = [JSONAPIResourceLinker defaultInstance];
    JSONAPIResourceModeler *modeler = [JSONAPIResourceModeler defaultInstance];
    
    XCTAssertEqual(linker, [JSONAPIResourceLinker defaultInstance], @"Linker must equal default instance");
    XCTAssertEqual(modeler, [JSONAPIResourceModeler defaultInstance], @"Modeler must equal default instance");
    
    XCTAssert(linker == [JSONAPIResourceLinker defaultInstance], @"Linker must equal default instance");
    XCTAssert(modeler == [JSONAPIResourceModeler defaultInstance], @"Modeler must equal default instance");
    
    XCTAssertNotNil(drinksClass, @"Drinks class must be defined");
    XCTAssertNotNil(spotsClass, @"Spots class must be defined");
}

//- (void)testHoursOfOperationNormalBarHours {
//
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    
//    // Today will be Tuesday March, 18th
//    NSDateComponents *comp = [[NSDateComponents alloc] init];
//    [comp setDay:18];
//    [comp setMonth:3];
//    [comp setYear:2014];
//    
//    // Setting time
//    [comp setHour:16];
//    [comp setMinute:0];
//    [comp setTimeZone:[NSTimeZone timeZoneWithName:@"CDT"]];
//    
//    NSDate *now = [calendar dateFromComponents:comp];
//    
//    NSArray *hoursOfOperation = @[
//                                  @[ @"5:00 PM", @"10:00 PM" ],
//                                  @[ @"5:30 PM", @"10:30 PM" ],
//                                  @[ @"6:00 PM", @"11:00 PM" ],
//                                  @[ @"6:30 PM", @"11:30 PM" ],
//                                  @[ @"7:00 PM", @"12:00 AM" ],
//                                  @[ @"7:30 PM", @"12:30 AM" ],
//                                  @[ @"9:00 PM", @"1:00 AM" ]
//                                  ];
//
//    NSArray *hoursForToday = [hoursOfOperation datesForNow:now];
//    
//    NSLog(@"Hours: %@", hoursForToday);
//    
//    XCTAssert(hoursForToday.count == 2, @"An array of 2 objects is expected");
//
//    NSDate *openDate = hoursForToday[0];
//    NSDate *closeDate = hoursForToday[1];
//    
//    //NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSCalendarUnit units = NSHourCalendarUnit|NSMinuteCalendarUnit;
//    NSDateComponents *openComponents = [calendar components:units fromDate:openDate];
//    NSDateComponents *closeComponents = [calendar components:units fromDate:closeDate];
//    
//    NSString *openString = [NSString stringWithFormat:@"%02li:%02li", (long)openComponents.hour, (long)openComponents.minute];
//    NSString *closeString = [NSString stringWithFormat:@"%02li:%02li", (long)closeComponents.hour, (long)closeComponents.minute];
//
//    NSLog(@"Open: (%@) %li:%02li", openString, (long)openComponents.hour, (long)openComponents.minute);
//    NSLog(@"Open: (%@) %li:%02li", closeString, (long)closeComponents.hour, (long)closeComponents.minute);
//    
//    XCTAssert(openComponents.hour == 13);
//    XCTAssert(openComponents.minute == 0);
//    XCTAssert(closeComponents.hour == 18);
//    XCTAssert(closeComponents.minute == 0);
//}
//
//- (void)testParsingUserModel {
//    // Creates response
//    NSDictionary *meta = @{};
//    NSArray *users = @[
//                       [MockData userForId:@1 withLinks:nil]
//                       ];
//    NSDictionary *linked = @{
//                             };
//    NSDictionary *jsonResponse = @{
//                                   @"meta" : meta,
//                                   @"users" : users,
//                                   @"linked" : linked
//                                   };
//    
//    // Parses
//    JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:jsonResponse];
//    
//    NSArray *userModels = [jsonApi resourcesForKey:@"users"];
//    for (NSInteger i = 0; i < userModels.count; ++i) {
//        
//        // Gets model and dictionary from response
//        UserModel *userModel = [userModels objectAtIndex:i];
//        NSDictionary *userFromResposne = [users objectAtIndex:i];
//        
//        // Assert id
//        NSNumber *ID = [userFromResposne objectForKey:@"id"];
//        XCTAssertEqualObjects(userModel.ID, ID, @"Should equal %@", ID);
//        
//        // Assert email
//        NSString *email = [userFromResposne objectForKey:@"email"];
//        XCTAssertEqualObjects(userModel.email, email, @"Should equal %@", email);
//        
//        // Assert role
//        NSString *role = [userFromResposne objectForKey:@"role"];
//        XCTAssertEqualObjects(userModel.role, role, @"Should equal %@", role);
//        
//        // Assert name
//        NSString *name = [userFromResposne objectForKey:@"name"];
//        XCTAssertEqualObjects(userModel.name, name, @"Should equal %@", name);
//        
//        // Assert birthday
//        NSString *birthday = [userFromResposne objectForKey:@"birthday"];
//        
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//        NSString *birthdayAsString = [dateFormatter stringFromDate: userModel.birthday];
//        XCTAssertEqualObjects(birthdayAsString, birthday, @"Should equal %@", birthday);
//        
//        // Assert settings
//        NSString *settings = [userFromResposne objectForKey:@"settings"];
//        XCTAssertEqualObjects(userModel.settings, settings, @"Should equal %@", settings);
//        
//    }
//}
//
//- (void)testParsingDrinkModel {
//    // Creates response
//    NSDictionary *meta = @{};
//    NSArray *drinks = @[
//                        [MockData drinkForId:@1 withLinks:@{@"spot":@1,@"slider_templates":@[@1,@2,@3],@"drink_type":@1}]
//                        ];
//    NSArray *linkedSliderTemplates = @[
//                             [MockData sliderTemplateForId:@1 withLinks:nil],
//                             [MockData sliderTemplateForId:@2 withLinks:nil],
//                             [MockData sliderTemplateForId:@3 withLinks:nil]
//                             ];
//    NSArray *linkedSpots = @[
//                            [MockData spotForId:@1 withLinks:nil]
//                             ];
//    NSArray *linkedDrinkTypes = @[
//                             [MockData drinkTypeForId:@1 withLinks:nil]
//                             ];
//    NSDictionary *linked = @{
//                             @"slider_templates" : linkedSliderTemplates,
//                             @"spots" : linkedSpots,
//                             @"drink_types" : linkedDrinkTypes
//                             };
//    NSDictionary *jsonResponse = @{
//                                   @"meta" : meta,
//                                   @"drinks" : drinks,
//                                   @"linked" : linked
//                                   };
//    
//    // ParsesJSONAPIResourceLinker
//    JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:jsonResponse];
//    
//    NSString *linkedType = [[JSONAPIResourceLinker defaultInstance] linkedType:@"drinks"];
//    JSONAPIResourceModeler *modeler = [JSONAPIResourceModeler defaultInstance];
//    Class c = [modeler resourceForLinkedType:linkedType];
//    XCTAssert(c != nil, @"Modeled class must be defined");
//    NSString *type = NSStringFromClass(c);
//    NSLog(@"type: %@", type);
//    
//    NSArray *drinkModels = [jsonApi resourcesForKey:@"drinks"];
//    for (NSInteger i = 0; i < drinkModels.count; ++i) {
//        
//        // Gets model and dictionary from response
//        id model = [drinkModels objectAtIndex:i];
//        XCTAssert([model isKindOfClass:[DrinkModel class]], @"Model must be a DrinkModel");
//        
//        DrinkModel *drinkModel = (DrinkModel *)model;
//        NSDictionary *drinkFromResponse = [drinks objectAtIndex:i];
//        
//        // Assert id
//        NSNumber *ID = [drinkFromResponse objectForKey:@"id"];
//        XCTAssertEqualObjects(drinkModel.ID, ID, @"Should equal %@", ID);
//        
//        // Assert name
//        NSString *name = [drinkFromResponse objectForKey:@"name"];
//        NSLog(@"'%@' == '%@'", name, drinkModel.name);
//        XCTAssertEqualObjects(drinkModel.name, name, @"Should equal %@", name);
//        
//        // Assert description
//        NSString *description = [drinkFromResponse objectForKey:@"description"];
//        XCTAssertEqualObjects(drinkModel.descriptionOfDrink, description, @"Should equal %@", description);
//        
//        // Assert alcohol by volume
//        NSNumber *alcoholByVolume = [drinkFromResponse objectForKey:@"abv"];
//        XCTAssertEqualObjects(drinkModel.abv, alcoholByVolume, @"Should equal %@", alcoholByVolume);
//        
//        // Assert style
//        NSString *style = [drinkFromResponse objectForKey:@"style"];
//        XCTAssertEqualObjects(drinkModel.style, style, @"Should equal %@", style);
//        
//        // Assert vintage
//        NSString *vintage = [drinkFromResponse objectForKey:@"vintage"];
//        XCTAssertEqualObjects(drinkModel.vintage, vintage, @"Should equal %@", vintage);
//        
//        // Assert region
//        NSString *region = [drinkFromResponse objectForKey:@"region"];
//        XCTAssertEqualObjects(drinkModel.region, region, @"Should equal %@", region);
//        
//        // Assert recipe
//        NSString *recipe = [drinkFromResponse objectForKey:@"recipe"];
//        XCTAssertEqualObjects(drinkModel.recipeOfDrink, recipe, @"Should equal %@", recipe);
//        
//        // Assert spot
//        NSDictionary *linkedSpot = nil;
//        NSNumber *spotId = [[drinkFromResponse objectForKey:@"links"] objectForKey:@"spot"];
//        for (NSDictionary *dict in [linked objectForKey:@"spots"]) {
//            // Finds the linked dictionary that matches the linked id
//            if ([[dict objectForKey:@"id"] isEqualToNumber:spotId] == YES) {
//                linkedSpot = dict;
//                break;
//            }
//        }
//        XCTAssertEqualObjects(drinkModel.spot.ID, spotId, @"Should equal %@", spotId);
//        
//        // Assert drink type
//        NSDictionary *linkedDrinkType = nil;
//        NSNumber *drinkTypeId = [[drinkFromResponse objectForKey:@"links"] objectForKey:@"drink_type"];
//        for (NSDictionary *dict in [linked objectForKey:@"drink_types"]) {
//            // Finds the linked dictionary that matches the linked id
//            if ([[dict objectForKey:@"id"] isEqualToNumber:drinkTypeId] == YES) {
//                linkedDrinkType = dict;
//                break;
//            }
//        }
//        XCTAssertEqualObjects(drinkModel.drinkType.ID, drinkTypeId, @"Should equal %@", drinkTypeId);
//        
//        // Assert slider templates
//        NSArray *sliderTemplateIds = [[drinkFromResponse objectForKey:@"links"] objectForKey:@"slider_templates"];
//        NSArray *sliderTemplateModelIds = [drinkModel.sliderTemplates valueForKey:@"ID"];
//        
//        sliderTemplateIds = [sliderTemplateIds sortedArrayUsingSelector:@selector(compare:)];
//        sliderTemplateModelIds = [sliderTemplateModelIds sortedArrayUsingSelector:@selector(compare:)];
//        
//        XCTAssert([sliderTemplateIds isEqualToArray:sliderTemplateModelIds], @"Should equal %@", sliderTemplateIds);
//        
//        // Asset slider template model info
//        for (SliderTemplateModel *sliderTemplateModel in drinkModel.sliderTemplates) {
//            NSDictionary *linkedSliderTemplate = nil;
//            for (NSDictionary *dict in [linked objectForKey:@"slider_templates"]) {
//                // Finds the linked dictionary that matches the linked id
//                if ([[dict objectForKey:@"id"] isEqualToNumber:sliderTemplateModel.ID] == YES) {
//                    linkedSliderTemplate = dict;
//                    break;
//                }
//            }
//            
//            // Asset name
//            NSString *name = [linkedSliderTemplate objectForKey:@"name"];
//            XCTAssertEqualObjects(sliderTemplateModel.name, name, @"Should equal %@", name);
//            
//            // Asset min label
//            NSString *minLabel = [linkedSliderTemplate objectForKey:@"min_label"];
//            XCTAssertEqualObjects(sliderTemplateModel.minLabel, minLabel, @"Should equal %@", minLabel);
//            
//            // Asset max label
//            NSString *maxLabel = [linkedSliderTemplate objectForKey:@"max_label"];
//            XCTAssertEqualObjects(sliderTemplateModel.maxLabel, maxLabel, @"Should equal %@", maxLabel);
//            
//            // Asset default value
//            NSString *defaultValue = [linkedSliderTemplate objectForKey:@"default_value"];
//            XCTAssertEqualObjects(sliderTemplateModel.defaultValue, defaultValue, @"Should equal %@", defaultValue);
//            
//            // Asset required
//            BOOL required = [[linkedSliderTemplate objectForKey:@"required"] boolValue];
//            XCTAssert(sliderTemplateModel.required == required, @"Should equal %@", (required ? @"true" : @"false"));
//        }
//    }
//}
//
//- (void)testParsingSpotModel {
//    // Creates response
//    NSDictionary *meta = @{};
//    NSArray *spots = @[
//                        [MockData spotForId:@1 withLinks:@{@"slider_templates":@[@1,@2,@3]}]
//                        ];
//    NSArray *linkedSliderTemplates = @[
//                                       [MockData sliderTemplateForId:@1 withLinks:nil],
//                                       [MockData sliderTemplateForId:@2 withLinks:nil],
//                                       [MockData sliderTemplateForId:@3 withLinks:nil]
//                                       ];
//    NSDictionary *linked = @{
//                             @"slider_templates" : linkedSliderTemplates
//                             };
//    NSDictionary *jsonResponse = @{
//                                   @"meta" : meta,
//                                   @"spots" : spots,
//                                   @"linked" : linked
//                                   };
//    
//    // Parses
//    JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:jsonResponse];
//    
//    NSArray *spotModels = [jsonApi resourcesForKey:@"spots"];
//    for (NSInteger i = 0; i < spotModels.count; ++i) {
//        
//        // Gets model and dictionary from response
//        SpotModel *spotModel = [spotModels objectAtIndex:i];
//        NSDictionary *spotFromResposne = [spots objectAtIndex:i];
//        
//        // Assert id
//        NSNumber *ID = [spotFromResposne objectForKey:@"id"];
//        XCTAssertEqualObjects(spotModel.ID, ID, @"Should equal %@", ID);
//        
//        // Assert name
//        NSString *name = [spotFromResposne objectForKey:@"name"];
//        XCTAssertEqualObjects(spotModel.name, name, @"Should equal %@", name);
//        
//        // Assert address
//        NSString *address = [spotFromResposne objectForKey:@"address"];
//        XCTAssertEqualObjects(spotModel.address, address, @"Should equal %@", address);
//        
//        // Assert phone number
//        NSString *phoneNumber = [spotFromResposne objectForKey:@"phone_number"];
//        XCTAssertEqualObjects(spotModel.phoneNumber, phoneNumber, @"Should equal %@", phoneNumber);
//        
//        // Assert latitude
//        NSString *latitude = [spotFromResposne objectForKey:@"latitude"];
//        XCTAssertEqualObjects(spotModel.latitude, latitude, @"Should equal %@", latitude);
//        
//        // Assert longitude
//        NSString *longitude = [spotFromResposne objectForKey:@"longitude"];
//        XCTAssertEqualObjects(spotModel.longitude, longitude, @"Should equal %@", longitude);
//        
//        // Assert hours of operation
//        NSArray *hoursOfOperation = [spotFromResposne objectForKey:@"hours_of_operation"];
//        XCTAssertEqualObjects(spotModel.hoursOfOperation, hoursOfOperation, @"Should equal %@", hoursOfOperation);
//        
//        // Assert slider templates
//        NSArray *sliderTemplateIds = [[spotFromResposne objectForKey:@"links"] objectForKey:@"slider_templates"];
//        NSArray *sliderTemplateModelIds = [spotModel.sliderTemplates valueForKey:@"ID"];
//        
//        sliderTemplateIds = [sliderTemplateIds sortedArrayUsingSelector:@selector(compare:)];
//        sliderTemplateModelIds = [sliderTemplateModelIds sortedArrayUsingSelector:@selector(compare:)];
//        
//        XCTAssert([sliderTemplateIds isEqualToArray:sliderTemplateModelIds], @"Should equal %@", sliderTemplateIds);
//        
//        // Asset slider template model info
//        for (SliderTemplateModel *sliderTemplateModel in spotModel.sliderTemplates) {
//            NSDictionary *linkedSliderTemplate = nil;
//            for (NSDictionary *dict in [linked objectForKey:@"slider_templates"]) {
//                // Finds the linked dictionary that matches the linked id
//                if ([[dict objectForKey:@"id"] isEqualToNumber:sliderTemplateModel.ID] == YES) {
//                    linkedSliderTemplate = dict;
//                    break;
//                }
//            }
//            
//            // Asset name
//            NSString *name = [linkedSliderTemplate objectForKey:@"name"];
//            XCTAssertEqualObjects(sliderTemplateModel.name, name, @"Should equal %@", name);
//            
//            // Asset min label
//            NSString *minLabel = [linkedSliderTemplate objectForKey:@"min_label"];
//            XCTAssertEqualObjects(sliderTemplateModel.minLabel, minLabel, @"Should equal %@", minLabel);
//            
//            // Asset max label
//            NSString *maxLabel = [linkedSliderTemplate objectForKey:@"max_label"];
//            XCTAssertEqualObjects(sliderTemplateModel.maxLabel, maxLabel, @"Should equal %@", maxLabel);
//            
//            // Asset default value
//            NSString *defaultValue = [linkedSliderTemplate objectForKey:@"default_value"];
//            XCTAssertEqualObjects(sliderTemplateModel.defaultValue, defaultValue, @"Should equal %@", defaultValue);
//            
//            // Asset required
//            BOOL required = [[linkedSliderTemplate objectForKey:@"required"] boolValue];
//            XCTAssert(sliderTemplateModel.required == required, @"Should equal %@", (required ? @"true" : @"false"));
//        }
//        
//    }
//}
//
//- (void)testParsingSliderTemplateModel {
//    // Creates response
//    NSDictionary *meta = @{};
//    NSArray *sliderTemplates = @[
//                         [MockData sliderTemplateForId:@1 withLinks:nil]
//                         ];
//    NSDictionary *linked = @{
//                             };
//    NSDictionary *jsonResponse = @{
//                                   @"meta" : meta,
//                                   @"slider_templates" : sliderTemplates,
//                                   @"linked" : linked
//                                   };
//    
//    // Parses
//    JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:jsonResponse];
//    
//    NSArray *sliderTemplateModels = [jsonApi resourcesForKey:@"slider_templates"];
//    for (NSInteger i = 0; i < sliderTemplateModels.count; ++i) {
//        
//        // Gets model and dictionary from response
//        SliderTemplateModel *sliderTemplateModel = [sliderTemplateModels objectAtIndex:i];
//        NSDictionary *sliderTemplateFromResposne = [sliderTemplates objectAtIndex:i];
//        
//        // Assert id
//        NSNumber *ID = [sliderTemplateFromResposne objectForKey:@"id"];
//        XCTAssertEqualObjects(sliderTemplateModel.ID, ID, @"Should equal %@", ID);
//        
//        // Asset name
//        NSString *name = [sliderTemplateFromResposne objectForKey:@"name"];
//        XCTAssertEqualObjects(sliderTemplateModel.name, name, @"Should equal %@", name);
//        
//        // Asset min label
//        NSString *minLabel = [sliderTemplateFromResposne objectForKey:@"min_label"];
//        XCTAssertEqualObjects(sliderTemplateModel.minLabel, minLabel, @"Should equal %@", minLabel);
//        
//        // Asset max label
//        NSString *maxLabel = [sliderTemplateFromResposne objectForKey:@"max_label"];
//        XCTAssertEqualObjects(sliderTemplateModel.maxLabel, maxLabel, @"Should equal %@", maxLabel);
//        
//        // Asset default value
//        NSString *defaultValue = [sliderTemplateFromResposne objectForKey:@"default_value"];
//        XCTAssertEqualObjects(sliderTemplateModel.defaultValue, defaultValue, @"Should equal %@", defaultValue);
//        
//        // Asset required
//        BOOL required = [[sliderTemplateFromResposne objectForKey:@"required"] boolValue];
//        XCTAssert(sliderTemplateModel.required == required, @"Should equal %@", (required ? @"true" : @"false"));
//    }
//}
//
//- (void)testParsingSliderModel {
//    // Creates response
//    NSDictionary *meta = @{};
//    NSArray *sliders = @[
//                        [MockData sliderForId:@1 withLinks:@{@"slider_template":@1}]
//                        ];
//    NSArray *linkedSliderTemplates = @[
//                                       [MockData sliderTemplateForId:@1 withLinks:nil],
//                                       ];
//    NSDictionary *linked = @{
//                             @"slider_templates" : linkedSliderTemplates
//                             };
//    NSDictionary *jsonResponse = @{
//                                   @"meta" : meta,
//                                   @"sliders" : sliders,
//                                   @"linked" : linked
//                                   };
//    
//    // Parses
//    JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:jsonResponse];
//    
//    NSArray *sliderModels = [jsonApi resourcesForKey:@"sliders"];
//    for (NSInteger i = 0; i < sliderModels.count; ++i) {
//        
//        // Gets model and dictionary from response
//        SliderModel *sliderModel = [sliderModels objectAtIndex:i];
//        NSDictionary *sliderFromResposne = [sliders objectAtIndex:i];
//        
//        // Assert id
//        NSNumber *ID = [sliderFromResposne objectForKey:@"id"];
//        XCTAssertEqualObjects(sliderModel.ID, ID, @"Should equal %@", ID);
//        
//        // Assert slider templates
//        XCTAssertNotNil(sliderModel.sliderTemplate, @"Should not be nil");
//
//        // Find linked slider templtes
//        NSDictionary *linkedSliderTemplate = nil;
//        NSNumber *sliderTemplateId = [[sliderFromResposne objectForKey:@"links"] objectForKey:@"slider_template"];
//        for (NSDictionary *dict in [linked objectForKey:@"slider_templates"]) {
//            // Finds the linked dictionary that matches the linked id
//            if ([[dict objectForKey:@"id"] isEqualToNumber:sliderTemplateId] == YES) {
//                linkedSliderTemplate = dict;
//                break;
//            }
//        }
//        
//        // Asset name
//        NSString *name = [linkedSliderTemplate objectForKey:@"name"];
//        XCTAssertEqualObjects(sliderModel.sliderTemplate.name, name, @"Should equal %@", name);
//        
//        // Asset min label
//        NSString *minLabel = [linkedSliderTemplate objectForKey:@"min_label"];
//        XCTAssertEqualObjects(sliderModel.sliderTemplate.minLabel, minLabel, @"Should equal %@", minLabel);
//        
//        // Asset max label
//        NSString *maxLabel = [linkedSliderTemplate objectForKey:@"max_label"];
//        XCTAssertEqualObjects(sliderModel.sliderTemplate.maxLabel, maxLabel, @"Should equal %@", maxLabel);
//        
//        // Asset default value
//        NSString *defaultValue = [linkedSliderTemplate objectForKey:@"default_value"];
//        XCTAssertEqualObjects(sliderModel.sliderTemplate.defaultValue, defaultValue, @"Should equal %@", defaultValue);
//        
//        // Asset required
//        BOOL required = [[linkedSliderTemplate objectForKey:@"required"] boolValue];
//        XCTAssert(sliderModel.sliderTemplate.required == required, @"Should equal %@", (required ? @"true" : @"false"));
//    }
//}
//
//- (void)testParsingReviewModel {
//    // Creates response
//    NSDictionary *meta = @{};
//    NSArray *reviews = @[
//                         [MockData reviewForId:@1 withLinks:@{@"drink":@1,@"spot":@1,@"user":@1,@"sliders":@[@1,@2,@3]}]
//                        ];
//    NSArray *linkedDrinks = @[
//                              [MockData drinkForId:@1 withLinks:nil]
//                              ];
//    NSArray *linkedSpots = @[
//                             [MockData spotForId:@1 withLinks:nil]
//                             ];
//    NSArray *linkedUsers = @[
//                             [MockData userForId:@1 withLinks:nil]
//                             ];
//    NSArray *linkedSliders = @[
//                             [MockData sliderForId:@1 withLinks:@{@"slider_template":@1}],
//                             [MockData sliderForId:@2 withLinks:@{@"slider_template":@2}],
//                             [MockData sliderForId:@3 withLinks:@{@"slider_template":@3}]
//                             ];
//    NSArray *linkedSliderTemplates = @[
//                               [MockData sliderTemplateForId:@1 withLinks:nil],
//                               [MockData sliderTemplateForId:@2 withLinks:nil],
//                               [MockData sliderTemplateForId:@3 withLinks:nil]
//                               ];
//    NSDictionary *linked = @{
//                             @"drinks" : linkedDrinks,
//                             @"users" : linkedUsers,
//                             @"spots" : linkedSpots,
//                             @"sliders" : linkedSliders,
//                             @"slider_templates" : linkedSliderTemplates
//                             };
//    NSDictionary *jsonResponse = @{
//                                   @"meta" : meta,
//                                   @"reviews" : reviews,
//                                   @"linked" : linked
//                                   };
//    
//    // Parses
//    JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:jsonResponse];
//    
//    NSArray *reviewModels = [jsonApi resourcesForKey:@"reviews"];
//    for (NSInteger i = 0; i < reviewModels.count; ++i) {
//        
//        // Gets model and dictionary from response
//        id model = [reviewModels objectAtIndex:i];
//        XCTAssert([model isKindOfClass:[ReviewModel class]], @"ReviewModel class is expected");
//        ReviewModel *reviewModel = (ReviewModel *)model;
//        NSDictionary *reviewFromResposne = [reviews objectAtIndex:i];
//        
//        // Assert id
//        NSNumber *ID = [reviewFromResposne objectForKey:@"id"];
//        XCTAssertEqualObjects(reviewModel.ID, ID, @"Should equal %@", ID);
//        
//        // Assert rating
//        NSNumber *rating = [reviewFromResposne objectForKey:@"rating"];
//        XCTAssertEqualObjects(reviewModel.rating, rating, @"Should equal %@", rating);
//        
//        // Assert drink
//        NSDictionary *linkedDrink = nil;
//        NSNumber *drinkId = [[reviewFromResposne objectForKey:@"links"] objectForKey:@"drink"];
//        for (NSDictionary *dict in [linked objectForKey:@"drinks"]) {
//            // Finds the linked dictionary that matches the linked id
//            if ([[dict objectForKey:@"id"] isEqualToNumber:drinkId] == YES) {
//                linkedDrink = dict;
//                break;
//            }
//        }
//        XCTAssertEqualObjects(reviewModel.drink.ID, drinkId, @"Should equal %@", drinkId);
//        
//        // Assert spot
//        NSDictionary *linkedSpot = nil;
//        NSNumber *spotId = [[reviewFromResposne objectForKey:@"links"] objectForKey:@"spot"];
//        for (NSDictionary *dict in [linked objectForKey:@"spots"]) {
//            // Finds the linked dictionary that matches the linked id
//            if ([[dict objectForKey:@"id"] isEqualToNumber:spotId] == YES) {
//                linkedSpot = dict;
//                break;
//            }
//        }
//        XCTAssertEqualObjects(reviewModel.spot.ID, spotId, @"Should equal %@", spotId);
//        
//        // Assert user
//        NSDictionary *linkedUser = nil;
//        NSNumber *userId = [[reviewFromResposne objectForKey:@"links"] objectForKey:@"user"];
//        for (NSDictionary *dict in [linked objectForKey:@"users"]) {
//            // Finds the linked dictionary that matches the linked id
//            if ([[dict objectForKey:@"id"] isEqualToNumber:userId] == YES) {
//                linkedUser = dict;
//                break;
//            }
//        }
//        XCTAssertEqualObjects(reviewModel.user.ID, userId, @"Should equal %@", userId);
//        
//        // Assert sliders
//        NSArray *sliderIds = [[reviewFromResposne objectForKey:@"links"] objectForKey:@"sliders"];
//        NSArray *sliderModelIds = [reviewModel.sliders valueForKey:@"ID"];
//        
//        sliderIds = [sliderIds sortedArrayUsingSelector:@selector(compare:)];
//        sliderModelIds = [sliderModelIds sortedArrayUsingSelector:@selector(compare:)];
//        
//        XCTAssert([sliderIds isEqualToArray:sliderModelIds], @"Should equal %@", sliderIds);
//        
//        // Asset slider model info
//        for (SliderModel *sliderModel in reviewModel.sliders) {
//            NSDictionary *linkedSlider = nil;
//            for (NSDictionary *dict in [linked objectForKey:@"sliders"]) {
//                // Finds the linked dictionary that matches the linked id
//                if ([[dict objectForKey:@"id"] isEqualToNumber:sliderModel.ID] == YES) {
//                    linkedSlider = dict;
//                    break;
//                }
//            }
//            
//            NSLog(@"MOO1 - %@", sliderModel.sliderTemplate);
//            
//            NSDictionary *linkedSliderTemplate = nil;
//            for (NSDictionary *dict in [linked objectForKey:@"slider_templates"]) {
//                // Finds the linked dictionary that matches the linked id
//                if ([[dict objectForKey:@"id"] isEqualToNumber:sliderModel.sliderTemplate.ID] == YES) {
//                    linkedSliderTemplate = dict;
//                    break;
//                }
//            }
//            
//            NSLog(@"MOO2 - %@", linkedSliderTemplate);
//            
//            // Asset name
//            NSNumber *value = [linkedSlider objectForKey:@"value"];
//            XCTAssertEqualObjects(sliderModel.value, value, @"Should equal %@", value);
//            
//            // Asset name
//            NSString *name = [linkedSliderTemplate objectForKey:@"name"];
//            XCTAssertEqualObjects(sliderModel.sliderTemplate.name, name, @"Should equal %@", name);
//            
//            // Asset min label
//            NSString *minLabel = [linkedSliderTemplate objectForKey:@"min_label"];
//            XCTAssertEqualObjects(sliderModel.sliderTemplate.minLabel, minLabel, @"Should equal %@", minLabel);
//            
//            // Asset max label
//            NSString *maxLabel = [linkedSliderTemplate objectForKey:@"max_label"];
//            XCTAssertEqualObjects(sliderModel.sliderTemplate.maxLabel, maxLabel, @"Should equal %@", maxLabel);
//            
//            // Asset default value
//            NSString *defaultValue = [linkedSliderTemplate objectForKey:@"default_value"];
//            XCTAssertEqualObjects(sliderModel.sliderTemplate.defaultValue, defaultValue, @"Should equal %@", defaultValue);
//            
//            // Asset required
//            BOOL required = [[linkedSliderTemplate objectForKey:@"required"] boolValue];
//            XCTAssert(sliderModel.sliderTemplate.required == required, @"Should equal %@", (required ? @"true" : @"false"));
//        }
//    }
//}

@end
