//
//  AppDelegate.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/26/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "AppDelegate.h"

#import "NSNumber+Helpers.h"
#import "UIActionSheet+Block.h"

#import "SHNavigationBar.h"
#import "SHAppConfiguration.h"
#import "SHAppUtil.h"

#import "ClientSessionManager.h"
#import "SHModelResourceManager.h"

#import "UserState.h"
#import "MockData.h"

#import "TellMeMyLocation.h"
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

#import "Crashlytics.h"

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <JSONAPI/JSONAPI.h>
#import <Parse/Parse.h>
#import <STTwitter/STTwitter.h>

@interface AppDelegate()

@property (nonatomic, strong) Mockery *mockery;

@end

@implementation AppDelegate {
    TellMeMyLocation *_tellMeMyLocation;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SHModelResourceManager prepareResources];

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    if ([SHAppConfiguration parseApplicationID].length) {
        // Initialize Parse
        [Parse setApplicationId:[SHAppConfiguration parseApplicationID]
                      clientKey:[SHAppConfiguration parseClientKey]];
        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        [PFUser enableAutomaticUser];
    }
    
    // Prompts user for permission to send notifications
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)] && [application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    else {
        UIRemoteNotificationType types = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:types];
    }
    
    if ([SHAppConfiguration isCrashlyticsEnabled]) {
        NSString *crashlyticsKey = [SHAppConfiguration crashlyticsKey];
        [Crashlytics startWithAPIKey:crashlyticsKey];
        
        if ([UserModel isLoggedIn]) {
            UserModel *user = [[ClientSessionManager sharedClient] currentUser];
            [[Crashlytics sharedInstance] setUserIdentifier:user.ID];
            if (user.email.length) {
                [[Crashlytics sharedInstance] setUserEmail:user.email];
            }
        }
    }
    
    FBSessionTokenCachingStrategy *cachingStrategy = [FBSessionTokenCachingStrategy defaultInstance];
    if ([FBSessionTokenCachingStrategy isValidTokenInformation:[cachingStrategy fetchTokenInformation]]) {
        [FBSession openActiveSessionWithAllowLoginUI:NO];
    }
    
    if ([[FBSession activeSession] isOpen]) {
        [[SHAppUtil defaultInstance] fetchFacebookDetailsWithCompletionBlock:^(BOOL success, NSError *error) {
            if (error) {
                DebugLog(@"Error: %@", error);
                [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
            }
        }];
    }
    else {
        DebugLog(@"Facebook session is not active");
    }
    
//#ifndef NDEBUG
//    
//    NSString *drinksType = [[JSONAPIResourceLinker defaultInstance] linkedType:@"drinks"];
//    Class drinksClass = [[JSONAPIResourceModeler defaultInstance] resourceForLinkedType:drinksType];
//    NSLog(@"Drinks Class: %@", NSStringFromClass(drinksClass));
//    
//    NSString *spotsType = [[JSONAPIResourceLinker defaultInstance] linkedType:@"spots"];
//    Class spotsClass = [[JSONAPIResourceModeler defaultInstance] resourceForLinkedType:spotsType];
//    NSLog(@"Spots Class: %@", NSStringFromClass(spotsClass));
//    
//    NSLog(@"Linker: %@", [JSONAPIResourceLinker defaultInstance]);
//    NSLog(@"Modeler: %@", [JSONAPIResourceModeler defaultInstance]);
//    
//    JSONAPIResourceLinker *linker = [JSONAPIResourceLinker defaultInstance];
//    JSONAPIResourceModeler *modeler = [JSONAPIResourceModeler defaultInstance];
//    
//    NSAssert([linker isEqual:[JSONAPIResourceLinker defaultInstance]], @"Linker must equal default instance");
//    NSAssert([modeler isEqual:[JSONAPIResourceModeler defaultInstance]], @"Modeler must equal default instance");
//    
//#endif
    
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
            [TellMeMyLocation setLastLocation:[TellMeMyLocation currentDeviceLocation] completionHandler:^{
                CLLocation *location = [TellMeMyLocation lastLocation];
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
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler {
    DebugLog(@"%@, %@, %@", NSStringFromSelector(_cmd), identifier, userInfo);
    
    // TODO review for iOS 8 changes to Push Notifications
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current Installation and save it to Parse.
    if ([SHAppConfiguration parseApplicationID].length) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setDeviceTokenFromData:deviceToken];
        [currentInstallation saveInBackground];
        
        [[SHAppUtil defaultInstance] updateParse];
    }

    // prepare Mixpanel to send notifications to this device
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:mixpanel.distinctId];
    [mixpanel.people addPushDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    [self handlePush:userInfo inForeground:(application.applicationState == UIApplicationStateActive)];
}

- (void)handlePush:(NSDictionary*)payload inForeground:(BOOL)inForeground {
    if (payload != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPushReceived object:self userInfo:payload];
    }
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

#pragma mark - Location

- (void)refreshDeviceLocationWithCompletionBlock:(void (^)())completionBlock {
    if (!_tellMeMyLocation) {
        _tellMeMyLocation = [[TellMeMyLocation alloc] init];
    }
    
    // Gets current location
    [_tellMeMyLocation findMe:kCLLocationAccuracyHundredMeters found:^(CLLocation *newLocation) {
        
        // Saves current location
        [TellMeMyLocation setLastLocation:newLocation completionHandler:^{
            if (completionBlock) {
                completionBlock();
            }
        }];
        
    } failure:^(NSError *error) {
        [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

#pragma mark - Facebook Connect

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
