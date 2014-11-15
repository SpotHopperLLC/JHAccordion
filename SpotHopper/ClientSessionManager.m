//
//  ClientSessionManager.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/12/13.
//  Copyright (c) 2013 Josh Holtz. All rights reserved.
//

#define kCookie @"Cookie"
#define kCurrentUser @"CurrentUser"
#define kHasSeenWelcome @"HasSeenWelcome"
#define kHasSeenLaunch @"HasSeenLaunch"
#define kHasSeenSpotlists @"HasSeenSpotlists"
#define kHasSeenDrinklists @"HasSeenDrinklists"

#define kReachabilityKey @"ReachabilityKey"

#define kNotReachableErrorsDictionary @{ @"errors" : @[ @{ @"human" : @"Network connection is down." } ] }

#define kTimeoutInterval 25

#import "ClientSessionManager.h"

#import "SHAppConfiguration.h"
#import "SHAppUtil.h"

#import "UserModel.h"
#import "Tracker.h"
#import "SHNotifications.h"

#import "JTSReachabilityResponder.h"

#import "FacebookSDK.h"
#import <Parse/Parse.h>

@interface ClientSessionManager()

@property (nonatomic, strong) NSString *cookie;
@property (nonatomic, strong) UserModel *currentUser;

@property (nonatomic, readwrite, assign) NSUInteger totalContentLength;

@end

@implementation ClientSessionManager

@synthesize cookie = _cookie;
@synthesize currentUser =_currentUser;

+ (instancetype)sharedClient {
    static ClientSessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [NSURL URLWithString:[SHAppConfiguration baseUrl]];
        _sharedClient = [[ClientSessionManager alloc] initWithBaseURL:baseURL];
        [_sharedClient setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [_sharedClient setResponseSerializer:[AFJSONResponseSerializer serializer]];
        
        JTSReachabilityResponder *responder = [JTSReachabilityResponder sharedInstance];
        [responder addHandler:^(JTSNetworkStatus status) {
            
            switch (status) {
                case NotReachable:
                    DebugLog(@"Not Reachable");
                    [[_sharedClient operationQueue] cancelAllOperations];
                    break;
                case ReachableViaWiFi:
                    DebugLog(@"WiFi Reachable");
                    break;
                case ReachableViaWWAN:
                    DebugLog(@"WWAN Reachable");
                    break;
                    
                default:
                    NSAssert(FALSE, @"Condition is not defined");
                    break;
            }
            
        } forKey:kReachabilityKey];
    });
    
    return _sharedClient;
}

- (void)cancelAllHTTPOperationsWithMethod:(NSString*)method path:(NSString*)path parameters:(NSDictionary*)parameters ignoreParams:(BOOL)ignoreParams {
    NSError *error;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:(method ?: @"GET") URLString:[[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&error];
    NSString *URLStringToMatched = [[request URL] absoluteString];
    
    for (NSOperation *operation in [self.operationQueue operations]) {
        if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
            continue;
        }
        
        NSURL *matchymatchyURL = [[(AFHTTPRequestOperation *)operation request] URL];
        if (ignoreParams == YES) {
            NSURLComponents *components = [[NSURLComponents alloc] initWithURL:matchymatchyURL resolvingAgainstBaseURL:YES];
            components.query = nil;
            components.fragment = nil;
            
            matchymatchyURL = [components URL];
        }
        
        BOOL hasMatchingMethod = !method || [method isEqualToString:[[(AFHTTPRequestOperation *)operation request] HTTPMethod]];
        BOOL hasMatchingURL = [[matchymatchyURL absoluteString] isEqualToString:URLStringToMatched];
        
        if (hasMatchingMethod && hasMatchingURL) {
            [operation cancel];
        }
    }
}

- (AFHTTPRequestOperation *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id responseObject))success {
    if (!success) {
        return nil;
    }
    
    if (![[JTSReachabilityResponder sharedInstance] isReachable]) {
        success(nil, kNotReachableErrorsDictionary);
        return nil;
    }
    
    NSDate *now = [NSDate date];
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    request.timeoutInterval = kTimeoutInterval;
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (_debug) {
            NSLog(@"%@ %ld - %@", operation.request.URL.standardizedURL, (long)operation.response.statusCode, operation.responseString);
            NSLog(@"%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
        }
        
        NSAssert(now, @"Date value is required");
        [self logResponse:operation.response startDate:now];
        
        success(operation, responseObject);
        [self handleError:operation withResponseObject:responseObject timeStarted:now];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (_debug) {
            NSLog(@"%@ %ld - %@", operation.request.URL.standardizedURL, (long)operation.response.statusCode, operation.responseString);
            NSLog(@"%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
        }
        
        id response = nil;
        if (operation.responseData) {
            response = [NSJSONSerialization JSONObjectWithData: operation.responseData
                                                       options: NSJSONReadingMutableContainers
                                                         error: nil];
        }
        
        if (!response) {
            response = [self responseForOperation:operation];
        }
        success(operation, response);
        [self handleError:operation withResponseObject:response timeStarted:now];
    }];
    
    [self.operationQueue addOperation:operation];

    return operation;
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block success:(void (^)(AFHTTPRequestOperation *, id responseObject))success {
    if (!success) {
        return nil;
    }
    
    if (![[JTSReachabilityResponder sharedInstance] isReachable]) {
        success(nil, kNotReachableErrorsDictionary);
        return nil;
    }
    
    NSDate *now = [NSDate date];
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:block error:nil];
    request.timeoutInterval = kTimeoutInterval;
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (_debug) {
            NSLog(@"Request Headers\n\t%@", operation.request.allHTTPHeaderFields);
            NSLog(@"Request Body\n\t%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
            NSLog(@"Response\n\t%@ %ld - %@", operation.request.URL.standardizedURL, (long)operation.response.statusCode, operation.responseString);
        }
        
        [self logResponse:operation.response startDate:now];
        
        success(operation, responseObject);
        [self handleError:operation withResponseObject:responseObject timeStarted:now];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (_debug) {
            NSLog(@"Request Headers\n\t%@", operation.request.allHTTPHeaderFields);
            NSLog(@"Request Body\n\t%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
            NSLog(@"Response\n\t%@ %ld - %@", operation.request.URL.standardizedURL, (long)operation.response.statusCode, operation.responseString);
        }
        
        id response = nil;
        if (operation.responseData) {
            response = [NSJSONSerialization JSONObjectWithData: operation.responseData
                                                       options: NSJSONReadingMutableContainers
                                                         error: nil];
        }
        
        if (!response) {
            response = [self responseForOperation:operation];
        }
        success(operation, response);
        [self handleError:operation withResponseObject:response timeStarted:now];
    }];
    
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id responseObject))success {
    if (!success) {
        return nil;
    }
    
    if (![[JTSReachabilityResponder sharedInstance] isReachable]) {
        success(nil, kNotReachableErrorsDictionary);
        return nil;
    }
    
    NSDate *now = [NSDate date];
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    request.timeoutInterval = kTimeoutInterval;
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (_debug) {
            NSLog(@"%@ %ld - %@", operation.request.URL.standardizedURL, (long)operation.response.statusCode, operation.responseString);
            NSLog(@"Request Headers - %@", operation.request.allHTTPHeaderFields);
            NSLog(@"%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
        }
        
        [self logResponse:operation.response startDate:now];
        
        success(operation, responseObject);
        [self handleError:operation withResponseObject:responseObject timeStarted:now];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error - %@", error);
        
        if (_debug) {
            NSLog(@"Request Headers - %@", operation.request.allHTTPHeaderFields);
            NSLog(@"Request Body - %@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
            NSLog(@"Response - %@ %ld - %@", operation.request.URL.standardizedURL, (long)operation.response.statusCode, operation.responseString);
        }
        
        id response = nil;
        if (operation.responseData) {
            response = [NSJSONSerialization JSONObjectWithData: operation.responseData
                                                       options: NSJSONReadingMutableContainers
                                                         error: nil];
        }
        
        if (!response) {
            response = [self responseForOperation:operation];
        }
        success(operation, response);
        [self handleError:operation withResponseObject:response timeStarted:now];
    }];
    
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)PUT:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id responseObject))success {
    if (!success) {
        return nil;
    }
    
    if (![[JTSReachabilityResponder sharedInstance] isReachable]) {
        success(nil, kNotReachableErrorsDictionary);
        return nil;
    }
    
    NSDate *now = [NSDate date];
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"PUT" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    request.timeoutInterval = kTimeoutInterval;
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (_debug) {
            NSLog(@"%@ %ld - %@", operation.request.URL.standardizedURL, (long)operation.response.statusCode, operation.responseString);
            NSLog(@"%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
        }
        
        [self logResponse:operation.response startDate:now];
        
        success(operation, responseObject);
        [self handleError:operation withResponseObject:responseObject timeStarted:now];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (_debug) {
            NSLog(@"%@ %ld - %@", operation.request.URL.standardizedURL, (long)operation.response.statusCode, operation.responseString);
            NSLog(@"%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
        }
        
        id response = nil;
        if (operation.responseData) {
            response = [NSJSONSerialization JSONObjectWithData: operation.responseData
                                                       options: NSJSONReadingMutableContainers
                                                         error: nil];
        }
        
        if (!response) {
            response = [self responseForOperation:operation];
        }
        success(operation, response);
        [self handleError:operation withResponseObject:response timeStarted:now];
    }];
    
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(AFHTTPRequestOperation *, id responseObject))success {
    if (!success) {
        return nil;
    }
    
    if (![[JTSReachabilityResponder sharedInstance] isReachable]) {
        success(nil, kNotReachableErrorsDictionary);
        return nil;
    }
    
    NSDate *now = [NSDate date];
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"DELETE" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    request.timeoutInterval = kTimeoutInterval;
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (_debug) {
            NSLog(@"%@ %ld - %@", operation.request.URL.standardizedURL, (long)operation.response.statusCode, operation.responseString);
            NSLog(@"%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
        }
        
        [self logResponse:operation.response startDate:now];
        
        success(operation, responseObject);
        [self handleError:operation withResponseObject:responseObject timeStarted:now];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (_debug) {
            NSLog(@"%@ %ld - %@", operation.request.URL.standardizedURL, (long)operation.response.statusCode, operation.responseString);
            NSLog(@"%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding]);
        }
        
        id response = nil;
        if (operation.responseData) {
            response = [NSJSONSerialization JSONObjectWithData: operation.responseData
                                                       options: NSJSONReadingMutableContainers
                                                         error: nil];
        }
        
        if (!response) {
            response = [self responseForOperation:operation];
        }
        success(operation, response);
        [self handleError:operation withResponseObject:response timeStarted:now];
    }];
    
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark - Track Content Length

- (void)incrementContentLength:(NSUInteger)contentLength {
    self.totalContentLength += contentLength;
}

- (void)resetContentLength {
    self.totalContentLength = 0;
}

#pragma mark - Handle error response

- (id)responseForOperation:(AFHTTPRequestOperation *)operation {
    NSString *error = [NSString stringWithFormat:@"status %li", (long)operation.response.statusCode];
    NSString *human = [NSHTTPURLResponse localizedStringForStatusCode:operation.response.statusCode];
    
    NSDictionary *response = @{ @"errors" : @[@{
                                                  @"error" : error,
                                                  @"human" : human,
                                                  @"validations" : [NSNull null]
                                            }]};
    
    return response;
}

- (void)handleError:(AFHTTPRequestOperation*)operation withResponseObject:(id)responseObject timeStarted:(NSDate*)date {
    
    if (operation.isCancelled) {
        return;
    }
    
    long statusCode = operation.response.statusCode;
    if (statusCode >= 200 && statusCode < 400) {
        // 200s are okay, 300s are redirects and things
        return;
    }
    
    CGFloat elapsedTime = [[NSDate date] timeIntervalSinceDate:date];
    NSString *body = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
    NSString *message = [NSString stringWithFormat:@"[Error] %ld '%@' [%.04f s]: %@", statusCode, [[operation.response URL] absoluteString], elapsedTime, body];
    [Tracker logError:message class:[self class] trace:NSStringFromSelector(_cmd)];
}

#pragma mark - Logging

- (void)logResponse:(NSHTTPURLResponse *)response startDate:(NSDate *)startDate {
    //DebugLog(@"response: %@", response.allHeaderFields);
    NSAssert(startDate, @"Start Date is required");
    NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startDate];
    JTSNetworkStatus networkStatus = [[JTSReachabilityResponder sharedInstance] networkStatus];
    
    NSString *network = @"Unknown";
    
    switch (networkStatus) {
        case NotReachable:
            network = @"Unreachable";
            break;
        case ReachableViaWiFi:
            network = @"WiFi";
            break;
        case ReachableViaWWAN:
            network = @"WWAN";
            break;
            
        default:
            break;
    }
    
    NSString *contentLength = [NSString stringWithFormat:@"%li", (long)response.expectedContentLength];
    
    if (!contentLength.length) {
        contentLength = @"0";
    }
    if (_debug) {
        NSLog(@"Status Code: %li", (long)response.statusCode);
        NSLog(@"Content-Length: %@", contentLength);
        NSLog(@"Path: %@", response.URL.path);
    }
    
    [Tracker track:@"API Response" properties:@{
                                                @"Status Code" : [NSNumber numberWithInteger:response.statusCode],
                                                @"Path" : response.URL.path.length ? response.URL.path : @"Unknown",
                                                @"Duration" : [NSNumber numberWithFloat:duration] ? : @0,
                                                @"Content Length" : [NSNumber numberWithInteger:[contentLength integerValue]],
                                                @"Network" : network
                                                }];
    
    [self incrementContentLength:[contentLength integerValue]];
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
        if (_debug) NSLog(@"Loaded cookie - %@", self.cookie);
        return YES;
    }
    return NO;
}

- (void)setCurrentUser:(UserModel *)currentUser {
    _currentUser = currentUser;
    [self save:_currentUser forKey:kCurrentUser];
    
}

#pragma mark - Login Helpers

- (void)login:(NSHTTPURLResponse*)response user:(UserModel*)user {
    NSLog(@"All response cookies - %@", [response allHeaderFields]);
    NSString *cookie = [[response allHeaderFields] objectForKey:@"Set-Cookie"];
    NSLog(@"Setting Cookie - %@", cookie);
    
    [self setCookie:cookie];
    [self.requestSerializer setValue:cookie forHTTPHeaderField:@"Cookie"];
    [self setCurrentUser:user];
    
    [[SHAppUtil defaultInstance] updateParse];
    [SHNotifications userDidLoginIn];
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
    
    [SHNotifications userDidLoginOut];
}

- (void)forgotPasswordWithEmail:(NSString *)email withCompletionBlock:(void (^)(NSError *error))completionBlock {
    NSDictionary *params = @{@"email" : email};
    
    [self POST:@"/api/users/forgot_password" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completionBlock) {
            completionBlock(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completionBlock) {
            completionBlock(error);
        }
    }];
}

#pragma mark - Facebook Helpers
#pragma mark -

// TODO: set fetching facebook friends
- (void)findFacebookFriendsWithCompletionBlock:(void (^)(NSArray *friendUsers, NSError *error))completionBlock {
    // Issue a Facebook Graph API request to get your user's friend list
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            if (completionBlock) {
                completionBlock(nil, error);
            }
        }
        else {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:friendObject[@"id"]];
            }
            
            // Construct a PFUser query that will find friends whose facebook ids
            // are contained in the current user's friend list.
            PFQuery *friendQuery = [PFUser query];
            [friendQuery whereKey:@"facebookId" containedIn:friendIds];
            
            // findObjects will return a list of PFUsers that are friends
            // with the current user
            NSArray *friendUsers = [friendQuery findObjects];
            DebugLog(@"friendUsers: %@", friendUsers);
            
            if (completionBlock) {
                completionBlock(friendUsers, nil);
            }
        }
    }];
}

#pragma mark - Settings

- (BOOL)hasSeenWelcome {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasSeenWelcome];
}

- (void)setHasSeenWelcome:(BOOL)seenWelcome {
    [[NSUserDefaults standardUserDefaults] setBool:seenWelcome forKey:kHasSeenWelcome];
}

- (BOOL)hasSeenLaunch {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasSeenLaunch];
}

- (void)setHasSeenLaunch:(BOOL)seenLaunch {
    [[NSUserDefaults standardUserDefaults] setBool:seenLaunch forKey:kHasSeenLaunch];
}

- (BOOL)hasSeenSpotlists {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasSeenSpotlists];
}

- (void)setHasSeenSpotlists:(BOOL)seenSpotlists {
    [[NSUserDefaults standardUserDefaults] setBool:seenSpotlists forKey:kHasSeenSpotlists];
}

- (BOOL)hasSeenDrinklists {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasSeenDrinklists];
}

- (void)setHasSeenDrinklists:(BOOL)seenDrinklists {
    [[NSUserDefaults standardUserDefaults] setBool:seenDrinklists forKey:kHasSeenDrinklists];
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
    }
    else {
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
