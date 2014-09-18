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

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <JSONAPI/JSONAPI.h>
#import <Parse/Parse.h>
#import <Raven/RavenClient.h>
#import <STTwitter/STTwitter.h>

@interface AppDelegate()

@property (nonatomic, strong) Mockery *mockery;

@end

@implementation AppDelegate {
    TellMeMyLocation *_tellMeMyLocation;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [[ClientSessionManager sharedClient] setHasSeenLaunch:NO];

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    if ([SHAppConfiguration parseApplicationID].length) {
        // Initialize Parse
        [Parse setApplicationId:[SHAppConfiguration parseApplicationID]
                      clientKey:[SHAppConfiguration parseClientKey]];
        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    }
    
    // Prompts user for permission to send notifications
    UIRemoteNotificationType types = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
    [application registerForRemoteNotificationTypes:types];
    
    // Initializes Raven (Sentry) for error reporting/logging
    [RavenClient clientWithDSN:kSentryDSN];
    [[RavenClient sharedClient] setupExceptionHandler];
    
    [SHModelResourceManager prepareResources];
    
#ifndef NDEBUG
    
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
    
    NSAssert([linker isEqual:[JSONAPIResourceLinker defaultInstance]], @"Linker must equal default instance");
    NSAssert([modeler isEqual:[JSONAPIResourceModeler defaultInstance]], @"Modeler must equal default instance");
    
#endif
    
    // Navigation bar styling
    [[UINavigationBar appearance] setTintColor:kColorOrange];
    
    // Sets networking debug logs if debug is set
    [[ClientSessionManager sharedClient] setDebug:[SHAppConfiguration isDebuggingEnabled]];
    
    // Initializes cookie for network calls
    [[ClientSessionManager sharedClient] isLoggedIn];
    
    // Open Facebook active session
    [self facebookAuth:NO success:^(FBSession *session) {
        NSLog(@"We have an active FB session");
    } failure:^(FBSessionState state, NSError *error) {
        NSLog(@"We DON'T have an active FB session");
        [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
    
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
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BFURL *parsedUrl = [BFURL URLWithURL:url];
    
    NSString *fullURLString = parsedUrl.targetURL.absoluteString;
    NSInteger maximumExpectedLength = 2048;
    
    if (!fullURLString.length || fullURLString.length > maximumExpectedLength) {
        // The URL is longer than we expect. Stop servicing it.
        return NO;
    }
    
    if ([self isURLSchemePrefixForURLString:fullURLString] || [fullURLString hasPrefix:[SHAppConfiguration websiteUrl]]) {
        self.openedURL = parsedUrl.targetURL;
        if (parsedUrl.appLinkReferer.sourceURL) {
            self.sourceURL = parsedUrl.appLinkReferer.sourceURL;
        }
        
        NSURL *targetURL = parsedUrl.targetURL;
        NSURL *sourceURL = parsedUrl.appLinkReferer.sourceURL;
        [Tracker trackDeepLinkWithTargetURL:targetURL sourceURL:sourceURL sourceApplication:sourceApplication];
        
        [SHNotifications appOpenedWithURL:url];
        return YES;
    }
    else {
        return [FBSession.activeSession handleOpenURL:url];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current Installation and save it to Parse.
    if ([SHAppConfiguration parseApplicationID].length) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setDeviceTokenFromData:deviceToken];
        [currentInstallation saveInBackground];
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
    
    if ([[FBSession activeSession] isOpen] == YES) {
        successHandler([FBSession activeSession]);
        return;
    }
    
    if (allowLogin == YES) {
        FBSession* sess = [[FBSession alloc] initWithPermissions:[NSArray arrayWithObject:@"publish_actions, email"]];
        [FBSession setActiveSession:sess];
        [sess openWithBehavior:(FBSessionLoginBehaviorWithFallbackToWebView) completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
            
            switch (state) {
                case FBSessionStateOpen:
//                    [FBSession setActiveSession:session];
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
                    break;
            }
            
        }];
    }
    else {
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:NO completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
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
                    break;
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

@end
