//
//  AppDelegate.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/26/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "AppDelegate.h"

#import "SHAppContext.h"
#import "SHLocationManager.h"
#import "NSNumber+Helpers.h"
#import "UIActionSheet+Block.h"

#import "SHNavigationBar.h"
#import "SHAppConfiguration.h"
#import "SHAppUtil.h"
#import "SHUserProfileModel.h"

#import "ClientSessionManager.h"
#import "SHModelResourceManager.h"

#import "UserState.h"
#import "MockData.h"

#import "SHNotifications.h"

#import "BFURL.h"
#import "BFAppLink.h"

#import "Mixpanel.h"
#import "Tracker.h"
#import "Tracker+Events.h"
#import "Tracker+People.h"
#import "UserState.h"

#import "SHStyleKit.h"
#import "SSTURLShortener.h"

#import "DrinkListModel.h"
#import "SpotListModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubTypeModel.h"
#import "BaseAlcoholModel.h"

//#import "Crashlytics.h"
#import "Promise.h"

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <JSONAPI/JSONAPI.h>
#import <FiksuSDK/FiksuSDK.h>
#import <Parse/Parse.h>
#import <ParseCrashReporting/ParseCrashReporting.h>
#import <STTwitter/STTwitter.h>

#define kPushActionShowSpecials @"ShowSpecials"
#define kPushActionShowSpotlist @"ShowSpotlist"
#define kPushActionShowDrinklist @"ShowDrinklist"
#define kPushActionUpdateLocation @"UpdateLocation"
#define kPushActionPromptForCheckIn @"PromptForCheckIn"

#define kUpdateLocationLunchLocation @"Lunch"
#define kUpdateLocationHappyHourLocation @"Happy Hour"

#define kUpdateLocationSleep @"4am"
#define kUpdateLocationLunchTime @"11am"
#define kUpdateLocationHappyHour @"7pm"
#define kUpdateLocationLateNight @"12am"

@interface AppDelegate()

@property (nonatomic, strong) Mockery *mockery;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SHModelResourceManager prepareResources];

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    if ([SHAppConfiguration isParseEnabled]) {
        [ParseCrashReporting enable];
        [Parse setApplicationId:[SHAppConfiguration parseApplicationID]
                      clientKey:[SHAppConfiguration parseClientKey]];
//        [Parse enableLocalDatastore]; // not ready yet (it has crashing issues)
        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        [PFUser enableAutomaticUser];
        PFUser *user = [PFUser currentUser];
        if (user.isAuthenticated) {
            [user setObject:[SHAppConfiguration bundleDisplayName] forKey:@"appName"];
            [user setObject:[SHAppConfiguration bundleIdentifier] forKey:@"appIdentifier"];
            [user setObject:@"ios" forKey:@"deviceType"];
            
            if ([[ClientSessionManager sharedClient] isLoggedIn]) {
                NSString *sessionToken = [[ClientSessionManager sharedClient] sessionToken];
                if (sessionToken.length) {
                    [user setObject:sessionToken forKey:@"spotHopperSessionToken"];
                }
            }
            
            NSString *timezone = [[NSTimeZone localTimeZone] name];
            if (timezone.length) {
                [user setObject:timezone forKey:@"timeZone"];
            }
            
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    DebugLog(@"Error: %@", error);
                }
            }];
        }
    }
    
    // Prompts user for permission to send notifications
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)] && [application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // iOS 8 support
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    else {
        // iOS 7 support
        UIRemoteNotificationType types = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:types];
    }
    
    FBSessionTokenCachingStrategy *cachingStrategy = [FBSessionTokenCachingStrategy defaultInstance];
    if ([FBSessionTokenCachingStrategy isValidTokenInformation:[cachingStrategy fetchTokenInformation]]) {
        [FBSession openActiveSessionWithAllowLoginUI:NO];
    }
    
    if ([[FBSession activeSession] isOpen]) {
        [[SHAppUtil defaultInstance] becomeFacebookUserWithCompletionBlock: ^(BOOL success, NSError *error) {
            [[SHAppUtil defaultInstance] fetchFacebookDetailsWithCompletionBlock:^(BOOL success, NSError *error) {
                if (error) {
                    DebugLog(@"Error: %@", error);
                    [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
                }
            }];
        }];
    }
    else if ([UserModel isLoggedIn]) {
        [[SHAppUtil defaultInstance] becomeSpotHopperUserWithCompletionBlock:^(BOOL success, NSError *error) {
            if (error) {
                DebugLog(@"Error: %@", error);
            }
            
            // set the user profile using just UserModel
            
            UserModel *user = [UserModel currentUser];
            DebugLog(@"user: %@", user);
            
            SHUserProfileModel *userProfile = [[SHUserProfileModel alloc] init];
            userProfile.spotHopperUserId = [NSNumber numberWithLongLong:[user.ID longLongValue]];
            userProfile.name = user.name;
            
            if (user.facebookId) {
                userProfile.facebookId = [NSNumber numberWithLongLong:[user.facebookId longLongValue]];
                NSString *imageUrlString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", user.facebookId];
                userProfile.imageURL = [NSURL URLWithString:imageUrlString];
            }
            else {
                userProfile.imageURL = [NSURL URLWithString:@"http://static.spotapps.co/spothopper-icon.png"];
            }
            
            [[SHAppUtil defaultInstance] saveUserProfile:userProfile withCompletionBlock:^(SHUserProfileModel *savedUserProfile, NSError *error) {
                if (error) {
                    DebugLog(@"Error: %@", error);
                }
                else {
                    [[SHAppContext defaultInstance] setCurrentUserProfile:savedUserProfile];
                }
            }];
        }];
    }
    
    // Navigation bar styling
    [[UINavigationBar appearance] setTintColor:kColorOrange];
    
    // Sets networking debug logs if debug is set
    [[ClientSessionManager sharedClient] setDebug:[SHAppConfiguration isDebuggingEnabled]];
    
    // Initializes cookie for network calls
    [[ClientSessionManager sharedClient] isLoggedIn];
    
    if ([SHAppConfiguration isTrackingEnabled]) {
        NSString *token = [SHAppConfiguration mixpanelToken];
        [Mixpanel sharedInstanceWithToken:token];
        [Tracker trackAppLaunching];
        [Tracker identifyUser];
        [Tracker trackUserWithProperties:@{ @"Last Launch Date" : [NSDate date] }];
        [Tracker trackUserAction:@"App Launch"];
    }
    
    NSDate *firstUseDate = [UserState firstUseDate];
    if (!firstUseDate) {
        [UserState setFirstUseDate:[NSDate date]];
        if ([SHAppConfiguration isTrackingEnabled]) {
            [Tracker trackFirstUse];
            [Tracker trackUserFirstUse];
        }
    }

    if ([ClientSessionManager sharedClient].isLoggedIn) {
        [self refreshDeviceLocationWithCompletionBlock:^{
            [SHAppContext setLastLocation:[SHAppContext currentDeviceLocation] withCompletionBlock:^{
                CLLocation *location = [SHAppContext lastLocation];
                if (location) {
                    UserModel *user = [[ClientSessionManager sharedClient] currentUser];
                    [user putUser:@{ kUserModelParamLatitude : [NSNumber numberWithFloat:location.coordinate.latitude],
                                     kUserModelParamLongitude : [NSNumber numberWithFloat:location.coordinate.longitude]
                                     } success:^(UserModel *userModel, NSHTTPURLResponse *response) {
                                         
                                     } failure:^(ErrorModel *errorModel) {
                                         [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
                                     }];
                }
            }];
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFacebookSessionDidBecomeOpenActiveSessionNotification:)
                                                 name:FBSessionDidBecomeOpenActiveSessionNotification
                                               object:nil];
    
    BOOL isLocationChange = [launchOptions.allKeys containsObject:UIApplicationLaunchOptionsLocationKey];
    if (isLocationChange) {
        [Tracker trackDidChangeSignificantLocation];
    }
    
    [[SHLocationManager defaultInstance] wakeUp];
    
    // Twitter ad tracking
    [FiksuTrackingManager applicationDidFinishLaunching:launchOptions];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSInteger maximumExpectedLength = 2048;
    if (!url.absoluteString.length || url.absoluteString.length > maximumExpectedLength) {
        // The URL is longer than we expect. Stop servicing it.
        return NO;
    }
    
    BFURL *parsedUrl = [BFURL URLWithURL:url];
    NSString *fullURLString = parsedUrl.targetURL.absoluteString;
    
    if (!fullURLString.length || fullURLString.length > maximumExpectedLength) {
        // The URL is longer than we expect. Stop servicing it.
        return NO;
    }
    
    if ([self isShortenedURL:fullURLString] || [self isURLSchemePrefixForURLString:fullURLString] || [fullURLString hasPrefix:[SHAppConfiguration websiteUrl]]) {
        self.openedURL = parsedUrl.targetURL;
        if (parsedUrl.appLinkReferer.sourceURL) {
            self.sourceURL = parsedUrl.appLinkReferer.sourceURL;
        }
        
        NSURL *targetURL = parsedUrl.targetURL;
        NSURL *sourceURL = parsedUrl.appLinkReferer.sourceURL;

        // if the targetURL is a shortened URL then expand it first
        if ([self isShortenedURL:targetURL.absoluteString]) {
            [SSTURLShortener expandURL:targetURL accessToken:[SHAppConfiguration bitlyAccessToken] withCompletionBlock:^(NSURL *expandedURL, NSError *error) {
                if (!error) {
                    self.openedURL = expandedURL;
                    [Tracker trackDeepLinkWithTargetURL:expandedURL sourceURL:sourceURL sourceApplication:sourceApplication];
                    [SHNotifications appOpenedWithURL:expandedURL];
                }
            }];
        }
        else {
            [Tracker trackDeepLinkWithTargetURL:targetURL sourceURL:sourceURL sourceApplication:sourceApplication];
            [SHNotifications appOpenedWithURL:targetURL];
        }
        
        return YES;
    }
    else {
        return [FBSession.activeSession handleOpenURL:url];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    DebugLog(@"%@ - %@", NSStringFromSelector(_cmd), notificationSettings);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current Installation and save it to Parse.
    if ([SHAppConfiguration isParseEnabled]) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setDeviceTokenFromData:deviceToken];
//        DebugLog(@"device type: %@", currentInstallation.deviceType);
//        DebugLog(@"device token: %@", currentInstallation.deviceToken);
//        PFUser *currentUser = [PFUser currentUser];
//        DebugLog(@"user: %@", currentUser.objectId);
        
#ifndef NDEBUG
        [currentInstallation setObject:[NSNumber numberWithBool:YES] forKey:@"debug"];
        [Tracker trackUserDebugMode:YES];
#else
        [currentInstallation setObject:[NSNumber numberWithBool:NO] forKey:@"debug"];
        [Tracker trackUserDebugMode:NO];
#endif

        [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                DebugLog(@"Error: %@", error);
            }
        }];
    }

    // prepare Mixpanel to send notifications to this device
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:mixpanel.distinctId];
    [mixpanel.people addPushDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler {
    DebugLog(@"%@, %@, %@", NSStringFromSelector(_cmd), identifier, userInfo);
    
    // TODO review for iOS 8 changes to Push Notifications
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    DebugLog(@"userInfo: %@", userInfo);
    
    [Tracker trackNotification:userInfo];
    [Tracker trackUserNotification:userInfo];
    [PFPush handlePush:userInfo];
    
    NSString *action = userInfo[@"action"];
    BOOL inForeground = application.applicationState == UIApplicationStateActive;
    
    id contentAvailable = userInfo[@"aps"][@"content-available"];
    BOOL isSilentPush = contentAvailable != nil && [contentAvailable intValue] == 1;
    
    DebugLog(@"is silent: %@", isSilentPush ? @"YES" : @"NO");
    
    if ([kPushActionUpdateLocation isEqualToString:action]) {
        [self processLocationUpdate:userInfo withCompletionBlock:^{
            if (completionHandler) {
                completionHandler(UIBackgroundFetchResultNewData);
            }
        }];
    }
    else if (isSilentPush && !inForeground) {
        [self processSilentNotification:userInfo withCompletionBlock:^{
            if (completionHandler) {
                completionHandler(UIBackgroundFetchResultNewData);
            }
        }];
    }
    else if (!isSilentPush && !inForeground) {
        [self handleNotification:userInfo];
        completionHandler(UIBackgroundFetchResultNewData);
    }
    else if (completionHandler) {
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    application.applicationIconBadgeNumber = 0;
    
    [self handleNotification:notification.userInfo];
}

- (CLLocation *)locationFromDictionary:(NSDictionary *)dictionary {
    if (dictionary[@"latitude"] && dictionary[@"longitude"]) {
        CLLocationDegrees latitude = [dictionary[@"latitude"] doubleValue];
        CLLocationDegrees longitude = [dictionary[@"longitude"] doubleValue];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        return location;
    }
    
    return nil;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
#if !TARGET_IPHONE_SIMULATOR
    DebugLog(@"Error: %@", error);
#endif
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [Tracker trackTotalContentLength];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    application.applicationIconBadgeNumber = 0;
    
    if ([[ClientSessionManager sharedClient] hasSeenLaunch]) {
        [self refreshDeviceLocationWithCompletionBlock:^{
            // do nothing
        }];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Private
#pragma mark -

- (void)handleNotification:(NSDictionary *)userInfo {
    NSString *action = userInfo[@"action"];
    
    CLLocation *location = [self locationFromDictionary:userInfo];
    CLLocationDegrees radius = [userInfo[@"radius"] doubleValue];
    
    if ([kPushActionShowSpecials isEqualToString:action]) {
        if (location) {
            [SHNotifications showSpecialsAtLocation:location withRadius:radius];
        }
    }
    else if ([kPushActionShowSpotlist isEqualToString:action]) {
        if (location) {
            NSString *name = userInfo[@"name"];
            DebugLog(@"name: %@", name);
            
            [[SpotListModel fetchMySpotLists] then:^(NSArray *spotlists) {
                SpotListModel *foundSpotlist = nil;
                for (SpotListModel *spotlist in spotlists) {
                    if ([name isEqualToString:spotlist.name]) {
                        foundSpotlist = spotlist;
                        break;
                    }
                }
                
                if (foundSpotlist) {
                    [SHNotifications showSpotlist:foundSpotlist atLocation:location withRadius:radius];
                }
            } fail:^(ErrorModel *errorModel) {
                [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
            } always:nil];
        }
    }
    else if ([kPushActionShowDrinklist isEqualToString:action]) {
        if (location) {
            NSString *name = userInfo[@"name"];
            DebugLog(@"name: %@", name);
            
            if ([@"Highest Rated" isEqualToString:name]) {
                DrinkListModel *drinklist = [[DrinkListModel alloc] init];
                drinklist.name = name;

                // the drink type should be defined while subtype and alcohol are optional
                
                if (userInfo[@"drinkTypeId"]) {
                    DrinkTypeModel *drinkType = [[DrinkTypeModel alloc] init];
                    drinkType.ID = [NSNumber numberWithInteger:[userInfo[@"drinkTypeId"] integerValue]];
                    drinklist.drinkType = drinkType;
                }
                if (userInfo[@"drinkSubTypeId"]) {
                    DrinkSubTypeModel *drinkSubType = [[DrinkSubTypeModel alloc] init];
                    drinkSubType.ID = [NSNumber numberWithInteger:[userInfo[@"drinkTypeId"] integerValue]];
                    drinklist.drinkSubType = drinkSubType;
                }
                if (userInfo[@"baseAlcoholId"]) {
                    BaseAlcoholModel *baseAlcohol = [[BaseAlcoholModel alloc] init];
                    baseAlcohol.ID = [NSNumber numberWithInteger:[userInfo[@"baseAlcoholId"] integerValue]];
                    drinklist.baseAlcohol = baseAlcohol;
                }
                
                [SHNotifications showDrinklist:drinklist atLocation:location withRadius:radius];
            }
            else {
                [[DrinkListModel fetchMyDrinkLists] then:^(NSArray *drinklists) {
                    DrinkListModel *foundDrinklist = nil;
                    for (DrinkListModel *drinklist in drinklists) {
                        if ([name isEqualToString:drinklist.name]) {
                            foundDrinklist = drinklist;
                            break;
                        }
                    }
                    
                    if (foundDrinklist) {
                        [SHNotifications showDrinklist:foundDrinklist atLocation:location withRadius:radius];
                    }
                } fail:^(ErrorModel *errorModel) {
                    [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
                } always:nil];
            }
        }
    }
    else if ([kPushActionPromptForCheckIn isEqualToString:action]) {
        // prompt user to check in at spot
        DebugLog(@"Check In at Spot");
        DebugLog(@"userInfo: %@", userInfo);
        
        [SHNotifications promptForCheckIn:userInfo];
    }
    else {
        DebugLog(@"Location notification not supported");
    }
}

- (void)processLocationUpdate:(NSDictionary *)userInfo withCompletionBlock:(void (^)())completionBlock {
    NSString *action = userInfo[@"action"];
    NSString *key = userInfo[@"key"];
    if (action.length && key.length) {
        CLLocation *location = [SHAppContext currentDeviceLocation];
        [SHAppContext updateLocation:location withCompletionBlock:nil];
        if (location) {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                if (!error && placemarks.count) {
                    CLPlacemark *placemark = placemarks[0];
                    if ([key isEqualToString:kUpdateLocationLunchLocation] || [key isEqualToString:kUpdateLocationHappyHourLocation]) {
                        [Tracker trackUserLocation:placemark forKey:key];
                    }
                    else if ([key isEqualToString:kUpdateLocationSleep] ||
                             [key isEqualToString:kUpdateLocationLunchTime] ||
                             [key isEqualToString:kUpdateLocationLateNight] ||
                             [key isEqualToString:kUpdateLocationHappyHour]) {
                        [Tracker trackUserZip:placemark forKey:key];
                    }
                    
                    if (completionBlock) {
                        completionBlock();
                    }
                }
            }];
        }
    }
    else {
        if (completionBlock) {
            completionBlock();
        }
    }
}

- (void)processSilentNotification:(NSDictionary *)userInfo withCompletionBlock:(void (^)())completionBlock {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    if (!completionBlock) {
        return;
    }
    
    NSString *action = userInfo[@"action"];
    
    if ([kPushActionShowSpecials isEqualToString:action]) {
        if (userInfo[@"latitude"] && userInfo[@"longitude"] && userInfo[@"radius"]) {
            [self scheduleLocationNotification:userInfo];
        }
        completionBlock();
    }
    else if ([kPushActionShowSpotlist isEqualToString:action]) {
        // check that the given spotlist is present for this user
        
        if (!userInfo[@"latitude"] || !userInfo[@"longitude"] || !userInfo[@"radius"]) {
            completionBlock();
            return;
        }
        
        NSString *name = userInfo[@"name"];
        DebugLog(@"name: %@", name);
        
        [[SpotListModel fetchMySpotLists] then:^(NSArray *spotlists) {
            for (SpotListModel *spotlist in spotlists) {
                if ([name isEqualToString:spotlist.name]) {
                    [self scheduleLocationNotification:userInfo];
                    break;
                }
            }
            
            completionBlock();
        } fail:^(ErrorModel *errorModel) {
            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
            completionBlock();
        } always:nil];
    }
    else if ([kPushActionShowDrinklist isEqualToString:action]) {
        // check that the given drinklist is present for this user
        
        if (!userInfo[@"latitude"] || !userInfo[@"longitude"] || !userInfo[@"radius"]) {
            completionBlock();
            return;
        }
        
        NSString *name = userInfo[@"name"];
        DebugLog(@"name: %@", name);
        
        if ([@"Highest Rated" isEqualToString:name]) {
            [self scheduleLocationNotification:userInfo];
            completionBlock();
        }
        else {
            [[DrinkListModel fetchMyDrinkLists] then:^(NSArray *drinklists) {
                for (DrinkListModel *drinklist in drinklists) {
                    if ([name isEqualToString:drinklist.name]) {
                        [self scheduleLocationNotification:userInfo];
                        break;
                    }
                }
                
                completionBlock();
            } fail:^(ErrorModel *errorModel) {
                [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
                completionBlock();
            } always:nil];
        }
    }
    else {
        DebugLog(@"Action not supported: %@", action);
        completionBlock();
    }
}

- (void)scheduleLocationNotification:(NSDictionary *)userInfo {
    if (!userInfo[@"message"]) {
        DebugLog(@"No alert to show");
        return;
    }
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.userInfo = userInfo;
    notification.alertBody = userInfo[@"message"];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (BOOL)isShortenedURL:(NSString *)urlString {
    NSString *bitlyShortURL = [SHAppConfiguration bitlyShortURL];
    return [urlString hasPrefix:bitlyShortURL];
}

- (BOOL)isURLSchemePrefixForURLString:(NSString *)urlString {
    NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    for (NSDictionary *urlType in urlTypes) {
        NSArray *urlSchemes = urlType[@"CFBundleURLSchemes"];
        for (NSString *urlScheme in urlSchemes) {
            if (![urlScheme hasPrefix:@"fb"] && [urlString hasPrefix:urlScheme]) {
                return TRUE;
            }
        }
    }
    
    return FALSE;
}

- (void)handlePush:(NSDictionary*)payload inForeground:(BOOL)inForeground {
    // TODO: remove this method as it is not longer going to be used
    //    if (payload) {
    //        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPushReceived object:self userInfo:payload];
    //    }
}

#pragma mark - Location
#pragma mark -

- (void)refreshDeviceLocationWithCompletionBlock:(void (^)())completionBlock {
    CLLocation *location = [SHAppContext currentDeviceLocation];
    if (location) {
        // Saves current location
        [SHAppContext setLastLocation:location withCompletionBlock:^{
            if (completionBlock) {
                completionBlock();
            }
        }];
    }
    else {
        if (completionBlock) {
            completionBlock();
        }
    }
}

#pragma mark - Facebook Connect
#pragma mark -

- (void)facebookAuth:(BOOL)allowLogin success:(void(^)(FBSession *session))successHandler failure:(void(^)(FBSessionState state, NSError *error))failureHandler {
    
    if (!successHandler || !failureHandler) {
        return;
    }
    
    if ([[FBSession activeSession] isOpen]) {
        successHandler([FBSession activeSession]);
        
        [[SHAppUtil defaultInstance] fetchFacebookDetailsWithCompletionBlock:^(BOOL success, NSError *error) {
            if (error) {
                DebugLog(@"Error: %@", error);
                [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
            }
        }];
        
        return;
    }
    
    if (allowLogin == YES) {
        FBSession* sess = [[FBSession alloc] initWithPermissions:@[@"public_profile, publish_actions, email, user_friends"]];
        [FBSession setActiveSession:sess];
        [sess openWithBehavior:(FBSessionLoginBehaviorWithFallbackToWebView) completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
            
            switch (state) {
                case FBSessionStateOpen:
                    successHandler(session);
                    
                    break;
                case FBSessionStateClosed:
                case FBSessionStateClosedLoginFailed:
                    if (error) {
                        failureHandler(state, error);
                    }
                    break;
                default:
                    if (error) {
                        failureHandler(state, error);
                    }
                    MAAssert(FALSE, @"State not handled");
                    break;
            }
        }];
    }
    else {
        if (![FBSession openActiveSessionWithPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:NO completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
            switch (state) {
                case FBSessionStateOpen:
                case FBSessionStateCreated:
                case FBSessionStateCreatedTokenLoaded:
                case FBSessionStateOpenTokenExtended:
                    successHandler(session);
                    
                    break;
                case FBSessionStateClosed:
                case FBSessionStateClosedLoginFailed:
                    if (error) {
                        failureHandler(state, error);
                    }
                    break;
                default:
                    if (error) {
                        failureHandler(state, error);
                    }
                    MAAssert(FALSE, @"State not handled");
                    break;
            }
        }]) {
            if ([[FBSession activeSession] isOpen]) {
                successHandler([FBSession activeSession]);
            }
            else {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"FBSession is not active"};
                NSError *error = [NSError errorWithDomain:@"Facebook" code:400 userInfo:userInfo];
                failureHandler([[FBSession activeSession] state], error);
            }
        }
    }
}

- (void)handleFacebookSessionDidBecomeOpenActiveSessionNotification:(NSNotification *)notification {
    DebugLog(@"FB session did become open active session.");
    
    if ([[FBSession activeSession] isOpen]) {
        [[SHAppUtil defaultInstance] fetchFacebookDetailsWithCompletionBlock:^(BOOL success, NSError *error) {
            if (error) {
                DebugLog(@"Error: %@", error);
                [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
            }
        }];
    }
}

#pragma mark - Twitter Connect
#pragma mark -

- (void)twitterChooseAccount:(UIView*)view success:(void(^)(ACAccount* account))successHandler cancel:(void(^)())cancelHandler noAccounts:(void(^)())noAccounts permissionDenied:(void(^)())permissionDeniedHandler {
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        // Did user allow us access?
        if (granted == YES)
        {
            // Populate array with all available Twitter accounts
            NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
            
            // Sanity check
            if ([arrayOfAccounts count] > 0)
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableArray* twitterAccountsArray = [NSMutableArray array];
                    
                    for (ACAccount *account in arrayOfAccounts) {
                        account.accountType = accountType;
                        [twitterAccountsArray addObject:account.accountDescription];
                    }
                    
                    [UIActionSheet showInView:view withTitle:@"Select account:" cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:twitterAccountsArray tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            cancelHandler();
                        }
                        else {
                            successHandler([arrayOfAccounts objectAtIndex:buttonIndex - 1]);
                        }
                    }];
                    
                });
                
            }
            else {
                noAccounts();
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                permissionDeniedHandler();
            });
        }
    }];
}

- (void)twitterAuth:(ACAccount*)account success:(void(^)(NSString *oAuthToken, NSString *oAuthTokenSecret, NSString *userID, NSString *screenName))successHandler failure:(void(^)(NSError *error))failureHandler {
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:nil
                                                              consumerKey:[SHAppConfiguration twitterConsumerKey]
                                                           consumerSecret:[SHAppConfiguration twitterConsumerSecret]];
    
    [twitter postReverseOAuthTokenRequest:^(NSString *authenticationHeader) {
        
        STTwitterAPI *twitterAPIOS = [STTwitterAPI twitterAPIOSWithAccount:account];
        
        [twitterAPIOS verifyCredentialsWithSuccessBlock:^(NSString *username) {
            
            [twitterAPIOS postReverseAuthAccessTokenWithAuthenticationHeader:authenticationHeader
                                                                successBlock:^(NSString *oAuthToken,
                                                                               NSString *oAuthTokenSecret,
                                                                               NSString *userID,
                                                                               NSString *screenName) {
                                                                    
                                                                    successHandler(oAuthToken, oAuthTokenSecret, userID, screenName);
                                                                    
                                                                } errorBlock:^(NSError *error) {
                                                                    failureHandler(error);
                                                                }];
            
        } errorBlock:^(NSError *error) {
            failureHandler(error);
        }];
        
    } errorBlock:^(NSError *error) {
        failureHandler(error);
    }];
}

- (BOOL)canPhone {
    return ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"tel://"]]);
}

- (BOOL)canSkype {
    return ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"skype:"]]);
}

- (void)callPhoneNumber:(NSString *)formattedPhoneNumber {
    NSCharacterSet *charactersToRemove = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *number = [[formattedPhoneNumber componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@"" ];
    
    NSString *urlString = [NSString stringWithFormat:@"tel://%@", number];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    });
}

- (void)skypePhoneNumber:(NSString *)formattedPhoneNumber {
    NSCharacterSet *charactersToRemove = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *number = [[formattedPhoneNumber componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@"" ];
    
    NSString *urlString = [NSString stringWithFormat:@"skype:%@?call", number];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    });
}

@end
