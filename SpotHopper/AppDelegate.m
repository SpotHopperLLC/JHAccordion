//
//  AppDelegate.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/26/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "AppDelegate.h"

#import "UIActionSheet+Block.h"

#import "ClientSessionManager.h"
#import "DrinkModel.h"
#import "ErrorModel.h"
#import "ReviewModel.h"
#import "SpotModel.h"
#import "UserModel.h"

#import "Mockery.h"

#import <JSONAPI/JSONAPI.h>
#import <Raven/RavenClient.h>
#import <STTwitter/STTwitter.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [[ClientSessionManager sharedClient] setHasSeenLaunch:NO];
    
    // Initializes Raven (Sentry) for error reporting/logging
    [RavenClient clientWithDSN:kSentryDSN];
    
    // Initializes resource linkng for JSONAPI
    [JSONAPIResourceLinker link:@"drink" toLinkedType:@"drinks"];
    [JSONAPIResourceLinker link:@"spot" toLinkedType:@"spots"];
    [JSONAPIResourceLinker link:@"review" toLinkedType:@"reviews"];
    [JSONAPIResourceLinker link:@"user" toLinkedType:@"users"];
    
    // Initializes model linking for JSONAPI
    [JSONAPIResourceModeler useResource:[DrinkModel class] toLinkedType:@"drinks"];
    [JSONAPIResourceModeler useResource:[ErrorModel class] toLinkedType:@"errors"];
    [JSONAPIResourceModeler useResource:[ReviewModel class] toLinkedType:@"reviews"];
    [JSONAPIResourceModeler useResource:[SpotModel class] toLinkedType:@"spots"];
    [JSONAPIResourceModeler useResource:[UserModel class] toLinkedType:@"users"];

    // Sets networking debug logs if debug is set
    [[ClientSessionManager sharedClient] setDebug:kDebug];
    
    // Open Facebook active session
    [self facebookAuth:NO success:^(FBSession *session) {

    } failure:^(FBSessionState state, NSError *error) {

    }];
    
    if (kMock) {
        [self startTheMockery];
    }
    
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

#pragma mark - Mockery

- (void)startTheMockery {
    [Mockery mockeryWithURL:kBaseUrl];
    
    /*
     * DRINKS
     */
    [Mockery get:@"/api/drinks" block:^MockeryHTTPURLResponse *(NSString *path, NSURLRequest *request, NSArray *routeParams) {
        NSDictionary *d1 = [self drinkForId:@1 withLinks:@{@"spot":@1}];
        
        NSArray *ds = @[d1];
        
        NSDictionary *jsonApi = @{
                                  @"drinks" : ds,
                                  @"linked" : @{
                                          @"spots" : @[
                                                  [self spotForId:@1 withLinks:nil]
                                                  ]
                                          }
                                  };
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonApi options:0 error:nil];
        
        return [MockeryHTTPURLResponse mockeryWithURL:request.URL statusCode:200 data:jsonData headerFields:[NSDictionary dictionary]];
    }];
    
    /*
     * REVIEWS
     */
    [Mockery get:@"/api/reviews" block:^MockeryHTTPURLResponse *(NSString *path, NSURLRequest *request, NSArray *routeParams) {
        NSDictionary *r1 = [self reviewForId:@1 withLinks:@{@"spot":@1}];
        NSDictionary *r2 = [self reviewForId:@2 withLinks:@{@"drink":@1}];
        
        NSArray *rs = @[r1, r2];
        
        NSDictionary *jsonApi = @{
                                  @"reviews" : rs,
                                  @"linked" : @{
                                          @"spots" : @[
                                                  [self spotForId:@1 withLinks:nil]
                                                  ]
                                          ,
                                          @"drinks" : @[
                                                  [self drinkForId:@1 withLinks:@{@"spot":@1}]
                                                  ]
                                          }
                                  };
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonApi options:0 error:nil];
        
        return [MockeryHTTPURLResponse mockeryWithURL:request.URL statusCode:200 data:jsonData headerFields:[NSDictionary dictionary]];
    }];
    
    /*
     * REVIEWS/<ID>
     */
    [Mockery post:[NSRegularExpression regularExpressionWithPattern:@"^/reviews/(\\d+)" options:NSRegularExpressionCaseInsensitive error:nil] block:^MockeryHTTPURLResponse *(NSString *path, NSURLRequest *request, NSArray *routeParams) {
        
        NSNumber *reviewId = [routeParams objectAtIndex:0];
        NSDictionary *r = [self reviewForId:reviewId withLinks:@{@"spot":@1}];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:r options:0 error:nil];
        
        return [MockeryHTTPURLResponse mockeryWithURL:request.URL statusCode:200 data:jsonData headerFields:[NSDictionary dictionary]];
    }];
    
    /*
     * SPOTSgi
     */
    [Mockery get:@"/api/spots" block:^MockeryHTTPURLResponse *(NSString *path, NSURLRequest *request, NSArray *routeParams) {
        NSDictionary *s1 = [self spotForId:@1 withLinks:nil];
        
        NSArray *ss = @[s1];
        
        NSDictionary *jsonApi = @{
                                  @"spots" : ss,
                                  @"linked" : @{
                                          }
                                  };
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonApi options:0 error:nil];
        
        return [MockeryHTTPURLResponse mockeryWithURL:request.URL statusCode:200 data:jsonData headerFields:[NSDictionary dictionary]];
    }];
}

#pragma mark - Data Helpers

- (NSDictionary*)drinkForId:(NSNumber*)ID withLinks:(NSDictionary*)links {
    if (links == nil) links = @{};
    if (ID.intValue == 1) {
        return @{
                 @"id": @1,
                 @"name": @"Boobs and Billiards Scotch",
                 @"image_url" : @"http://placekitten.com/300/300",
                 @"type": @"spirit",
                 @"subtype": @"scotch",
                 @"description": @"Super premium breasts and pool balls scotch which reeks of upper crust.",
                 @"alcohol_by_volume": @0.9,
                 @"style": @"IPA",
                 @"vintage": @1984,
                 @"region": @"Your mom's butt",
                 @"recipe": @"1 part boobs\n1part billiards",
                 @"links" : links
                 };
    }
    return nil;
}

- (NSDictionary*)spotForId:(NSNumber*)ID withLinks:(NSDictionary*)links {
    if (links == nil) links = @{};
    if (ID.intValue == 1) {
        return @{
                 @"id": @1,
                 @"name": @"Oatmeal Junction",
                 @"image_url" : @"http://placekitten.com/300/300",
                 @"type": @"Restaurant",
                 @"address": @"229 E Wisconsin Ave\nSuite #1102\nMilwaukee, WI 53202",
                 @"phone_number": @"715-539-8911",
                 @"hours_of_operation":@[
                         @[@"8:30-0500",@"16:00-0500"],
                         @[@"8:00-0500",@"20:00-0500"],
                         @[@"8:00-0500",@"20:00-0500"],
                         @[@"8:00-0500",@"20:00-0500"],
                         @[@"8:00-0500",@"20:00-0500"],
                         @[@"8:00-0500",@"20:00-0500"],
                         @[@"8:30-0500",@"18:00-0500"]
                         ],
                 @"latitude": @43.038513,
                 @"longitude": @-87.908913,
                 @"sliders":@[
                         @{@"id": @"radness", @"name": @"Radness", @"min": @"UnRad", @"max": @"Super Rad!", @"value": @10}
                         ],
                 @"links" : links
                 };
    }
    return nil;
}


- (NSDictionary*)userForId:(NSNumber*)ID withLinks:(NSDictionary*)links {
    if (links == nil) links = @{};
    if (ID.intValue == 1) {
        return @{
                 @"id": @1,
                 @"email": @"placeholder@rokkincat.com",
                 @"role": @"admin",
                 @"name": @"Nick Gartmann",
                 @"birthday": @"1989-02-03",
                 @"settings": @{},
                 @"links" : links
                 };
    }
    return nil;
}

- (NSDictionary*)reviewForId:(NSNumber*)ID withLinks:(NSDictionary*)links {
    if (links == nil) links = @{};
    if (ID.intValue == 1) {
        return @{
                 @"id": @1,
                 @"rating": @9,
                 @"sliders": @[
                         @{@"id": @"radness", @"name": @"Radness", @"min": @"UnRad", @"max": @"Super Rad!", @"value": @9}
                         ],
                 @"created_at": @"2014-01-01T15:12:43+00:00",
                 @"updated_at": @"2014-01-01T15:12:43+00:00",
                 @"links" : links
                 
                 };
    } else if (ID.intValue == 2) {
        return @{
                 @"id": @2,
                 @"rating": @5,
                 @"sliders": @[
                         @{@"id": @"radness", @"name": @"Radness", @"min": @"UnRad", @"max": @"Super Rad!", @"value": @4}
                         ],
                 @"created_at": @"2014-01-01T15:12:43+00:00",
                 @"updated_at": @"2014-01-01T15:12:43+00:00",
                 @"links" : links
                 
                 };
    }
    return nil;
}

@end
