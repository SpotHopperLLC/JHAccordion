//
//  LaunchViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/30/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "LaunchViewController.h"

#import "AppDelegate.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"
#import "UserModel.h"

@interface LaunchViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;
@property (weak, nonatomic) IBOutlet UIView *viewOptions;

@property (weak, nonatomic) IBOutlet UIView *viewFacebook;
@property (weak, nonatomic) IBOutlet UIView *viewTwitter;
@property (weak, nonatomic) IBOutlet UIView *viewLogin;
@property (weak, nonatomic) IBOutlet UIView *viewCreate;
@property (weak, nonatomic) IBOutlet UIButton *btnSkip;

@property (weak, nonatomic) IBOutlet UIView *viewFormLogin;
@property (weak, nonatomic) IBOutlet UITextField *txtLoginEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtLoginPassword;
@property (weak, nonatomic) IBOutlet UIImageView *imgLoginArrow;

@property (weak, nonatomic) IBOutlet UIView *viewFormCreate;
@property (weak, nonatomic) IBOutlet UITextField *txtCreateEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtCreatePassword;
@property (weak, nonatomic) IBOutlet UITextField *txtCreatePasswordConfirm;
@property (weak, nonatomic) IBOutlet UIImageView *imgCreateArrow;

@property (nonatomic, assign) BOOL keyboardUp;

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
    [super viewDidLoad:@[kDidLoadOptionsDontAdjustForIOS6]];

    // Logs current user out
    [[ClientSessionManager sharedClient] logout];
    
    // Initialize properties - login
    _keyboardUp = NO;
    _isShowingLogin = NO;
    _viewLoginInitialFrame = _viewLogin.frame;
    
    CGRect frameLoginForm = _viewFormLogin.frame;
    frameLoginForm.origin.y = -frameLoginForm.size.height;
    [_viewFormLogin setFrame:frameLoginForm];
    
    // Initialize properties - sign up
    _isShowingCreate = NO;
    _viewCreateInitialFrame = _viewCreate.frame;
    
    CGRect frameCreateForm = _viewFormCreate.frame;
    frameCreateForm.origin.y = -frameCreateForm.size.height;
    [_viewFormCreate setFrame:frameCreateForm];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Sets in settings that user has seen launch
    [[ClientSessionManager sharedClient] setHasSeenLaunch:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (NSArray *)textfieldToHideKeyboard {
    return @[_txtLoginEmail, _txtLoginPassword, _txtCreateEmail, _txtCreatePassword, _txtCreatePasswordConfirm];
}

- (float)offsetForKeyboard {
    return 210.0f;
}

-(void)setViewMovedUp:(BOOL)movedUp keyboardFrame:(CGRect)keyboardFrame
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = _viewOptions.frame;
    if (_keyboardUp == NO)
    {
        _keyboardUp = YES;
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= [self offsetForKeyboard];
        rect.size.height += [self offsetForKeyboard];
        
        [_imgLogo setAlpha:0.0f];
    }
    else
    {
        _keyboardUp = NO;
        // revert back to the normal state.
        rect.origin.y += [self offsetForKeyboard];
        rect.size.height -= [self offsetForKeyboard];
        
        [_imgLogo setAlpha:1.0f];
    }
    _viewOptions.frame = rect;
    
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onClickSkip:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClickFacebook:(id)sender {
    [self doFacebook];
}

- (IBAction)onClickTwitter:(id)sender {
    [self doTwitter];
}

- (IBAction)onClickLogin:(id)sender {
    [self.view endEditing:YES];
    [self showLogin:!_isShowingLogin];
}

- (IBAction)onClickCreate:(id)sender {
    [self.view endEditing:YES];
    [self showCreate:!_isShowingCreate];
}

- (IBAction)onClickDoLogin:(id)sender {
    [self doLoginSpotHopper];
}
- (IBAction)onClickDoCreate:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private - Connect

- (void)doFacebook {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    [self showHUD:@"Connecting Facebook"];
    [appDelegate facebookAuth:YES success:^(FBSession *session) {
        [self hideHUD];
        [self doLoginFacebook];
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

#pragma mark - Private - API

- (void)doLoginFacebook {
    if ([[FBSession activeSession] isOpen] == YES) {
        
        NSDictionary *params = @{
                                 kUserModelParamFacebookAccessToken: [[[FBSession activeSession] accessTokenData] accessToken]
                                 };
        [self doLoginOperation:params];
    } else {
        [self showAlert:@"Oops" message:@"Error while logging in with Facebook"];
    }
}

- (void)doLoginSpotHopper {
    NSString *email = _txtLoginEmail.text;
    NSString *password = _txtLoginPassword.text;
    
    if (email.length == 0) {
        [self showAlert:@"Oops" message:@"Email is required"];
        return;
    }
    if (password.length == 0) {
        [self showAlert:@"Oops" message:@"Password is required"];
        return;
    }
    
    NSDictionary *params = @{
                             kUserModelParamEmail : email,
                             kUserModelParamPassword : password
                             };
    
    [self doLoginOperation:params];
}

- (void)doLoginOperation:(NSDictionary*)params {
    
    [self showHUD:@"Logging in"];
    [UserModel loginUser:params success:^(UserModel *userModel, NSHTTPURLResponse *response) {
        [self hideHUD];
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Oops" message:@"Error while trying to login"];
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
            [_btnSkip setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [_viewFacebook setHidden:YES];
            [_viewTwitter setHidden:YES];
            [_viewCreate setHidden:YES];
            [_btnSkip setHidden:YES];
            
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
        [_btnSkip setHidden:NO];
        
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
                    [_btnSkip setAlpha:1.0f];
                } completion:^(BOOL finished) {
                    
                }];
                
            }];
            
        }];
        
    }
    
}

- (void)showCreate:(BOOL)show {
    
    if (show == YES) {
        _isShowingCreate = YES;
        
        [UIView animateWithDuration:0.35f animations:^{
            [_viewFacebook setAlpha:0.0f];
            [_viewTwitter setAlpha:0.0f];
            [_viewLogin setAlpha:0.0f];
            [_btnSkip setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [_viewFacebook setHidden:YES];
            [_viewTwitter setHidden:YES];
            [_viewLogin setHidden:YES];
            [_btnSkip setHidden:YES];
            
            // Create button
            CGRect createFrame = _viewCreate.frame;
            createFrame.origin.y = 0;
            
            [UIView animateWithDuration:0.35 animations:^{
                [_viewCreate setFrame:createFrame];
            } completion:^(BOOL finished) {
                
                // Create frame
                CGRect frameCreateForm = _viewFormCreate.frame;
                frameCreateForm.origin.y = 0;
                
                [UIView animateWithDuration:0.35 animations:^{
                    [_viewFormCreate setFrame:frameCreateForm];
                    _imgCreateArrow.transform = CGAffineTransformMakeRotation(M_PI_2);
                } completion:^(BOOL finished) {
                    
                }];
                
            }];
        }];
        
    } else {
        _isShowingCreate = NO;
        
        [_viewFacebook setHidden:NO];
        [_viewTwitter setHidden:NO];
        [_viewLogin setHidden:NO];
        [_btnSkip setHidden:NO];
        
        // Create frame
        CGRect frameCreateForm = _viewFormCreate.frame;
        frameCreateForm.origin.y = -frameCreateForm.size.height;
        
        [UIView animateWithDuration:0.35f animations:^{
            [_viewFormCreate setFrame:frameCreateForm];
            _imgCreateArrow.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.35f animations:^{
                [_viewCreate setFrame:_viewCreateInitialFrame];
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.35f animations:^{
                    [_viewFacebook setAlpha:1.0f];
                    [_viewTwitter setAlpha:1.0f];
                    [_viewLogin setAlpha:1.0f];
                    [_btnSkip setAlpha:1.0f];
                } completion:^(BOOL finished) {
                    
                }];
                
            }];
            
        }];
        
    }
    
}

@end
