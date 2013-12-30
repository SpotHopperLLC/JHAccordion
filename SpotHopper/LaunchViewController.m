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

@property (weak, nonatomic) IBOutlet UIView *viewFacebook;
@property (weak, nonatomic) IBOutlet UIView *viewTwitter;
@property (weak, nonatomic) IBOutlet UIView *viewLogin;
@property (weak, nonatomic) IBOutlet UIView *viewCreate;

@property (weak, nonatomic) IBOutlet UIView *viewFormLogin;
@property (weak, nonatomic) IBOutlet UITextField *txtLoginEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtLoginPassword;
@property (weak, nonatomic) IBOutlet UIImageView *imgLoginArrow;

// Login
@property (nonatomic, assign) BOOL isShowingLogin;
@property (nonatomic, assign) CGRect viewLoginInitialFrame;

// Sign up
@property (nonatomic, assign) BOOL isShowingCreate;
@property (nonatomic, assign) CGRect viewCreateInitialFrame;

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

    // Initialize properties - login
    _isShowingLogin = NO;
    _viewLoginInitialFrame = _viewLogin.frame;
    
    CGRect frameLoginForm = _viewFormLogin.frame;
    frameLoginForm.origin.y = -frameLoginForm.size.height;
    [_viewFormLogin setFrame:frameLoginForm];
    
    // Initialize properties - sign up
    _isShowingCreate = NO;
    _viewCreateInitialFrame = _viewCreate.frame;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (NSArray *)textfieldToHideKeyboard {
    return @[_txtLoginEmail, _txtLoginPassword];
}

- (float)offsetForKeyboard {
    return 210.0f;
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
    [self showLogin:!_isShowingLogin];
}

- (IBAction)onClickCreate:(id)sender {
    
}

#pragma mark - Private - Connect

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

#pragma mark - Private - Animations

- (void)showLogin:(BOOL)show {
    
    if (show == YES) {
        _isShowingLogin = YES;
        
        [UIView animateWithDuration:0.35f animations:^{
            [_viewFacebook setAlpha:0.0f];
            [_viewTwitter setAlpha:0.0f];
            [_viewCreate setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [_viewFacebook setHidden:YES];
            [_viewTwitter setHidden:YES];
            [_viewCreate setHidden:YES];
            
            // Login button
            CGRect loginFrame = _viewLogin.frame;
            loginFrame.origin.y = 0;
            
            [UIView animateWithDuration:0.35 animations:^{
                [_viewLogin setFrame:loginFrame];
            } completion:^(BOOL finished) {
                
                // Login frame
                CGRect frameLoginForm = _viewFormLogin.frame;
                frameLoginForm.origin.y = 0;
                
                [UIView animateWithDuration:0.35 animations:^{
                    [_viewFormLogin setFrame:frameLoginForm];
                    _imgLoginArrow.transform = CGAffineTransformMakeRotation(M_PI_2);
                } completion:^(BOOL finished) {
                    
                }];
                
            }];
        }];
        
    } else {
        _isShowingLogin = NO;
        
        [_viewFacebook setHidden:NO];
        [_viewTwitter setHidden:NO];
        [_viewCreate setHidden:NO];
        
        // Login frame
        CGRect frameLoginForm = _viewFormLogin.frame;
        frameLoginForm.origin.y = -frameLoginForm.size.height;
        
        [UIView animateWithDuration:0.35f animations:^{
            [_viewFormLogin setFrame:frameLoginForm];
            _imgLoginArrow.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {
           
            [UIView animateWithDuration:0.35f animations:^{
                [_viewLogin setFrame:_viewLoginInitialFrame];
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.35f animations:^{
                    [_viewFacebook setAlpha:1.0f];
                    [_viewTwitter setAlpha:1.0f];
                    [_viewCreate setAlpha:1.0f];
                } completion:^(BOOL finished) {
                    
                }];
                
            }];
            
        }];
        
    }
    
}

- (IBAction)txtLoginPassword:(id)sender {
}
@end
