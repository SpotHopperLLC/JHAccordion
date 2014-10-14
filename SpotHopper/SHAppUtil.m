//
//  SHAppUtil.m
//  SpotHopper
//
//  Created by Brennan Stehling on 9/24/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHAppUtil.h"

#import "SHAppConfiguration.h"
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

@implementation SHAppUtil

+ (instancetype)defaultInstance {
    static SHAppUtil *defaultInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        defaultInstance = [[SHAppUtil alloc] init];
    });
    return defaultInstance;
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
//        [activityItems addObject:[NSURL URLWithString:link]];
//        if (image) {
//            [activityItems addObject:image];
//        }
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
//        [activityItems addObject:[NSURL URLWithString:link]];
//        if (image) {
//            [activityItems addObject:image];
//        }
        NSMutableArray *activities = @[].mutableCopy;
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activities];
        
        [vc presentViewController:activityView animated:YES completion:nil];
    }];
}

#pragma mark - Parse
#pragma mark -

- (void)updateParse {
    if ([UserModel isLoggedIn] && [SHAppConfiguration parseApplicationID].length) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        UserModel *currentUser = [UserModel currentUser];
        [currentInstallation addUniqueObject:[NSString stringWithFormat:@"user-%@", currentUser.ID] forKey:@"channels"];
        [currentInstallation addUniqueObject:currentUser.ID ? currentUser.ID : [NSNull null] forKey:@"spotHopperUserId"];
        [currentInstallation addUniqueObject:currentUser.email.length ? currentUser.email : [NSNull null] forKey:@"email"];
        [currentInstallation saveInBackground];
        
        // Value for currentUser is now always due to [PFUser enableAutomaticUser]
        PFUser *parseUser = [PFUser currentUser];
        [parseUser setObject:currentUser.ID forKey:@"spotHopperUserId"];
        [parseUser setObject:currentUser.email.length ? currentUser.email : [NSNull null] forKey:@"email"];
        [parseUser saveInBackground];
        
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

#pragma mark - Facebook
#pragma mark -

- (void)ensureFacebookGrantedPermissions:(NSArray *)permissionsNeeded withCompletionBlock:(void (^)(BOOL success, NSError *error))completionBlock {
    if (!completionBlock) {
        return;
    }
    
//    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
    
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
    if (!completionBlock) {
        return;
    }
    
    if ([[FBSession activeSession] isOpen]) {
        NSArray *permissions = [[FBSession activeSession] permissions];
        if ([permissions containsObject:@"public_profile"]) {
            // TODO: fetch public profile details to store on UserModel, Parse and Mixpanel
            
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // Success! Include your code to handle the results here
                    NSLog(@"user info: %@", result);
                    
                    if ([result isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dict = (NSDictionary *)result;
                        NSString *name = dict[@"name"];
                        NSString *email = dict[@"email"];
                        NSString *gender = dict[@"gender"];

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

                        // Note: Settings are not currently supported by the backend
                        
                        [UserModel updateUser:user success:^(UserModel *updatedUser) {
                            DebugLog(@"updatedUser: %@", updatedUser);
                        } failure:^(ErrorModel *errorModel) {
                            DebugLog(@"Error: %@", errorModel);
                        }];
                        
                        PFUser *parseUser = [PFUser currentUser];
                        
                        if (parseUser) {
                            NSString *className = @"FacebookUserProfile";
                            PFQuery *query = [PFQuery queryWithClassName:className];
                            [query whereKey:@"user" equalTo:parseUser];
                            
                            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                if (!error) {
                                    PFObject *facebookUserProfile = objects.firstObject;
                                    if (!facebookUserProfile) {
                                        facebookUserProfile = [[PFObject alloc] initWithClassName:className];
                                    }
                                    
                                    for (NSString *key in dict.allKeys) {
                                        facebookUserProfile[key] = dict[key];
                                    }
                                    
                                    PFACL *acl = [PFACL ACL];
                                    [acl setWriteAccess:TRUE forUser:parseUser];
                                    [facebookUserProfile setACL:acl];
                                    
                                    [facebookUserProfile saveInBackground];
                                }
                            }];
                        }
                    }
                    
//                    birthday = "10/22/1975";
//                    email = "offwhite@gmail.com";
//                    "first_name" = Brennan;
//                    gender = male;
//                    id = 10152111225878359;
//                    "last_name" = Stehling;
//                    link = "https://www.facebook.com/app_scoped_user_id/10152111225878359/";
//                    locale = "en_US";
//                    name = "Brennan Stehling";
//                    timezone = "-5";
//                    "updated_time" = "2014-08-29T17:24:00+0000";
//                    verified = 1;
                    
                }
                else {
                    // An error occurred, we need to handle the error
                    // See: https://developers.facebook.com/docs/ios/errors   
                }
            }];
            
        }
        
        if ([permissions containsObject:@"user_friends"]) {
            // TODO: fetch user friends to store on UserModel, Parse and Mixpanel
        }
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

@end
