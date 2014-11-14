//
//  SHMenuAdminNoAdminViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 11/14/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHMenuAdminNoAdminViewController.h"

#import <MessageUI/MessageUI.h>
#import <BlocksKit/MFMailComposeViewController+BlocksKit.h>
#import <BlocksKit/MFMessageComposeViewController+BlocksKit.h>

#import "ClientSessionManager.h"
#import "UserModel.h"

#pragma mark - Class Extension
#pragma mark -

@interface SHMenuAdminNoAdminViewController ()

@end

@implementation SHMenuAdminNoAdminViewController

#pragma mark - User Actions
#pragma mark -

- (IBAction)emailButtonTapped:(id)sender {
    if (![MFMailComposeViewController canSendMail]) {
        [self showAlert:@"Oops" message:@"Your device has not been set up for mail. Please configure your mail account and try again."];
        return;
    }
    
    UserModel *user = [UserModel currentUser];
    
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    [vc setSubject:@"SpotHopper Admin Setup"];
    [vc setToRecipients:@[@"support@spothopperapp.com"]];
    [vc setMessageBody:[NSString stringWithFormat:@"My email for my SpotHopper account is %@ and I would like help with setting up my account. My phone number is below.\n\nPlease enter your phone number.", user.email] isHTML:NO];
    [vc bk_setCompletionBlock:^(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *error) {
        [controller.presentingViewController dismissViewControllerAnimated:TRUE completion:^{
            DebugLog(@"Done");
        }];
    }];
    
    [self presentViewController:vc animated:TRUE completion:^{
        DebugLog(@"Done");
    }];
}

- (IBAction)dismissButton:(id)sender {
    [[ClientSessionManager sharedClient] logout];
    [self.presentingViewController dismissViewControllerAnimated:TRUE completion:^{
        DebugLog(@"Done");
    }];
}

@end
