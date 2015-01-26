//
//  SHAppUtil.m
//  SpotHopper
//
//  Created by Brennan Stehling on 9/24/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHAppUtil.h"

#import "SHAppConfiguration.h"
#import "SHAppContext.h"
#import "ClientSessionManager.h"

#import "SpotModel.h"
#import "SpecialModel.h"
#import "DrinkModel.h"
#import "CheckInModel.h"

#import "ImageUtil.h"
#import "SSTURLShortener.h"

#import "Tracker.h"
#import "Tracker+Events.h"
#import "Tracker+People.h"

#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

#define kMeterToMile 0.000621371f
#define kMetersPerMile 1609.344

#define kLastCheckInPromptDateKey @"LastCheckInPromptDate"

#ifndef NDEBUG
// 3 minutes
#define kCheckInPromptCooldownPeriodInSeconds 60 * 3
#else
// 5 days
#define kCheckInPromptCooldownPeriodInSeconds 60 * 3
//#define kCheckInPromptCooldownPeriodInSeconds 60*60*24*5
#endif

#pragma mark - Class Extension
#pragma mark -

@interface SHAppUtil ()

@property (strong, nonatomic) NSDate *lastCheckInPromptDate;

@end

@implementation SHAppUtil

+ (instancetype)defaultInstance {
    static SHAppUtil *defaultInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        defaultInstance = [[SHAppUtil alloc] init];
    });
    return defaultInstance;
}

#pragma mark - Properties
#pragma mark -

- (NSDate *)lastCheckInPromptDate {
    NSDate *date = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:kLastCheckInPromptDateKey];
    if (!date) {
        return [NSDate distantPast];
    }
    return date;
}

- (void)setLastCheckInPromptDate:(NSDate *)date {
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:kLastCheckInPromptDateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Sharing
#pragma mark -

- (void)shareSpecial:(SpecialModel *)special atSpot:(SpotModel *)spot withViewController:(UIViewController *)vc {
    if (!spot.highlightImage) {
        [self shareSpecial:special atSpot:spot image:nil withViewController:vc];
    }
    else {
        [ImageUtil loadImage:spot.highlightImage placeholderImage:nil withThumbImageBlock:nil withFullImageBlock:^(UIImage *fullImage) {
            [self shareSpecial:special atSpot:spot image:fullImage withViewController:vc];
        } withErrorBlock:^(NSError *error) {
            [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
}

- (void)shareSpecial:(SpecialModel *)special atSpot:(SpotModel *)spot image:(UIImage *)image withViewController:(UIViewController *)vc {
    [Tracker trackSharingSpecial:special atSpot:spot];
    NSString *link = [NSString stringWithFormat:@"%@/spots/%lu/specials/%i", [SHAppConfiguration websiteUrl], (unsigned long)[spot.ID integerValue], (int)special.weekday];
    
    // go.spotapps.co -> www.spothopperapp.com
    [SSTURLShortener shortenURL:[NSURL URLWithString:link] username:[SHAppConfiguration bitlyUsername] apiKey:[SHAppConfiguration bitlyAPIKey] withCompletionBlock:^(NSURL *shortenedURL, NSError *error) {
        NSString *specialText = special.text;
        
        NSMutableArray *activityItems = @[].mutableCopy;
        [activityItems addObject:[NSString stringWithFormat:@"Special at %@", spot.name]];
        [activityItems addObject:specialText.length ? specialText : @""];
        if (shortenedURL) {
            [activityItems addObject:shortenedURL];
        }
//        [activityItems addObject:[NSURL URLWithString:link]];
//        if (image) {
//            [activityItems addObject:image];
//        }
        NSMutableArray *activities = @[].mutableCopy;
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activities];
        
        [vc presentViewController:activityView animated:YES completion:nil];
    }];
}

- (void)shareSpot:(SpotModel *)spot withViewController:(UIViewController *)vc {
    if (!spot.highlightImage) {
        [self shareSpot:spot image:nil withViewController:vc];
    }
    else {
        [ImageUtil loadImage:spot.highlightImage placeholderImage:nil withThumbImageBlock:nil withFullImageBlock:^(UIImage *fullImage) {
            [self shareSpot:spot image:fullImage withViewController:vc];
        } withErrorBlock:^(NSError *error) {
            [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
}

- (void)shareSpot:(SpotModel *)spot image:(UIImage *)image withViewController:(UIViewController *)vc {
    [Tracker trackSharingSpot:spot];
    NSString *link = [NSString stringWithFormat:@"%@/spots/%lu", [SHAppConfiguration websiteUrl], (unsigned long)[spot.ID integerValue]];

    // go.spotapps.co -> www.spothopperapp.com
    [SSTURLShortener shortenURL:[NSURL URLWithString:link] username:[SHAppConfiguration bitlyUsername] apiKey:[SHAppConfiguration bitlyAPIKey] withCompletionBlock:^(NSURL *shortenedURL, NSError *error) {
        NSMutableArray *activityItems = @[].mutableCopy;
        [activityItems addObject:spot.name.length ? spot.name : @""];
        [activityItems addObject:shortenedURL];
//        [activityItems addObject:[NSURL URLWithString:link]];
//        if (image) {
//            [activityItems addObject:image];
//        }
        NSMutableArray *activities = @[].mutableCopy;
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activities];
        
        [vc presentViewController:activityView animated:YES completion:nil];
    }];
}

- (void)shareDrink:(DrinkModel *)drink withViewController:(UIViewController *)vc {
    if (!drink.highlightImage) {
        [self shareDrink:drink image:nil withViewController:vc];
    }
    else {
        [ImageUtil loadImage:drink.highlightImage placeholderImage:nil withThumbImageBlock:nil withFullImageBlock:^(UIImage *fullImage) {
            [self shareDrink:drink image:fullImage withViewController:vc];
        } withErrorBlock:^(NSError *error) {
            [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
}

- (void)shareDrink:(DrinkModel *)drink image:(UIImage *)image withViewController:(UIViewController *)vc {
    [Tracker trackSharingDrink:drink];
    NSString *link = [NSString stringWithFormat:@"%@/drinks/%lu", [SHAppConfiguration websiteUrl], (unsigned long)[drink.ID integerValue]];
    
    // go.spotapps.co -> www.spothopperapp.com
    [SSTURLShortener shortenURL:[NSURL URLWithString:link] username:[SHAppConfiguration bitlyUsername] apiKey:[SHAppConfiguration bitlyAPIKey] withCompletionBlock:^(NSURL *shortenedURL, NSError *error) {
        
        NSMutableArray *activityItems = @[].mutableCopy;
        [activityItems addObject:drink.name.length ? drink.name : @""];
        [activityItems addObject:shortenedURL];
        NSMutableArray *activities = @[].mutableCopy;
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activities];
        
        [vc presentViewController:activityView animated:YES completion:nil];
    }];
}

- (void)shareCheckin:(CheckInModel *)checkin withViewController:(UIViewController *)vc {
    if (!checkin.spot.highlightImage) {
        [self shareCheckin:checkin image:nil withViewController:vc];
    }
    else {
        [ImageUtil loadImage:checkin.spot.highlightImage placeholderImage:nil withThumbImageBlock:nil withFullImageBlock:^(UIImage *fullImage) {
            [self shareCheckin:checkin image:fullImage withViewController:vc];
        } withErrorBlock:^(NSError *error) {
            [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
}

- (void)shareCheckin:(CheckInModel *)checkin image:(UIImage *)image withViewController:(UIViewController *)vc {
    [Tracker trackSharingCheckin:checkin];
    NSString *link = [NSString stringWithFormat:@"%@/checkins/%@", [SHAppConfiguration websiteUrl], checkin.ID];
    
    // go.spotapps.co -> www.spothopperapp.com
    [SSTURLShortener shortenURL:[NSURL URLWithString:link] username:[SHAppConfiguration bitlyUsername] apiKey:[SHAppConfiguration bitlyAPIKey] withCompletionBlock:^(NSURL *shortenedURL, NSError *error) {
        
        NSMutableArray *activityItems = @[].mutableCopy;
         
        [activityItems addObject:[NSString stringWithFormat:@"Checked in at %@", checkin.spot.name.length ? checkin.spot.name : @""]];
        [activityItems addObject:shortenedURL];
        NSMutableArray *activities = @[].mutableCopy;
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activities];
        
        [vc presentViewController:activityView animated:YES completion:nil];
    }];
}

#pragma mark - Significant Location Changes
#pragma mark -

- (void)processSignificantLocationChange:(CLLocation *)location {
    // 1) check for expiration of the cool down period
    // 2) fetch nearby spots
    // 3) ask the user if they would like to check in with a local notification
    
    // disable local prompting to allow for remote pushes to handle it
    if (TRUE) {
        return;
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    if (application.applicationState == UIApplicationStateActive) {
        // prompting should not be triggered when the app is active
        [self logMessage:@"App is active, not prompting" location:location spot:nil];
        return;
    }
    else if (location.horizontalAccuracy > 100) {
        NSString *message = [NSString stringWithFormat:@"Location accuracy is not sufficient (%.1f)", location.horizontalAccuracy];
        [self logMessage:message location:location spot:nil];
        return;
    }
    else if ([location.timestamp timeIntervalSinceNow] > 30) {
        // if the location update is old do not use it
        // deferred/cached location updates could be reported which are out of date
        return;
    }
    else if (location.speed > 0.5) {
        // device must not be moving (driving past a spot)
        // speed is -1 when the device detects no movement
        // average walking speed is ~3 mph which is ~1.35 meters per second
        // the speed used here will ensure the user is essentially stopped
        return;
    }
    else if (![self isNowAGoodTimeForADrink]) {
        return;
    }
    
    // Networking communications is costly on the batter so a cool down period and other filtering
    // criteria are used to prevent frequent API calls which are not necessary
    
    // if it has been longer than the cool down period it is ok to prompt the user to check in
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:self.lastCheckInPromptDate];
    if (seconds > kCheckInPromptCooldownPeriodInSeconds) {
        [self setLastCheckInPromptDate:[NSDate date]];
        
        CLLocationDistance radius = 5000.0f * kMeterToMile;
        [[SpotModel fetchSpotsNearLocation:location radius:radius] then:^(NSArray *spots) {
            SpotModel *spot = spots.firstObject;
            if (spot) {
                CLLocationDistance distance = [spot.location distanceFromLocation:location];

                if (distance < 100.0) {
                    [Tracker trackUserPromptedToCheckIn];
                    [Tracker trackPromptedToCheckInAtSpot:spot];
                    [Tracker trackWentToSpot:spot];
                    [Tracker trackUserWentToSpot:spot];
                    [Tracker logInfo:@"Prompting to check in at spot" class:[self class] trace:NSStringFromSelector(_cmd)];
                    
                    NSDictionary *userInfo = @{
                                               @"action" : @"PromptForCheckIn",
                                               @"spotId" : spot.ID,
                                               @"name" : spot.name
                                               };
                    
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    notification.userInfo = userInfo;
                    notification.alertBody = [NSString stringWithFormat:@"Want to check in at %@?", spot.name];
                    notification.soundName = UILocalNotificationDefaultSoundName;
                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                    
                    [self logMessage:@"Prompted to check in" location:location spot:spot];
                }
                else {
                    NSString *message = [NSString stringWithFormat:@"Nearest spot is not close enough: %f meters", distance];
                    [Tracker logInfo:message class:[self class] trace:NSStringFromSelector(_cmd)];
                    [self logMessage:@"Not prompted to check in" location:location spot:spot];
                }
            }
            else {
                [Tracker logInfo:@"No spots found for prompting for check in" class:[self class] trace:NSStringFromSelector(_cmd)];
                [self logMessage:@"No spots nearby" location:location spot:nil];
            }
        } fail:^(id error) {
            [self logMessage:@"Failed to fetch spots" location:location spot:nil];
        } always:^{
        }];
    }
    else {
        DebugLog(@"Cooling down from prompting for check in...");
        NSString *message = [NSString stringWithFormat:@"Cooling down (%li)", (long)seconds];
        [self logMessage:message location:location spot:nil];
    }
}

- (void)logMessage:(NSString *)message location:(CLLocation *)location {
    [self logMessage:message location:location spot:nil];
}

- (void)logMessage:(NSString *)message location:(CLLocation *)location spot:(SpotModel *)spot {
    MAAssert(message.length, @"There must be a message");
    DebugLog(@"message: %@", message);
    
    CLLocationDistance distance = CGFLOAT_MAX;
    if (spot && location) {
        distance = [spot.location distanceFromLocation:location];
    }
    
    if ([SHAppConfiguration isParseEnabled]) {
        PFUser *currentUser = [PFUser currentUser];
        PFObject *messageLog = [PFObject objectWithClassName:@"MessageLog"];
        
        [messageLog setObject:message forKey:@"message"];

        if (distance != CGFLOAT_MAX) {
            [messageLog setObject:[NSNumber numberWithDouble:distance] forKey:@"distance"];
        }

        if (location) {
            PFGeoPoint *locationPoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
            [messageLog setObject:locationPoint forKey:@"location"];
            [messageLog setObject:[NSNumber numberWithDouble:location.speed] forKey:@"speed"];
            [messageLog setObject:[NSNumber numberWithDouble:location.course] forKey:@"course"];
        }
        if (spot) {
            [messageLog setObject:spot.name forKey:@"spot"];
        }
        
        [messageLog setObject:currentUser forKey:@"user"];
        
        [messageLog saveEventually:^(BOOL succeeded, NSError *error) {
            if (error) {
                DebugLog(@"Error: %@", error);
            }
        }];
    }
}

- (void)resetLastCheckInPromptDate {
    [self setLastCheckInPromptDate:[NSDate distantPast]];
}

- (BOOL)isNowAGoodTimeForADrink {
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSCalendarUnitWeekday|NSCalendarUnitHour fromDate:now];
    
    BOOL isWeekend = components.weekday == 7 || components.weekday == 0; // sat or sun

    // it is a good time for a drink on weekends after 11am and weekdays after 5pm
    return (isWeekend && components.hour >= 11) || (!isWeekend && components.hour >= 17);
}

#pragma mark - Parse
#pragma mark -

- (void)updateParse {
    if ([UserModel isLoggedIn] && [SHAppConfiguration isParseEnabled]) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        UserModel *currentUser = [UserModel currentUser];
        [currentInstallation addUniqueObject:[NSString stringWithFormat:@"user-%@", currentUser.ID] forKey:@"channels"];
        [currentInstallation addUniqueObject:currentUser.ID ? currentUser.ID : [NSNull null] forKey:@"spotHopperUserId"];
        [currentInstallation addUniqueObject:currentUser.email.length ? currentUser.email : [NSNull null] forKey:@"email"];
        [currentInstallation saveInBackground];
        
        // Value for currentUser is now always due to [PFUser enableAutomaticUser]
//        PFUser *parseUser = [PFUser currentUser];
//        [parseUser setObject:currentUser.ID forKey:@"spotHopperUserId"];
//        [parseUser setObject:currentUser.email.length ? currentUser.email : [NSNull null] forKey:@"spotHopperEmail"];
//        [parseUser saveInBackground];
        
        // The following code will require fetching the session token for the fetched user in order to use becomeInBackground
        // Right now it the session token is not returned when the PFUser is fetched by spotHopperUserId
        
//        PFQuery *query = [PFUser query];
//        [query whereKey:@"spotHopperUserId" equalTo:currentUser.ID];
//        [query includeKey:@"sessionToken"];
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            PFUser *parseUser = [PFUser currentUser];
//            
//            if (!error && objects.count) {
//                // become user
//                PFUser *existingUser = objects.firstObject;
//                DebugLog(@"current: %@", parseUser.sessionToken);
//                DebugLog(@"existing: %@", existingUser.sessionToken);
//                if (existingUser.sessionToken.length && ![parseUser.username isEqualToString:existingUser.username]) {
//                    [PFUser becomeInBackground:existingUser.sessionToken block:^(PFUser *user, NSError *error) {
//                        if (error) {
//                            DebugLog(@"Error: %@", error);
//                        }
//                        else {
//                            DebugLog(@"user: %@", user[@"spotHopperUserId"]);
//                        }
//                    }];
//                }
//                else {
//                    [parseUser setObject:currentUser.ID forKey:@"spotHopperUserId"];
//                    [parseUser setObject:currentUser.email.length ? currentUser.email : [NSNull null] forKey:@"email"];
//                    [parseUser saveInBackground];
//                }
//            }
//            else {
//                // Value for currentUser is now always due to [PFUser enableAutomaticUser]
//                [parseUser setObject:currentUser.ID forKey:@"spotHopperUserId"];
//                [parseUser setObject:currentUser.email.length ? currentUser.email : [NSNull null] forKey:@"email"];
//                [parseUser saveInBackground];
//            }
//        }];
    }
}

- (void)becomeSpotHopperUserWithCompletionBlock:(void (^)(BOOL success, NSError *error))completionBlock {
    NSString *sessionToken = [[ClientSessionManager sharedClient] sessionToken];
    if (!sessionToken.length) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Session Token is not defined"};
        NSError *error = [NSError errorWithDomain:@"Session" code:101 userInfo:userInfo];
        if (completionBlock) {
            completionBlock(FALSE, error);
        }
    }
    else {
        NSDictionary *params = @{ @"sessionToken" : sessionToken };
        [PFCloud callFunctionInBackground:@"becomeSpotHopperUser"
                           withParameters:params block:^(id result, NSError *error) {
                               if (completionBlock) {
                                   if (error) {
                                       completionBlock(FALSE, error);
                                   }
                                   else {
                                       DebugLog(@"result: %@", result);
                                       completionBlock(TRUE, nil);
                                   }
                               }
                           }];
    }
}

- (void)becomeFacebookUserWithCompletionBlock:(void (^)(BOOL success, NSError *error))completionBlock {
    if ([[FBSession activeSession] isOpen]) {
        NSString *accessToken = [[[FBSession activeSession] accessTokenData] accessToken];
        
        [PFCloud callFunctionInBackground:@"becomeFacebookUser"
                           withParameters:@{ @"accessToken" : accessToken }
                                    block: ^(id result, NSError *error) {
                                        if (error) {
                                            DebugLog(@"Error: %@", error.localizedDescription);
                                            completionBlock(FALSE, error);
                                        }
                                        else {
                                            if ([result isKindOfClass:[NSDictionary class]]) {
                                                NSDictionary *dict = (NSDictionary *)result;
                                                NSString *sessionToken = dict[@"sessionToken"];
                                                if (sessionToken.length) {
                                                    [PFUser becomeInBackground:sessionToken block: ^(PFUser *user, NSError *error) {
                                                        DebugLog(@"User is %@", user.objectId);
                                                        completionBlock(TRUE, nil);
                                                    }];
                                                }
                                                else {
                                                    completionBlock(TRUE, nil);
                                                }
                                            }
                                        }
                                    }];
    }
    else {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"Facebook session is not active" };
        NSError *error = [NSError errorWithDomain:@"Facebook" code:101 userInfo:userInfo];
        completionBlock(FALSE, error);
    }
}

- (void)saveUserProfile:(SHUserProfileModel *)userProfile withCompletionBlock:(void (^)(SHUserProfileModel *savedUserProfile, NSError *error))completionBlock {
    if (!userProfile.name.length || !userProfile.imageURL || !userProfile.facebookId) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Incomplete User Profile"};
        NSError *error = [NSError errorWithDomain:@"Model" code:101 userInfo:userInfo];
        if (completionBlock) {
            completionBlock(nil, error);
        }
        return;
    }
    
    NSMutableDictionary *params = @{
                                    @"name" : userProfile.name,
                                    @"imageURL" : userProfile.imageURL.absoluteString,
                                    @"facebookId" : [NSString stringWithFormat:@"%@", userProfile.facebookId],
                                    @"spotHopperUserId" : [NSString stringWithFormat:@"%@", userProfile.spotHopperUserId]}.mutableCopy;
    
//    CLLocation *location = [[SHLocationManager defaultInstance] location];
//    if (location) {
//        params[@"latitude"] = [NSNumber numberWithFloat:location.coordinate.latitude];
//        params[@"longitude"] = [NSNumber numberWithFloat:location.coordinate.longitude];
//    }
    
    DebugLog(@"params: %@", params);
    
    [PFCloud callFunctionInBackground:@"saveUserProfile"
                       withParameters:params
                                block:^(PFObject *userProfileObject, NSError *error) {
                                    if (error) {
                                        DebugLog(@"Error: %@", error.localizedDescription);
                                        if (completionBlock) {
                                            completionBlock(nil, error);
                                        }
                                    }
                                    else {
                                        SHUserProfileModel *savedUserProfile = [self userProfileFromObject:userProfileObject];
                                        DebugLog(@"Saved User Profile");
                                        
                                        if (completionBlock) {
                                            completionBlock(savedUserProfile, nil);
                                        }
                                    }
                                }];
}

- (void)connectParseObjectsWithCompletionBlock:(void (^)(BOOL success, NSError *error))completionBlock {
    // ensure the Installation instance has the User Profile and User
    // ensure the User has the User Profile
    // ensure the User Profile has the User
    
    DebugLog(@"Called by %@", NSStringFromSelector(_cmd));
    
    SHUserProfileModel *userProfile = [[SHAppContext defaultInstance] currentUserProfile];
    
    if (!userProfile) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"User Profile is not defined"};
        NSError *error = [NSError errorWithDomain:@"Parse" code:101 userInfo:userInfo];
        if (completionBlock) {
            completionBlock(FALSE, error);
        }
        return;
    }
    
    PFObject *userProfileObject = [PFObject objectWithClassName:@"UserProfile"];
    userProfileObject.objectId = userProfile.objectId;
    
    [userProfileObject fetchIfNeededInBackgroundWithBlock:^(PFObject *fetchedUserProfile, NSError *error) {
        PFInstallation *installation = [PFInstallation currentInstallation];
        PFUser *user = [PFUser currentUser];
        
        [installation setObject:user forKey:@"user"];
        [installation setObject:fetchedUserProfile forKey:@"userProfile"];
        [user setObject:fetchedUserProfile forKey:@"userProfile"];
        
        [user saveEventually];
        [installation saveEventually];
        
        if (completionBlock) {
            completionBlock(TRUE, nil);
        }
    }];
}

#pragma mark - Facebook
#pragma mark -

- (void)ensureFacebookGrantedPermissions:(NSArray *)permissionsNeeded withCompletionBlock:(void (^)(BOOL success, NSError *error))completionBlock {
    if (!completionBlock) {
        return;
    }
    
    if (![[FBSession activeSession] isOpen]) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"FBSession is not active"};
        NSError *error = [NSError errorWithDomain:@"Facebook" code:400 userInfo:userInfo];
        completionBlock(FALSE, error);
        return;
    }
    
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  NSArray *results = (NSArray *)[result data];
                                  NSDictionary *currentPermissions = results[0];
                                  NSMutableArray *requestPermissions = @[].mutableCopy;
                                  
                                  // Check if all the permissions we need are present in the user's current permissions
                                  // If they are not present add them to the permissions to be requested
                                  for (NSString *permission in permissionsNeeded) {
                                      if (![currentPermissions objectForKey:permission]) {
                                          [requestPermissions addObject:permission];
                                      }
                                  }
                                  
                                  // If we have permissions to request
                                  if ([requestPermissions count] > 0) {
                                      // Ask for the missing permissions
                                      [FBSession.activeSession requestNewPublishPermissions:requestPermissions
                                                                            defaultAudience:FBSessionDefaultAudienceFriends
                                                                          completionHandler:^(FBSession *session, NSError *error) {
                                                                              if (!error) {
                                                                                  // Permission granted, we can request the user information
                                                                                  completionBlock(TRUE, nil);
                                                                              }
                                                                              else {
                                                                                  // An error occurred, handle the error
                                                                                  // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                                                                                  completionBlock(FALSE, error);
                                                                              }
                                                                          }];
                                  }
                                  else {
                                      // Permissions are present, we can request the user information
                                      completionBlock(TRUE, nil);
                                  }
                              }
                              else {
                                  // There was an error requesting the permission information
                                  // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                                  completionBlock(FALSE, error);
                              }
                          }];
}

- (void)fetchFacebookDetailsWithCompletionBlock:(void (^)(BOOL success, NSError *error))completionBlock {
    [self fetchFacebookPublicProfileWithCompletionBlock:^(BOOL publicProfileSuccess, NSError *error) {
        [self fetchFacebookFriendsListWithCompletionBlock:^(BOOL friendsListSuccess, NSError *error) {
            if (completionBlock) {
                completionBlock(publicProfileSuccess && friendsListSuccess, nil);
            }
        }];
    }];
}

- (void)fetchFacebookPublicProfileWithCompletionBlock:(void (^)(BOOL success, NSError *error))completionBlock {
    // fetch public profile details to store on UserModel, Parse and Mixpanel
    
    if ([[FBSession activeSession] isOpen]) {
        NSArray *permissions = [[FBSession activeSession] permissions];
        if ([permissions containsObject:@"public_profile"]) {
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary *result, NSError *error) {
                if (!error) {
                    NSString *name = result[@"name"];
                    NSString *email = result[@"email"];
                    NSString *gender = result[@"gender"];
                    NSString *birthday = result[@"birthday"];
                    
                    UserModel *user = [[ClientSessionManager sharedClient] currentUser];
                    
                    if (name.length && !user.name.length) {
                        user.name = name;
                    }
                    if (email.length && !user.email.length) {
                        user.email = email;
                    }
                    if (gender.length && !user.gender.length) {
                        user.gender = gender;
                    }
                    if (birthday.length) {
                        // birthday = "MM/DD/YYYY";
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"MM/dd/yyyy"];
                        NSDate *date = [formatter dateFromString:birthday];
                        if (date) {
                            user.birthday = date;
                        }
                    }
                    
                    // Note: Settings are not currently supported by the backend
                    
                    [UserModel updateUser:user success:^(UserModel *updatedUser) {
                        DebugLog(@"updatedUser: %@", updatedUser);
                    } failure:^(ErrorModel *errorModel) {
                        DebugLog(@"Error: %@", errorModel);
                    }];
                    
                    PFUser *parseUser = [PFUser currentUser];
                    UserModel *currentUser = [UserModel currentUser];
                    
                    NSString *className = @"FacebookUserProfile";
                    PFQuery *query = [PFQuery queryWithClassName:className];
                    [query whereKey:@"user" equalTo:parseUser];
                    
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            PFObject *facebookUserProfile = objects.firstObject;
                            if (!facebookUserProfile) {
                                facebookUserProfile = [[PFObject alloc] initWithClassName:className];
                                facebookUserProfile[@"user"] = parseUser;
                                facebookUserProfile[@"spotHopperUserId"] = currentUser.ID;
                                
                                PFACL *acl = [PFACL ACL];
                                [acl setWriteAccess:YES forUser:parseUser];
                                [acl setReadAccess:YES forUser:parseUser];
                                [facebookUserProfile setACL:acl];
                            }
                            
                            for (NSString *key in result.allKeys) {
                                if ([@"id" isEqualToString:key]) {
                                    facebookUserProfile[@"facebookId"] = result[key];
                                }
                                else {
                                    facebookUserProfile[key] = result[key];
                                }
                            }
                            
                            [facebookUserProfile saveInBackground];
                        }
                        
                        SHUserProfileModel *userProfile = [[SHUserProfileModel alloc] init];
                        
                        NSString *firstName = result[@"first_name"];
                        NSString *lastName = result[@"last_name"];
                        NSString *name = [NSString stringWithFormat:@"%@ %@", firstName, lastName.length ? [lastName substringToIndex:1]:@""];
                        NSString *imageUrlString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", result[@"id"]];
                        
                        userProfile.name = name;
                        userProfile.imageURL = [NSURL URLWithString:imageUrlString];
                        userProfile.facebookId = [NSNumber numberWithLongLong:[result[@"id"] longLongValue]];
                        
                        [self saveUserProfile:userProfile withCompletionBlock:^(SHUserProfileModel *savedUserProfile, NSError *error) {
                            [[SHAppContext defaultInstance] setCurrentUserProfile:savedUserProfile];
                            
                            if (completionBlock) {
                                completionBlock(TRUE, nil);
                            }
                        }];
                    }];
                }
                else {
                    if (completionBlock) {
                        completionBlock(FALSE, error);
                    }
                }
            }];
            return;
        }
    }

    if (completionBlock) {
        completionBlock(FALSE, nil);
    }
}

- (void)fetchFacebookFriendsListWithCompletionBlock:(void (^)(BOOL success, NSError *error))completionBlock {
    // fetch user friends to store on UserModel, Parse and Mixpanel
    
    if ([[FBSession activeSession] isOpen]) {
        NSArray *permissions = [[FBSession activeSession] permissions];
        
        if ([permissions containsObject:@"user_friends"]) {
            [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary *result, NSError *error) {
                if (!error) {
                    NSMutableArray *facebookIds = @[].mutableCopy;
                    
                    for (NSDictionary *dict in result[@"data"]) {
                        [facebookIds addObject:dict[@"id"]];
                    }
                    
                    PFUser *parseUser = [PFUser currentUser];
                    UserModel *currentUser = [UserModel currentUser];
                    
                    NSString *className = @"FacebookFriends";
                    PFQuery *query = [PFQuery queryWithClassName:className];
                    [query whereKey:@"user" equalTo:parseUser];
                    
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            PFObject *facebookFriends = objects.firstObject;
                            if (!facebookFriends) {
                                facebookFriends = [[PFObject alloc] initWithClassName:className];
                                facebookFriends[@"user"] = parseUser;
                                facebookFriends[@"spotHopperUserId"] = currentUser.ID;
                                PFACL *acl = [PFACL ACL];
                                [acl setWriteAccess:YES forUser:parseUser];
                                [acl setReadAccess:YES forUser:parseUser];
                                [facebookFriends setACL:acl];
                            }
                            
                            facebookFriends[@"friendsCount"] = [NSNumber numberWithLong:facebookIds.count];
                            facebookFriends[@"friends"] = facebookIds;
                            
                            [facebookFriends saveInBackground];
                            
                            [Tracker trackFacebookFriendsList:facebookIds];
                        }
                        if (completionBlock) {
                            completionBlock(TRUE, nil);
                        }
                    }];
                }
                else {
                    if (completionBlock) {
                        completionBlock(FALSE, error);
                    }
                }
            }];
            return;
        }
    }
    
    if (completionBlock) {
        completionBlock(FALSE, nil);
    }
}

#pragma mark - Text Height
#pragma mark -

- (CGFloat)heightForAttributedString:(NSAttributedString *)text maxWidth:(CGFloat)maxWidth {
    if ([text isKindOfClass:[NSString class]] && !text.length) {
        // no text means no height
        return 0;
    }
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize size = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:options context:nil].size;
    
    CGFloat height = ceilf(size.height) + 1; // add 1 point as padding
    
    return height;
}

- (CGFloat)heightForString:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxWidth {
    if (![text isKindOfClass:[NSString class]] || !text.length) {
        // no text means no height
        return 0;
    }
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    CGSize size = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:options attributes:attributes context:nil].size;
    CGFloat height = ceilf(size.height) + 1; // add 1 point as padding
    
    return height;
}

- (CGFloat)widthForAttributedString:(NSAttributedString *)text maxWidth:(CGFloat)maxHeight {
    if ([text isKindOfClass:[NSString class]] && !text.length) {
        // no text means no height
        return 0;
    }
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, maxHeight) options:options context:nil].size;
    
    CGFloat width = ceilf(size.width) + 1; // add 1 point as padding
    
    return width;
}

- (CGFloat)widthForString:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxHeight {
    if (![text isKindOfClass:[NSString class]] || !text.length) {
        // no text means no height
        return 0;
    }
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    CGSize size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, maxHeight) options:options attributes:attributes context:nil].size;
    CGFloat width = ceilf(size.width) + 1; // add 1 point as padding
    
    return width;
}

#pragma mark - Layout Constraints
#pragma mark -

- (NSLayoutConstraint *)getTopConstraint:(UIView *)view {
    return [self getConstraintInView:view forLayoutAttribute:NSLayoutAttributeTop];
}

- (NSLayoutConstraint *)getWidthConstraint:(UIView *)view {
    return [self getConstraintInView:view forLayoutAttribute:NSLayoutAttributeWidth];
}

- (NSLayoutConstraint *)getHeightConstraint:(UIView *)view {
    return [self getConstraintInView:view forLayoutAttribute:NSLayoutAttributeHeight];
}

- (NSLayoutConstraint *)getConstraintInView:(UIView *)view forLayoutAttribute:(NSLayoutAttribute)layoutAttribute {
    NSLayoutConstraint *foundConstraint = nil;
    
    if (layoutAttribute == NSLayoutAttributeTop || layoutAttribute == NSLayoutAttributeBottom ||
        layoutAttribute == NSLayoutAttributeLeading || layoutAttribute == NSLayoutAttributeTrailing) {
        
        for (NSLayoutConstraint *constraint in view.superview.constraints) {
            if (constraint.firstAttribute == layoutAttribute &&
                [view isEqual:constraint.firstItem]) {
                foundConstraint = constraint;
                break;
            }
        }
    }
    else {
        for (NSLayoutConstraint *constraint in view.constraints) {
            if (constraint.firstAttribute == layoutAttribute &&
                constraint.secondAttribute == NSLayoutAttributeNotAnAttribute) {
                foundConstraint = constraint;
                break;
            }
        }
    }
    
    return foundConstraint;
}

#pragma mark - Loading Images
#pragma mark -

- (void)loadImage:(ImageModel *)imageModel intoImageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage {
    [ImageUtil loadImage:imageModel placeholderImage:placeholderImage withThumbImageBlock:^(UIImage *thumbImage) {
        imageView.image = thumbImage;
    } withFullImageBlock:^(UIImage *fullImage) {
        imageView.image = fullImage;
    } withErrorBlock:^(NSError *error) {
        [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)loadImage:(ImageModel *)imageModel intoButton:(UIButton *)button placeholderImage:(UIImage *)placeholderImage {
    button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    button.clipsToBounds = TRUE;
    
    [ImageUtil loadImage:imageModel placeholderImage:placeholderImage withThumbImageBlock:^(UIImage *thumbImage) {
        [button setImage:thumbImage forState:UIControlStateNormal];
    } withFullImageBlock:^(UIImage *fullImage) {
        [button setImage:fullImage forState:UIControlStateNormal];
    } withErrorBlock:^(NSError *error) {
        [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

#pragma mark - Parse Objects
#pragma mark -

- (SHUserProfileModel *)userProfileFromObject:(PFObject *)object {
    SHUserProfileModel *userProfile = [[SHUserProfileModel alloc] init];
    userProfile.objectId = object.objectId;
    userProfile.name = object[@"name"];
    userProfile.imageURL = [NSURL URLWithString:object[@"imageURL"]];
    id facebookId = object[@"facebookId"];
    if ([facebookId isKindOfClass:[NSString class]]) {
        userProfile.facebookId = [NSNumber numberWithLongLong:[facebookId longLongValue]];
    }
    id spotHopperUserId = object[@"spotHopperUserId"];
    if ([spotHopperUserId isKindOfClass:[NSString class]]) {
        userProfile.spotHopperUserId = [NSNumber numberWithLongLong:[spotHopperUserId longLongValue]];
    }
    
    return userProfile;
}

@end
