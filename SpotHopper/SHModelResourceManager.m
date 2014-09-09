//
//  SHEnums.m
//  SpotHopper
//
//  Created by Brennan Stehling on 8/19/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHModelResourceManager.h"

#import <JSONAPI/JSONAPI.h>

#import "AverageReviewModel.h"
#import "BaseAlcoholModel.h"
#import "CheckInModel.h"
#import "DrinkModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubTypeModel.h"
#import "DrinkListModel.h"
#import "ErrorModel.h"
#import "ImageModel.h"
#import "LiveSpecialModel.h"
#import "MenuItemModel.h"
#import "MenuTypeModel.h"
#import "PriceModel.h"
#import "ReviewModel.h"
#import "SizeModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"
#import "SpotModel.h"
#import "SpotTypeModel.h"
#import "SpotListModel.h"
#import "SpotListMoodModel.h"
#import "SpecialModel.h"
#import "LikeModel.h"
#import "UserModel.h"

@implementation SHModelResourceManager

#pragma mark - Public
#pragma mark -

+ (void)prepareResources {
    [self linkResources];
    [self mapModels];
    [self registerFormatters];
}

#pragma mark - Private
#pragma mark -

// Initializes resource linking for JSONAPI
+ (void)linkResources {
    JSONAPIResourceLinker *linker = [JSONAPIResourceLinker defaultInstance];
    [linker link:@"average_review" toLinkedType:@"average_reviews"];
    [linker link:@"base_alcohol" toLinkedType:@"base_alcohols"];
    [linker link:@"checkin" toLinkedType:@"checkins"];
    [linker link:@"drink" toLinkedType:@"drinks"];
    [linker link:@"drink_type" toLinkedType:@"drink_types"];
    [linker link:@"drink_subtype" toLinkedType:@"drink_subtypes"];
    [linker link:@"drink_list" toLinkedType:@"drink_lists"];
    [linker link:@"image" toLinkedType:@"images"];
    [linker link:@"live_special" toLinkedType:@"live_specials"];
    [linker link:@"menu_item" toLinkedType:@"menu_items"];
    [linker link:@"menu_type" toLinkedType:@"menu_types"];
    [linker link:@"price" toLinkedType:@"prices"];
    [linker link:@"review" toLinkedType:@"reviews"];
    [linker link:@"size" toLinkedType:@"sizes"];
    [linker link:@"slider" toLinkedType:@"sliders"];
    [linker link:@"slider_template" toLinkedType:@"slider_templates"];
    [linker link:@"spot" toLinkedType:@"spots"];
    [linker link:@"spot_type" toLinkedType:@"spot_types"];
    [linker link:@"spot_list" toLinkedType:@"spot_lists"];
    [linker link:@"spot_list_mood" toLinkedType:@"spot_list_moods"];
    [linker link:@"daily_special" toLinkedType:@"daily_specials"];
    [linker link:@"likes" toLinkedType:@"likes"];
    [linker link:@"user" toLinkedType:@"users"];
}

// Initializes model linking for JSONAPI
+ (void)mapModels {
    JSONAPIResourceModeler *modeler = [JSONAPIResourceModeler defaultInstance];
    [modeler useResource:[AverageReviewModel class] toLinkedType:@"average_reviews"];
    [modeler useResource:[BaseAlcoholModel class] toLinkedType:@"base_alcohols"];
    [modeler useResource:[CheckInModel class] toLinkedType:@"checkins"];
    [modeler useResource:[DrinkModel class] toLinkedType:@"drinks"];
    [modeler useResource:[DrinkTypeModel class] toLinkedType:@"drink_types"];
    [modeler useResource:[DrinkSubTypeModel class] toLinkedType:@"drink_subtypes"];
    [modeler useResource:[DrinkListModel class] toLinkedType:@"drink_lists"];
    [modeler useResource:[ErrorModel class] toLinkedType:@"errors"];
    [modeler useResource:[ImageModel class] toLinkedType:@"images"];
    [modeler useResource:[LiveSpecialModel class] toLinkedType:@"live_specials"];
    [modeler useResource:[MenuItemModel class] toLinkedType:@"menu_items"];
    [modeler useResource:[MenuTypeModel class] toLinkedType:@"menu_types"];
    [modeler useResource:[PriceModel class] toLinkedType:@"prices"];
    [modeler useResource:[ReviewModel class] toLinkedType:@"reviews"];
    [modeler useResource:[SizeModel class] toLinkedType:@"sizes"];
    [modeler useResource:[SliderModel class] toLinkedType:@"sliders"];
    [modeler useResource:[SliderTemplateModel class] toLinkedType:@"slider_templates"];
    [modeler useResource:[SpotModel class] toLinkedType:@"spots"];
    [modeler useResource:[SpotTypeModel class] toLinkedType:@"spot_types"];
    [modeler useResource:[SpotListModel class] toLinkedType:@"spot_lists"];
    [modeler useResource:[SpotListMoodModel class] toLinkedType:@"spot_list_moods"];
    [modeler useResource:[SpotListModel class] toLinkedType:@"spot_lists"];
    [modeler useResource:[SpecialModel class] toLinkedType:@"daily_specials"];
    [modeler useResource:[SpecialModel class] toLinkedType:@"specials"];
    [modeler useResource:[LikeModel class] toLinkedType:@"likes"];
    [modeler useResource:[UserModel class] toLinkedType:@"users"];
}

+ (void)registerFormatters {
    NSDateFormatter *dateFormatterSeconds = [[NSDateFormatter alloc] init];
    [dateFormatterSeconds setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatterSeconds setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSDateFormatter *dateFormatterMilliseconds = [[NSDateFormatter alloc] init];
    [dateFormatterMilliseconds setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatterMilliseconds setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    JSONAPIResourceFormatter *formatter = [JSONAPIResourceFormatter defaultInstance];
    
    // Date
    [formatter registerFormat:@"Date" withBlock:^id(id jsonValue) {
        NSDate *date = nil;
        NSError *error = nil;
        
        if ([jsonValue isKindOfClass:[NSString class]]) {
            NSString *dateString = (NSString *)jsonValue;
            if (dateString.length) {
                if (![dateFormatterSeconds getObjectValue:&date forString:jsonValue range:nil error:&error]) {
                    // if it fails with seconds try milliseconds
                    if (![dateFormatterMilliseconds getObjectValue:&date forString:jsonValue range:nil error:&error]) {
                        DebugLog(@"Date '%@' could not be parsed: %@", jsonValue, error);
                    }
                }
            }
        }
        
        return date;
    }];
    
    // ShortDate
    [formatter registerFormat:@"ShortDate" withBlock:^id(id jsonValue) {
        NSString *string = (NSString *)jsonValue;
            NSDate *date = nil;
            if (string.length > 0) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                
                NSError *error = nil;
                if (![dateFormatter getObjectValue:&date forString:string range:nil error:&error]) {
                }
            }
            return date;
    }];
    
    // Time
    [formatter registerFormat:@"Time" withBlock:^id(id jsonValue) {
        NSDate *date = nil;
        
        if ([jsonValue isKindOfClass:[NSString class]]) {
            NSString *timeString = (NSString *)jsonValue;
            if (timeString.length) {
                
                // sample: 19:00 (seconds is ignored)
                date = [NSDate date];
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSCalendarUnit units = NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSTimeZoneCalendarUnit;
                NSDateComponents *components = [calendar components:units fromDate:date];
                
                NSArray *parts = [timeString componentsSeparatedByString:@":"];
                if (parts.count >= 2) {
                    [components setHour:[parts[0] integerValue]];
                    [components setMinute:[parts[1] integerValue]];
                }
                
                date = [calendar dateFromComponents:components];
            }
        }
        
        return date;
    }];
    
    // Weekday
    [formatter registerFormat:@"Weekday" withBlock:^id(id jsonValue) {
        NSInteger weekday = [jsonValue integerValue];
        
        return [NSNumber numberWithInteger:weekday];
    }];
    
    // Time Interval
    [formatter registerFormat:@"TimeInterval" withBlock:^id(id jsonValue) {
        NSInteger minutes = [jsonValue integerValue];
        
        // convert to seconds
        return [NSNumber numberWithInteger:minutes*60];
    }];
}

@end
