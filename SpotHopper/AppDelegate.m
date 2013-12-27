//
//  AppDelegate.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/26/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "AppDelegate.h"

#import "ClientSessionManager.h"

#import <Raven/RavenClient.h>
#import <STTwitter/STTwitter.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Initializes Raven (Sentry) for error reporting/logging
    [RavenClient clientWithDSN:kSentryDSN];

    // Sets networking debug logs if debug is set
    [[ClientSessionManager sharedClient] setDebug:kDebug];
    
    // Open Facebook active session
    [self openFacebookSession:NO success:^(FBSession *session) {

    } failure:^(FBSessionState state, NSError *error) {

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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Facebook Connect

- (void)openFacebookSession:(BOOL)allowLogin success:(void(^)(FBSession *session))successHandler failure:(void(^)(FBSessionState state, NSError *error))failureHandler {
    
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

- (void)reverseAuthWithTwitter:(void(^)(NSString *oAuthToken, NSString *oAuthTokenSecret, NSString *userID, NSString *screenName))successHandler failure:(void(^)(NSError *error))failureHandler {
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:nil
                                                              consumerKey:kTwitterConsumerKey
                                                           consumerSecret:kTwitterConsumerSecret];
    
    [twitter postReverseOAuthTokenRequest:^(NSString *authenticationHeader) {
        
        STTwitterAPI *twitterAPIOS = [STTwitterAPI twitterAPIOSWithFirstAccount];
        
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
