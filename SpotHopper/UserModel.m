//
//  UserModel.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/26/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "UserModel.h"

#import <JSONAPI/JSONAPI.h>

#import "ClientSessionManager.h"
#import "ErrorModel.h"

#import <objc/runtime.h>
#import <objc/message.h>

@implementation UserModel

#pragma mark - API

+ (void)registerUser:(NSDictionary*)params success:(void(^)(UserModel *userModel, NSHTTPURLResponse *response))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    
    [[ClientSessionManager sharedClient] logout];
    
    NSDictionary *wrappedParams = @{
               kUserModelUsers : @[params]
               };
    
    [[ClientSessionManager sharedClient] POST:@"/api/users" parameters:wrappedParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == 200) {
            [UserModel loginUser:params success:successBlock failure:failureBlock];
        } else {
            JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
            
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
        }
    }];
    
}

+ (void)loginUser:(NSDictionary*)params success:(void(^)(UserModel *userModel, NSHTTPURLResponse *response))successBlock failure:(void(^)(ErrorModel *errorModel))failureBlock {
    
    [[ClientSessionManager sharedClient] logout];
    
    [[ClientSessionManager sharedClient] POST:@"/api/sessions" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        JSONAPI *jsonApi = [JSONAPI JSONAPIWithDictionary:responseObject];
        
        if (operation.response.statusCode == 200) {
            UserModel *userModel = [jsonApi resourceForKey:@"users"];
            
            NSLog(@"All request cookies - %@", [operation.request allHTTPHeaderFields]);
            [[ClientSessionManager sharedClient] login:operation.response user:userModel];
            
            successBlock(userModel, operation.response);
        } else {
            ErrorModel *errorModel = [jsonApi resourceForKey:@"errors"];
            failureBlock(errorModel);
        }
    }];
    
}

#pragma mark - Getters

- (NSString *)email {
    return [self objectForKey:@"email"];
}

- (NSString *)role {
    return [self objectForKey:@"role"];
}

- (NSString *)name {
    return [self objectForKey:@"name"];
}

- (NSDate *)birthday {
    return [self objectForKey:@"birthday"];
}

- (NSDictionary *)settings {
    return [self objectForKey:@"settings"];
}

#pragma mark - NSCoding

- (NSArray *)propertyKeys
{
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
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

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    for (NSString *key in [self propertyKeys])
    {
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}

@end
