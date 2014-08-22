//
//  SpecialModel.m
//  SpotHopper
//
//  Created by Brennan Stehling on 8/19/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SpecialModel.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"
#import "SpotModel.h"

#import "Tracker.h"

@implementation SpecialModel

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@ [%@]", self.ID, self.text, NSStringFromClass([self class])];
}

- (id)debugQuickLookObject {
    return self.text;
}

#pragma mark - Mappings

- (NSDictionary *)mapKeysToProperties {
    return @{
             @"text" : @"text",
             @"weekday" : @"Weekday:weekday",
             @"like_count" : @"likeCount",
             @"start_time" : @"startTimeString",
             @"duration_minutes" : @"TimeInterval:duration",
             @"links.spot" : @"spot"
            };
}

#pragma mark - Calculated Getters

- (NSString *)weekdayString {
    NSString *weekday = nil;
    
    switch (self.weekday) {
        case SHWeekdaySunday:
            weekday = @"Sunday";
            break;
        case SHWeekdayMonday:
            weekday = @"Monday";
            break;
        case SHWeekdayTuesday:
            weekday = @"Tuesday";
            break;
        case SHWeekdayWednesday:
            weekday = @"Wednesday";
            break;
        case SHWeekdayThursday:
            weekday = @"Thursday";
            break;
        case SHWeekdayFriday:
            weekday = @"Friday";
            break;
        case SHWeekdaySaturday:
            weekday = @"Saturday";
            break;
        default:
            break;
    }
    
    return weekday;
}

- (NSDate *)startTime {
    NSDate *date = nil;
    
    if (self.startTimeString.length == 8) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        date = [dateFormatter dateFromString:self.startTimeString];
    }
    
    return date;
}

- (NSDate *)endTime {
    NSDate *endTime = [self.startTime dateByAddingTimeInterval:self.duration];
    
    return endTime;
}

- (NSUInteger)durationInMinutes {
    return self.duration / 60;
}

- (NSDate *)startTimeForToday {
    return [self startTimeForDate:[NSDate date]];
}

- (NSDate *)endTimeForToday {
    return [self endTimeForDate:[NSDate date]];
}

- (NSDate *)startTimeForDate:(NSDate *)date {
    return [self adjustedDateForDate:date fromTimeString:self.startTimeString];
}

- (NSDate *)endTimeForDate:(NSDate *)date {
    NSDate *adjustedDate =  [self startTimeForDate:date];
    adjustedDate = [adjustedDate dateByAddingTimeInterval:self.duration];
    
    return adjustedDate;
}

- (NSDate *)adjustedDateForDate:(NSDate *)date fromTimeString:(NSString *)timeString {
    NSDate *adjustedDate = nil;
    
    if (timeString.length) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSCalendarUnit units = NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSTimeZoneCalendarUnit;
        NSDateComponents *components = [calendar components:units fromDate:date];
        
        NSArray *parts = [timeString componentsSeparatedByString:@":"];
        if (parts.count == 3) {
            [components setHour:[parts[0] integerValue]];
            [components setMinute:[parts[1] integerValue]];
            [components setSecond:[parts[2] integerValue]];
        }
        
        date = [calendar dateFromComponents:components];
    }
    
    return adjustedDate;
}

#pragma mark - Public

+ (SpecialModel *)specialForToday:(NSArray *)specials {
    NSDate *today = [NSDate date];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit units = NSWeekdayCalendarUnit;
    NSDateComponents *components = [calendar components:units fromDate:today];
    
    NSInteger weekday = components.weekday;
    
    for (SpecialModel *special in specials) {
        if (weekday == special.weekday) {
            return special;
        }
    }
    
    // no match
    return nil;
}

#pragma mark - Private

- (NSString *)timeStringForDate:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit units = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *components = [calendar components:units fromDate:date];
    
    return [NSString stringWithFormat:@"%02li:%02li:%02li", (long)components.hour, (long)components.minute, (long)components.second];
}

////// Service Layer //////

// Get specials for spot: /spots/{id}/daily_specials
+ (void)fetchSpecialsForSpot:(SpotModel *)spot success:(void(^)(NSArray *specials))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    NSDictionary *params = @{};
    NSDate *startDate = [NSDate date];
    NSString *path = [NSString stringWithFormat:@"/api/spots/%ld/daily_specials", (long)[spot.ID integerValue]];
    
    [[ClientSessionManager sharedClient] GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startDate];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            NSArray *specials = [jsonApi resourcesForKey:@"daily_specials"];

            // TODO: temporarily add duration
            for (SpecialModel *special in specials) {
                if (special.duration == 0) {
                    special.duration = 120*60;
                }
            }
            
            // only track a successful search
            [Tracker track:@"Fetch Specials" properties:@{ @"Duration" : [NSNumber numberWithInteger:duration] }];
            
            if (successBlock) {
                successBlock(specials);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

+ (Promise *)fetchSpecialsForSpot:(SpotModel *)spot {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self fetchSpecialsForSpot:spot success:^(NSArray *specials) {
        // Resolves promise
        [deferred resolveWith:specials];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

// Get special: /daily_specials/{id}
+ (void)fetchSpecial:(SpecialModel *)special success:(void(^)(SpecialModel *special))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    NSDictionary *params = @{};
    NSDate *startDate = [NSDate date];
    NSString *path = [NSString stringWithFormat:@"/api/daily_specials/%ld", (long)[special.ID integerValue]];
    
    [[ClientSessionManager sharedClient] GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startDate];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            NSArray *specials = [jsonApi resourcesForKey:@"daily_specials"];
            
            // only track a successful search
            [Tracker track:@"Fetch Special" properties:@{ @"Duration" : [NSNumber numberWithInteger:duration] }];
            
            SpecialModel *special = nil;
            if (specials.count) {
                special = (SpecialModel *)specials[0];
                if (special.duration == 0) {
                    special.duration = 120*60;
                }
            }
            
            if (successBlock) {
                successBlock(special);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

+ (Promise *)fetchSpecial:(SpecialModel *)special {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self fetchSpecial:special success:^(SpecialModel *special) {
        // Resolves promise
        [deferred resolveWith:special];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

// Create special
+ (void)createSpecial:(SpecialModel *)special success:(void(^)(SpecialModel *special))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    NSString *startTime = special.startTimeString;
    
    NSDictionary *params = @{
                             @"text" : special.text.length ? special.text : [NSNull null],
                             @"weekday" : [NSNumber numberWithInteger:special.weekday],
                             @"like_count" : [NSNumber numberWithInteger:special.likeCount],
                             @"start_time" : startTime.length ? startTime : [NSNull null],
                             @"duration_minutes" : [NSNumber numberWithInteger:special.durationInMinutes],
                             @"spot_id" : special.spot ? [NSNumber numberWithInteger:(NSInteger)special.spot.ID] : [NSNull null]
                             };
    
    NSDate *startDate = [NSDate date];
    NSString *path = [NSString stringWithFormat:@"/api/daily_specials"];

    [[ClientSessionManager sharedClient] POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startDate];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            // TODO: instantiate the newly created special
            SpecialModel *special = nil;
            
            // only track a successful search
            [Tracker track:@"Create Special" properties:@{ @"Duration" : [NSNumber numberWithInteger:duration] }];
            
            if (successBlock) {
                successBlock(special);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

// Update Special
+ (void)updateSpecial:(SpecialModel *)special success:(void(^)(SpecialModel *special))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    NSString *startTime = special.startTimeString;
    
    NSDictionary *params = @{
                             @"id" : [NSNumber numberWithInteger:(NSUInteger)special.ID],
                             @"text" : special.text.length ? special.text : [NSNull null],
                             @"weekday" : [NSNumber numberWithInteger:special.weekday],
                             @"like_count" : [NSNumber numberWithInteger:special.likeCount],
                             @"start_time" : startTime.length ? startTime : [NSNull null],
                             @"duration_minutes" : [NSNumber numberWithInteger:special.durationInMinutes],
                             @"spot_id" : special.spot ? [NSNumber numberWithInteger:(NSInteger)special.spot.ID] : [NSNull null]
                             };
    
    NSDate *startDate = [NSDate date];
    NSString *path = [NSString stringWithFormat:@"/api/daily_specials/%ld", (long)[special.ID integerValue]];
    
    [[ClientSessionManager sharedClient] PUT:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startDate];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            if (successBlock) {
                successBlock(nil);
            }
        }
        else if (operation.response.statusCode == 200) {
            // TODO: instantiate the newly created special
            SpecialModel *special = nil;
            
            // only track a successful search
            [Tracker track:@"Update Special" properties:@{ @"Duration" : [NSNumber numberWithInteger:duration] }];
            
            if (successBlock) {
                successBlock(special);
            }
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

// Save Specials (calls Create or Update)
+ (void)saveSpecial:(SpecialModel *)special success:(void(^)(SpecialModel *special))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    if (!special.ID) {
        [self createSpecial:special success:successBlock failure:failureBlock];
    }
    else {
        [self updateSpecial:special success:successBlock failure:failureBlock];
    }
}

+ (Promise *)saveSpecial:(SpecialModel *)special {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self saveSpecial:special success:^(SpecialModel *special) {
        // Resolves promise
        [deferred resolveWith:special];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

// Delete Special
+ (void)purgeSpecial:(SpecialModel *)special success:(void(^)(BOOL success))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    NSDictionary *params = @{};
    NSDate *startDate = [NSDate date];
    NSString *path = [NSString stringWithFormat:@"/api/daily_specials/%ld", (long)[special.ID integerValue]];
    
    [[ClientSessionManager sharedClient] DELETE:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parses response with JSONAPI
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startDate];
        
        if (operation.isCancelled || operation.response.statusCode == 204) {
            // only track a successful search
            [Tracker track:@"Delete Special" properties:@{ @"Duration" : [NSNumber numberWithInteger:duration] }];
            
            if (successBlock) {
                successBlock(TRUE);
            }
        }
        else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            
            if (failureBlock) {
                failureBlock(errorModel);
            }
        }
    }];
}

+ (Promise *)purgeSpecial:(SpecialModel *)special {
    // Creating deferred for promises
    Deferred *deferred = [Deferred deferred];
    
    [self purgeSpecial:special success:^(BOOL success) {
        // Resolves promise
        [deferred resolveWith:[NSNumber numberWithBool:success]];
    } failure:^(ErrorModel *errorModel) {
        // Rejects promise
        [deferred rejectWith:errorModel];
    }];
    
    return deferred.promise;
}

@end
