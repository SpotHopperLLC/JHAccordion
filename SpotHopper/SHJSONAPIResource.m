//
//  SHJSONAPIResource.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/12/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SHJSONAPIResource.h"

#import <objc/runtime.h>
#import <objc/message.h>

#import <Raven/RavenClient.h>

@implementation SHJSONAPIResource

- (id)initWithDictionary:(NSDictionary *)dict withLinked:(NSDictionary *)linked {
    self = [super initWithDictionary:dict withLinked:linked];
    if (self) {
        
    }
    return self;
}

- (id)objectForKey:(NSString *)key {
    // Makes sure NSNulls don't get returned - cause eww
    id object = [super objectForKey:key];
    if (object != [NSNull null]) {
        return object;
    }
    return nil;
}

#pragma mark - Debugging

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", self.ID, self.href];
}

#pragma mark - Format helpers

- (NSDate *)formatBirthday:(NSString *)string {
    NSDate *date = nil;
    if (string.length > 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSError *error = nil;
        if (![dateFormatter getObjectValue:&date forString:string range:nil error:&error]) {
//            [[RavenClient sharedClient] captureMessage:[NSString stringWithFormat:@"Birthday '%@' could not be parsed: %@", string, error] level:kRavenLogLevelDebugError];
        }
    }
    return date;
}

- (NSDate *)formatDateTimestamp:(NSString *)string {
    NSDate *date = nil;
    if (string.length > 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        
        NSError *error = nil;
        if (![dateFormatter getObjectValue:&date forString:string range:nil error:&error]) {
            return [self formatDateTimestampMillisecond:string];
        }

    }
    return date;
}

- (NSDate *)formatDateTimestampMillisecond:(NSString *)string {
    NSDate *date = nil;
    if (string.length > 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        
        NSError *error = nil;
        if (![dateFormatter getObjectValue:&date forString:string range:nil error:&error]) {
            
        }
        
    }
    return date;
}

#pragma mark - NSCoding

- (NSArray *)propertyKeys {
    NSMutableArray *array = [NSMutableArray array];
    Class class = [self class];
    while (class != [NSObject class])
    {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        for (int i = 0; i < propertyCount; i++)
        {
            //get property
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            NSString *key = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
            
            //check if read-only
            BOOL readonly = NO;
            const char *attributes = property_getAttributes(property);
            NSString *encoding = [NSString stringWithCString:attributes encoding:NSUTF8StringEncoding];
            if ([[encoding componentsSeparatedByString:@","] containsObject:@"R"])
            {
                readonly = YES;
                
                //see if there is a backing ivar with a KVC-compliant name
                NSRange iVarRange = [encoding rangeOfString:@",V"];
                if (iVarRange.location != NSNotFound)
                {
                    NSString *iVarName = [encoding substringFromIndex:iVarRange.location + 2];
                    if ([iVarName isEqualToString:key] ||
                        [iVarName isEqualToString:[@"_" stringByAppendingString:key]])
                    {
                        //setValue:forKey: will still work
                        readonly = NO;
                    }
                }
            }
            
            if (!readonly)
            {
                //exclude read-only properties
                [array addObject:key];
            }
        }
        free(properties);
        class = [class superclass];
    }
    return array;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [self init]))
    {
        for (NSString *key in [self propertyKeys])
        {
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    for (NSString *key in [self propertyKeys])
    {
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SHJSONAPIResource class]]) {
        return [self isEqualToJSONAPIResource:(SHJSONAPIResource *)object];
    }
    return FALSE;
}

- (BOOL)isEqualToJSONAPIResource:(SHJSONAPIResource *)other {
    return [self.ID isEqualToNumber:other.ID];
}

- (NSUInteger)hash {
    if ([self.ID respondsToSelector:@selector(hash)]) {
        return [self.ID hash];
    }
    
    return [super hash];
}

@end
