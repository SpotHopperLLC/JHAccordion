//
//  ClientSessionManager.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/12/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#define kCookie @"Cookie"
#define kCurrentUser @"CurrentUser"
#define kHasSeenLaunch @"HasSeenLaunch"

#import "ClientSessionManager.h"

#import "UserModel.h"

#import <FacebookSDK/Facebook.h>

@interface ClientSessionManager()

@property (nonatomic, strong) NSString *cookie;
@property (nonatomic, strong) UserModel *currentUser;

@end

@implementation ClientSessionManager

@synthesize cookie = _cookie;
@synthesize currentUser =_currentUser;

+ (instancetype)sharedClient {
    static ClientSessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[ClientSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
        [_sharedClient setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [_sharedClient setResponseSerializer:[AFJSONResponseSerializer serializer]];

    });
    
    return _sharedClient;
}

- (AFHTTPRequestOperation *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success {
    return [super GET:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (_debug) {
            NSLog(@"%@ %d - %@", operation.request.URL.standardizedURL, operation.response.statusCode, operation.responseString);
            NSLog(@"%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
        }
        
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (_debug) {
            NSLog(@"%@ %d - %@", operation.request.URL.standardizedURL, operation.response.statusCode, operation.responseString);
            NSLog(@"%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
        }
        
        id response = nil;
        if (operation.responseData != nil) {
            response = [NSJSONSerialization JSONObjectWithData: operation.responseData
                                                       options: NSJSONReadingMutableContainers
                                                         error: nil];
        }
        success(operation, response);
    }];
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block success:(void (^)(AFHTTPRequestOperation *, id))success {
    return [super POST:URLString parameters:parameters constructingBodyWithBlock:block success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (_debug) {
            NSLog(@"Request Headers\n\t%@", operation.request.allHTTPHeaderFields);
            NSLog(@"Request Body\n\t%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
            NSLog(@"Response\n\t%@ %d - %@", operation.request.URL.standardizedURL, operation.response.statusCode, operation.responseString);
        }
        
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (_debug) {
            NSLog(@"Request Headers\n\t%@", operation.request.allHTTPHeaderFields);
            NSLog(@"Reques Body\n\t%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
            NSLog(@"Response\n\t%@ %d - %@", operation.request.URL.standardizedURL, operation.response.statusCode, operation.responseString);
        }
        
        id response = nil;
        if (operation.responseData != nil) {
            response = [NSJSONSerialization JSONObjectWithData: operation.responseData
                                                       options: NSJSONReadingMutableContainers
                                                         error: nil];
        }
        success(operation, response);
    }];
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success {
    return [super POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (_debug) {
            NSLog(@"%@ %d - %@", operation.request.URL.standardizedURL, operation.response.statusCode, operation.responseString);
            NSLog(@"Request Headers - %@", operation.request.allHTTPHeaderFields);
            NSLog(@"%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
        }
        
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error - %@", error);
        
        if (_debug) {
            NSLog(@"Request Headers - %@", operation.request.allHTTPHeaderFields);
            NSLog(@"Request Body - %@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
            NSLog(@"Response - %@ %d - %@", operation.request.URL.standardizedURL, operation.response.statusCode, operation.responseString);
        }
        
        id response = nil;
        if (operation.responseData != nil) {
            response = [NSJSONSerialization JSONObjectWithData: operation.responseData
                                                       options: NSJSONReadingMutableContainers
                                                         error: nil];
        }
        success(operation, response);
    }];
}

- (AFHTTPRequestOperation *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success {
    return [super PUT:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (_debug) {
            NSLog(@"%@ %d - %@", operation.request.URL.standardizedURL, operation.response.statusCode, operation.responseString);
            NSLog(@"%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
        }
        
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (_debug) {
            NSLog(@"%@ %d - %@", operation.request.URL.standardizedURL, operation.response.statusCode, operation.responseString);
            NSLog(@"%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
        }
        
        id response = nil;
        if (operation.responseData != nil) {
            response = [NSJSONSerialization JSONObjectWithData: operation.responseData
                                                       options: NSJSONReadingMutableContainers
                                                         error: nil];
        }
        success(operation, response);
    }];
}

- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id))success {
    return [super DELETE:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (_debug) {
            NSLog(@"%@ %d - %@", operation.request.URL.standardizedURL, operation.response.statusCode, operation.responseString);
            NSLog(@"%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
        }
        
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (_debug) {
            NSLog(@"%@ %d - %@", operation.request.URL.standardizedURL, operation.response.statusCode, operation.responseString);
            NSLog(@"%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
        }
        
        id response = nil;
        if (operation.responseData != nil) {
            response = [NSJSONSerialization JSONObjectWithData: operation.responseData
                                                       options: NSJSONReadingMutableContainers
                                                         error: nil];
        }
        success(operation, response);
    }];
}

#pragma mark - Session Helpers

- (NSString *)cookie {
    if (_cookie == nil) {
        _cookie  = [[NSUserDefaults standardUserDefaults] objectForKey:kCookie];
    }
    return _cookie;
}

- (void)setCookie:(NSString *)cookie {
    _cookie  = cookie;
    [[NSUserDefaults standardUserDefaults] setObject:cookie forKey:kCookie];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UserModel *)currentUser {
    if (_currentUser == nil) {
        _currentUser = [self load:[UserModel class] forKey:kCurrentUser];
    }
    
    return _currentUser;
}

- (BOOL)isLoggedIn {
    if ([self cookie] != nil) {
        [self.requestSerializer setValue:self.cookie forHTTPHeaderField:@"Cookie"];
        NSLog(@"Loaded cookie - %@", self.cookie);
        return YES;
    }
    return NO;
}

- (void)setCurrentUser:(UserModel *)currentUser {
    _currentUser = currentUser;
    [self save:_currentUser forKey:kCurrentUser];
    
}

#pragma mark - Login helpers

- (void)login:(NSHTTPURLResponse*)response user:(UserModel*)user {
    NSLog(@"All response cookies - %@", [response allHeaderFields]);
    NSString *cookie = [[response allHeaderFields] objectForKey:@"Set-Cookie"];
    NSLog(@"Setting Cookie - %@", cookie);
    
    [self setCookie:cookie];
    [self.requestSerializer setValue:cookie forHTTPHeaderField:@"Cookie"];
    [self setCurrentUser:user];
}

- (void)logout {
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.requestSerializer setValue:@"" forHTTPHeaderField:@"Cookie"];
    [self setCookie:nil];
    [self setCurrentUser:nil];
}

#pragma mark - Settings

- (BOOL)hasSeenLaunch {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasSeenLaunch];
}

- (void)setHasSeenLaunch:(BOOL)seenLaunch {
    [[NSUserDefaults standardUserDefaults] setBool:seenLaunch forKey:kHasSeenLaunch];
}

#pragma mark - Save Model

- (void)save:(NSObject<NSCoding>*)object forKey:(NSString*)key {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    
    NSString *path = [[NSString alloc] initWithFormat:@"%@/%@", directory, key];
    
    if (object != nil) {
        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [object encodeWithCoder:archiver];
        [archiver finishEncoding];
        
        [data writeToFile:path atomically:YES];
    } else {
        NSFileManager *fileMgr = [[NSFileManager alloc] init];
        [fileMgr removeItemAtPath:path error:nil];
    }
    
}

- (id)load:(Class)clazz forKey:(NSString*)key {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    
    NSString *path = [[NSString alloc] initWithFormat:@"%@/%@", directory, key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:[NSData dataWithContentsOfFile:path]];
        id obj = [[clazz alloc] initWithCoder:unarchiver];
        [unarchiver finishDecoding];
        
        return obj;
    }
    return nil;
}

@end
