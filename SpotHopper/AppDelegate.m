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

#import "ClientSessionManager.h"
#import "AverageReviewModel.h"
#import "BaseAlcoholModel.h"
#import "CheckInModel.h"
#import "DrinkModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubtypeModel.h"
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
#import "UserModel.h"
#import "UserState.h"

#import "MockData.h"

#import "TellMeMyLocation.h"

#import "Mixpanel.h"
#import "GAI.h"
#import "iRate.h"
#import "Tracker.h"
#import "UserState.h"

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <JSONAPI/JSONAPI.h>
#import <Parse/Parse.h>
#import <Raven/RavenClient.h>
#import <STTwitter/STTwitter.h>

@interface AppDelegate() <iRateDelegate>

@property (nonatomic, strong) Mockery *mockery;

@end

@implementation AppDelegate {
    TellMeMyLocation *_tellMeMyLocation;
}

+ (void)initialize {
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 5;
    [iRate sharedInstance].usesUntilPrompt = 15;
    [iRate sharedInstance].onlyPromptIfLatestVersion = YES;
    
#ifdef PRODUCTION
    // enable preview mode in non-production targets
    [iRate sharedInstance].previewMode = NO;
#endif
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [[ClientSessionManager sharedClient] setHasSeenLaunch:NO];
    
    [iRate sharedInstance].delegate = self;
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    if (kParseApplicationID.length) {
        // Initialize Parse
        [Parse setApplicationId:kParseApplicationID
                      clientKey:kParseClientKey];
        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
         UIRemoteNotificationTypeAlert|
         UIRemoteNotificationTypeSound];
    }
    
    // Initializes Raven (Sentry) for error reporting/logging
    [RavenClient clientWithDSN:kSentryDSN];
    [[RavenClient sharedClient] setupExceptionHandler];
    
    [self prepareResources];
    
    // Navigation bar styling
    [[UINavigationBar appearance] setTintColor:kColorOrange];
    
    // Sets networking debug logs if debug is set
    [[ClientSessionManager sharedClient] setDebug:kDebug];
    
    // Initializes cookie for network calls
    [[ClientSessionManager sharedClient] isLoggedIn];
    
    // Open Facebook active session
    [self facebookAuth:NO success:^(FBSession *session) {
        NSLog(@"We have an active FB session");
    } failure:^(FBSessionState state, NSError *error) {
        NSLog(@"We DON'T have an active FB session");
    }];

    if (kAnalyticsEnabled) {
        [Mixpanel sharedInstanceWithToken:kMixPanelToken];
//        Examples:
//        Mixpanel *mixpanel = [Mixpanel sharedInstance];
//        [mixpanel track:@"Plan Selected" properties:@{@"Gender": @"Female", @"Plan": @"Premium"}];
//        [mixpanel identify:@"13793"]; // once the user is logged in set their identity
        [[Mixpanel sharedInstance] track:@"App Launching" properties:@{@"currentTime" : [NSDate date]}];
        
        // Optional: automatically send uncaught exceptions to Google Analytics.
        [GAI sharedInstance].trackUncaughtExceptions = YES;
        
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        [GAI sharedInstance].dispatchInterval = 20;
        
        // Optional: set Logger to VERBOSE for debug information.
        [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelWarning];
        
        // Initialize tracker. Replace with your tracking ID.
        [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticsTrackingId];
    }
    
    NSDate *firstUseDate = [UserState firstUseDate];
    if (!firstUseDate) {
        [UserState setFirstUseDate:[NSDate date]];
        if (kAnalyticsEnabled) {
            [[Mixpanel sharedInstance] track:@"First Use"];
        }
    }

    if ([ClientSessionManager sharedClient].isLoggedIn) {
        [self refreshDeviceLocationWithCompletionBlock:^{
            NSDate *date = [TellMeMyLocation lastLocationDate];
            if (date != nil && abs([date timeIntervalSinceNow]) > kRefreshLocationTime) {
                [TellMeMyLocation setLastLocation:[TellMeMyLocation currentDeviceLocation] completionHandler:^{

                    CLLocation *location = [TellMeMyLocation lastLocation];
                    if (location) {
                        UserModel *user = [[ClientSessionManager sharedClient] currentUser];
                        [user putUser:@{ kUserModelParamLatitude : [NSNumber numberWithFloat:location.coordinate.latitude],
                                         kUserModelParamLongitude : [NSNumber numberWithFloat:location.coordinate.longitude]
                                         } success:^(UserModel *userModel, NSHTTPURLResponse *response) {
                            
                        } failure:^(ErrorModel *errorModel) {
                            
                        }];
                    }
                    
                }];
            }
        }];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSString *fullURLString = [url absoluteString];
    
    if (!fullURLString.length) {
        // The URL's absoluteString is nil. There's nothing more to do.
        return NO;
    }
    
    NSInteger maximumExpectedLength = 2048;
    
    if ([fullURLString length] > maximumExpectedLength) {
        // The URL is longer than we expect. Stop servicing it.
        return NO;
    }
    
    if ([kAppURLScheme length] && [fullURLString hasPrefix:kAppURLScheme]) {
        self.openedURL = url;
        return YES;
    }
    else {
        return [FBSession.activeSession handleOpenURL:url];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current Installation and save it to Parse.
    if (kParseApplicationID.length) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setDeviceTokenFromData:deviceToken];
        [currentInstallation saveInBackground];
    }
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
    [self refreshDeviceLocationWithCompletionBlock:^{
        // do nothing
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Private

- (void)prepareResources {
    // Initializes resource linkng for JSONAPI
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
    [JSONAPIResourceLinker link:@"user" toLinkedType:@"users"];
    
    // Initializes model linking for JSONAPI
    [JSONAPIResourceModeler useResource:[AverageReviewModel class] toLinkedType:@"average_reviews"];
    [JSONAPIResourceModeler useResource:[BaseAlcoholModel class] toLinkedType:@"base_alcohols"];
    [JSONAPIResourceModeler useResource:[CheckInModel class] toLinkedType:@"checkins"];
    [JSONAPIResourceModeler useResource:[DrinkModel class] toLinkedType:@"drinks"];
    [JSONAPIResourceModeler useResource:[DrinkTypeModel class] toLinkedType:@"drink_types"];
    [JSONAPIResourceModeler useResource:[DrinkSubtypeModel class] toLinkedType:@"drink_subtypes"];
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
    [JSONAPIResourceModeler useResource:[UserModel class] toLinkedType:@"users"];
}

#pragma mark - Location

- (void)refreshDeviceLocationWithCompletionBlock:(void (^)())completionBlock {
    if (!_tellMeMyLocation) {
        _tellMeMyLocation = [[TellMeMyLocation alloc] init];
    }
    
    [_tellMeMyLocation findMe:kCLLocationAccuracyHundredMeters found:^(CLLocation *newLocation) {
        if (completionBlock) {
            completionBlock();
        }
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - iRateDelegate

- (BOOL)iRateShouldPromptForRating {
    // if the user is logged in and has either 3 spotlists or 3 drinklists
    // which makes them very likely a happy user of the app
    // prompt the user only on the home screen
    
    NSNumber *spotlistCount = [UserState spotlistCount];
    NSNumber *drinklistCount = [UserState drinklistCount];
    
    return spotlistCount.unsignedIntegerValue > 3 || drinklistCount.unsignedIntegerValue > 3;
}

- (void)iRateDidDetectAppUpdate {
    [Tracker track:@"iRate Detected Update"];
}

- (void)iRateDidPromptForRating {
    [Tracker track:@"iRate did Prompt to Rate"];
}

- (void)iRateUserDidAttemptToRateApp {
    [Tracker track:@"iRate Attempted to Rate"];
}

- (void)iRateUserDidDeclineToRateApp {
    [Tracker track:@"iRate Declined to Rate"];
}

- (void)iRateUserDidRequestReminderToRateApp {
    [Tracker track:@"iRate Requested Reminder"];
}

- (void)iRateDidOpenAppStore {
    [Tracker track:@"iRate Opened App Store"];
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
    } else {
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
                        } else {
                            successHandler([arrayOfAccounts objectAtIndex:buttonIndex - 1]);
                        }
                    }];
                    
                });
                
            } else {
                noAccounts();
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                permissionDeniedHandler();
            });
        }
    }];
}

- (void)twitterAuth:(ACAccount*)account success:(void(^)(NSString *oAuthToken, NSString *oAuthTokenSecret, NSString *userID, NSString *screenName))successHandler failure:(void(^)(NSError *error))failureHandler {
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:nil
                                                              consumerKey:kTwitterConsumerKey
                                                           consumerSecret:kTwitterConsumerSecret];
    
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
