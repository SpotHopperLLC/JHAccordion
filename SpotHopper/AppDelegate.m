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
#import "DrinkModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubtypeModel.h"
#import "DrinkListModel.h"
#import "ErrorModel.h"
#import "ImageModel.h"
#import "LiveSpecialModel.h"
#import "MenuItemModel.h"
#import "MenuTypeModel.h"
#import "ReviewModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"
#import "SpotModel.h"
#import "SpotTypeModel.h"
#import "SpotListModel.h"
#import "SpotListMoodModel.h"
#import "UserModel.h"

#import "MockData.h"

#import "TellMeMyLocation.h"

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <JSONAPI/JSONAPI.h>
#import <Raven/RavenClient.h>
#import <STTwitter/STTwitter.h>

@interface AppDelegate()

@property (nonatomic, strong) Mockery *mockery;
@property (nonatomic, strong) TellMeMyLocation *tellMeMyLocation;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [[ClientSessionManager sharedClient] setHasSeenLaunch:NO];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // Location finder
    _tellMeMyLocation = [[TellMeMyLocation alloc] init];
    
    // Initializes Raven (Sentry) for error reporting/logging
    [RavenClient clientWithDSN:kSentryDSN];
    [[RavenClient sharedClient] setupExceptionHandler];
    
    // Initializes resource linkng for JSONAPI
    [JSONAPIResourceLinker link:@"average_review" toLinkedType:@"average_reviews"];
    [JSONAPIResourceLinker link:@"base_alcohol" toLinkedType:@"base_alcohols"];
    [JSONAPIResourceLinker link:@"drink" toLinkedType:@"drinks"];
    [JSONAPIResourceLinker link:@"drink_type" toLinkedType:@"drink_types"];
    [JSONAPIResourceLinker link:@"drink_subtype" toLinkedType:@"drink_subtypes"];
    [JSONAPIResourceLinker link:@"drink_list" toLinkedType:@"drink_lists"];
    [JSONAPIResourceLinker link:@"image" toLinkedType:@"images"];
    [JSONAPIResourceLinker link:@"live_special" toLinkedType:@"live_specials"];
    [JSONAPIResourceLinker link:@"menu_item" toLinkedType:@"menu_items"];
    [JSONAPIResourceLinker link:@"menu_type" toLinkedType:@"menu_types"];
    [JSONAPIResourceLinker link:@"review" toLinkedType:@"reviews"];
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
    [JSONAPIResourceModeler useResource:[DrinkModel class] toLinkedType:@"drinks"];
    [JSONAPIResourceModeler useResource:[DrinkTypeModel class] toLinkedType:@"drink_types"];
    [JSONAPIResourceModeler useResource:[DrinkSubtypeModel class] toLinkedType:@"drink_subtypes"];
    [JSONAPIResourceModeler useResource:[DrinkListModel class] toLinkedType:@"drink_lists"];
    [JSONAPIResourceModeler useResource:[ErrorModel class] toLinkedType:@"errors"];
    [JSONAPIResourceModeler useResource:[ImageModel class] toLinkedType:@"images"];
    [JSONAPIResourceModeler useResource:[LiveSpecialModel class] toLinkedType:@"live_specials"];
    [JSONAPIResourceModeler useResource:[MenuItemModel class] toLinkedType:@"menu_items"];
    [JSONAPIResourceModeler useResource:[MenuTypeModel class] toLinkedType:@"menu_types"];
    [JSONAPIResourceModeler useResource:[ReviewModel class] toLinkedType:@"reviews"];
    [JSONAPIResourceModeler useResource:[SliderModel class] toLinkedType:@"sliders"];
    [JSONAPIResourceModeler useResource:[SliderTemplateModel class] toLinkedType:@"slider_templates"];
    [JSONAPIResourceModeler useResource:[SpotModel class] toLinkedType:@"spots"];
    [JSONAPIResourceModeler useResource:[SpotTypeModel class] toLinkedType:@"spot_types"];
    [JSONAPIResourceModeler useResource:[SpotListModel class] toLinkedType:@"spot_lists"];
    [JSONAPIResourceModeler useResource:[SpotListMoodModel class] toLinkedType:@"spot_list_moods"];
    [JSONAPIResourceModeler useResource:[UserModel class] toLinkedType:@"users"];

    // Navigation bar styling
    [[UINavigationBar appearance] setTintColor:kColorOrange];
    
    // Sets networking debug logs if debug is set
    [[ClientSessionManager sharedClient] setDebug:kDebug];
    
    // Initializes cookie for network calls
    [[ClientSessionManager sharedClient] isLoggedIn];
    
    // Open Facebook active session
    [self facebookAuth:NO success:^(FBSession *session) {
        NSLog(@"We got activite session");
    } failure:^(FBSessionState state, NSError *error) {
        NSLog(@"We DONT got activite session");
    }];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSession.activeSession handleDidBecomeActive];
    
    NSDate *date = [TellMeMyLocation lastLocationDate];
    if (date != nil && abs([date timeIntervalSinceNow]) > kRefreshLocationTime) {
        [_tellMeMyLocation findMe:kCLLocationAccuracyThreeKilometers found:^(CLLocation *newLocation) {
            [TellMeMyLocation setLastLocation:newLocation completionHandler:^{
                
            }];
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
