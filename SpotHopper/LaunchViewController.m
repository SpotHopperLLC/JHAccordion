//
//  LaunchViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/30/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "LaunchViewController.h"

#import "AppDelegate.h"

@interface LaunchViewController ()

@end

@implementation LaunchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onClickFacebook:(id)sender {
    [self doFacebook];
}

- (IBAction)onClickTwitter:(id)sender {
    [self doTwitter];
}

- (IBAction)onClickLogin:(id)sender {
    
}

- (IBAction)onClickCreate:(id)sender {
    
}

#pragma mark - Private

- (void)doFacebook {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    [self showHUD:@"Connecting Facebook"];
    [appDelegate facebookAuth:YES success:^(FBSession *session) {
        [self hideHUD];
        NSLog(@"We got Facebook!!");
    } failure:^(FBSessionState state, NSError *error) {
        [self hideHUD];
        [self showAlert:@"Oops" message:@"Looks like there was an error logging in with Facebook"];
    }];
}

- (void)doTwitter {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    [appDelegate twitterChooseAccount:self.view success:^(ACAccount *account) {
        
        [self showHUD:@"Connecting Twitter"];
        [appDelegate twitterAuth:account success:^(NSString *oAuthToken, NSString *oAuthTokenSecret, NSString *userID, NSString *screenName) {
            [self hideHUD];
            NSLog(@"We got Twitter!! - %@, %@, %@", screenName, oAuthToken, oAuthTokenSecret);
        } failure:^(NSError *error) {
            [self hideHUD];
            [self showAlert:@"Oops" message:@"Looks like there was an error logging in with Twitter"];
        }];

        
    } cancel:^{
        
    } noAccounts:^{
        [self showAlert:@"No Accounts Found" message:@"No Twitter accounts were found logged in to this device..\n\nPlease connect Twitter account in the Settings app if you would like to use Twitter in SpotHopper"];
    } permissionDenied:^{
        [self showAlert:@"Permission Denied" message:@"SpotHopper does not have permission to use Twitter.\n\nPlease adjust the permissions in the Settings app if you would like to use Twitter in SpotHopper"];
    }];
    }

@end
