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
    [self useResources];
    [self registerFormatters];
}

#pragma mark - Private
#pragma mark -

// Initializes resource linking for JSONAPI
+ (void)linkResources {
    [JSONAPIResourceLinker link:@"average_review" toLinkedType:@"average_reviews"];
    [JSONAPIResourceLinker link:@"base_alcohol" toLinkedType:@"base_alcohols"];
    [JSONAPIResourceLinker link:@"checkin" toLinkedType:@"checkins"];
    [JSONAPIResourceLinker link:@"drink" toLinkedType:@"drinks"];
    [JSONAPIResourceLinker link:@"drink_type" toLinkedType:@"drink_types"];
    [JSONAPIResourceLinker link:@"drink_subtype" toLinkedType:@"drink_subtypes"];
    [JSONAPIResourceLinker link:@"drink_list" toLinkedType:@"drink_lists"];
    [JSONAPIResourceLinker link:@"image" toLinkedType:@"images"];
    [JSONAPIResourceLinker link:@"live_special" toLinkedType:@"live_specials"];
    [JSONAPIResourceLinker link:@"menu_item" toLinkedType:@"menu_items"];
    [JSONAPIResourceLinker link:@"menu_type" toLinkedType:@"menu_types"];
    [JSONAPIResourceLinker link:@"price" toLinkedType:@"prices"];
    [JSONAPIResourceLinker link:@"review" toLinkedType:@"reviews"];
    [JSONAPIResourceLinker link:@"size" toLinkedType:@"sizes"];
    [JSONAPIResourceLinker link:@"slider" toLinkedType:@"sliders"];
    [JSONAPIResourceLinker link:@"slider_template" toLinkedType:@"slider_templates"];
    [JSONAPIResourceLinker link:@"spot" toLinkedType:@"spots"];
    [JSONAPIResourceLinker link:@"spot_type" toLinkedType:@"spot_types"];
    [JSONAPIResourceLinker link:@"spot_list" toLinkedType:@"spot_lists"];
    [JSONAPIResourceLinker link:@"spot_list_mood" toLinkedType:@"spot_list_moods"];
    [JSONAPIResourceLinker link:@"daily_special" toLinkedType:@"daily_specials"];
    [JSONAPIResourceLinker link:@"likes" toLinkedType:@"likes"];
    [JSONAPIResourceLinker link:@"user" toLinkedType:@"users"];
}

// Initializes model linking for JSONAPI
+ (void)useResources {
    [JSONAPIResourceModeler useResource:[AverageReviewModel class] toLinkedType:@"average_reviews"];
    [JSONAPIResourceModeler useResource:[BaseAlcoholModel class] toLinkedType:@"base_alcohols"];
    [JSONAPIResourceModeler useResource:[CheckInModel class] toLinkedType:@"checkins"];
    [JSONAPIResourceModeler useResource:[DrinkModel class] toLinkedType:@"drinks"];
    [JSONAPIResourceModeler useResource:[DrinkTypeModel class] toLinkedType:@"drink_types"];
    [JSONAPIResourceModeler useResource:[DrinkSubTypeModel class] toLinkedType:@"drink_subtypes"];
    [JSONAPIResourceModeler useResource:[DrinkListModel class] toLinkedType:@"drink_lists"];
    [JSONAPIResourceModeler useResource:[ErrorModel class] toLinkedType:@"errors"];
    [JSONAPIResourceModeler useResource:[ImageModel class] toLinkedType:@"images"];
    [JSONAPIResourceModeler useResource:[LiveSpecialModel class] toLinkedType:@"live_specials"];
    [JSONAPIResourceModeler useResource:[MenuItemModel class] toLinkedType:@"menu_items"];
    [JSONAPIResourceModeler useResource:[MenuTypeModel class] toLinkedType:@"menu_types"];
    [JSONAPIResourceModeler useResource:[PriceModel class] toLinkedType:@"prices"];
    [JSONAPIResourceModeler useResource:[ReviewModel class] toLinkedType:@"reviews"];
    [JSONAPIResourceModeler useResource:[SizeModel class] toLinkedType:@"sizes"];
    [JSONAPIResourceModeler useResource:[SliderModel class] toLinkedType:@"sliders"];
    [JSONAPIResourceModeler useResource:[SliderTemplateModel class] toLinkedType:@"slider_templates"];
    [JSONAPIResourceModeler useResource:[SpotModel class] toLinkedType:@"spots"];
    [JSONAPIResourceModeler useResource:[SpotTypeModel class] toLinkedType:@"spot_types"];
    [JSONAPIResourceModeler useResource:[SpotListModel class] toLinkedType:@"spot_lists"];
    [JSONAPIResourceModeler useResource:[SpotListMoodModel class] toLinkedType:@"spot_list_moods"];
    [JSONAPIResourceModeler useResource:[SpotListModel class] toLinkedType:@"spot_lists"];
    [JSONAPIResourceModeler useResource:[SpecialModel class] toLinkedType:@"daily_specials"];
    [JSONAPIResourceModeler useResource:[SpecialModel class] toLinkedType:@"specials"];
    [JSONAPIResourceModeler useResource:[LikeModel class] toLinkedType:@"likes"];
    [JSONAPIResourceModeler useResource:[UserModel class] toLinkedType:@"users"];
}

+ (void)registerFormatters {
    NSDateFormatter *dateFormatterSeconds = [[NSDateFormatter alloc] init];
    [dateFormatterSeconds setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatterSeconds setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSDateFormatter *dateFormatterMilliseconds = [[NSDateFormatter alloc] init];
    [dateFormatterMilliseconds setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatterMilliseconds setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    // Date
    [JSONAPIResourceFormatter registerFormat:@"Date" withBlock:^id(id jsonValue) {
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
    [JSONAPIResourceFormatter registerFormat:@"ShortDate" withBlock:^id(id jsonValue) {
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
    [JSONAPIResourceFormatter registerFormat:@"Time" withBlock:^id(id jsonValue) {
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
    [JSONAPIResourceFormatter registerFormat:@"Weekday" withBlock:^id(id jsonValue) {
        NSInteger weekday = [jsonValue integerValue];
        
        return [NSNumber numberWithInteger:weekday];
    }];
    
    // Time Interval
    [JSONAPIResourceFormatter registerFormat:@"TimeInterval" withBlock:^id(id jsonValue) {
        NSInteger minutes = [jsonValue integerValue];
        
        // convert to seconds
        return [NSNumber numberWithInteger:minutes*60];
    }];
}

@end
