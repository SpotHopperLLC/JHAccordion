//
//  AppDelegate.h
//  SpotHopper
//
//  Created by Josh Holtz on 12/26/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSURL *openedURL;

- (void)facebookAuth:(BOOL)allowLogin success:(void(^)(FBSession *session))successHandler failure:(void(^)(FBSessionState state, NSError *error))failureHandler;

- (void)twitterChooseAccount:(UIView*)view success:(void(^)(ACAccount* account))successHandler cancel:(void(^)())cancelHandler noAccounts:(void(^)())noAccounts permissionDenied:(void(^)())permissionDeniedHandler;
- (void)twitterAuth:(ACAccount*)account success:(void(^)(NSString *oAuthToken, NSString *oAuthTokenSecret, NSString *userID, NSString *screenName))successHandler failure:(void(^)(NSError *error))failureHandler;

@end
