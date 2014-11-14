//
//  SHMenuAdminLoginViewController.m
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 7/2/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>

#import "SHMenuAdminLoginViewController.h"
#import "SHMenuAdminHomeViewController.h"

#import "UserModel.h"
#import "ErrorModel.h"

#import "SHMenuAdminNetworkManager.h"
#import "ClientSessionManager.h"
#import "Tracker.h"

#define kUserRoleUser @"user"

@interface SHMenuAdminLoginViewController ()

@property (weak, nonatomic) SHMenuAdminNetworkManager *networkManager;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (weak, nonatomic) IBOutlet UIView *textFieldsContainerView;

@end

@implementation SHMenuAdminLoginViewController

#pragma mark - Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
#ifndef NDEBUG
    self.emailTextField.text = @"niko.ivanovic@spothopperapp.com";
    self.passwordTextField.text = @"spothopper071";
#endif
    
    self.navigationController.navigationBarHidden = TRUE;
    // Do any additional setup after loading the view.
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

#pragma mark - User Action
#pragma mark -

- (IBAction)loginTapped:(id)sender {
    [self login];
}

- (IBAction)tapGestureRecognized:(id)sender {
    if (![sender isKindOfClass:[UITextField class]] &&
        ![sender isKindOfClass:[UIButton class]]) {
        [self.view endEditing:TRUE];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self login];
    return YES;
}

#pragma mark - Private - User Login
#pragma mark -

- (void)login {
    NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = self.passwordTextField.text;
    
    if (email.length == 0) {
        [self showAlert:@"Oops" message:@"Email is required"];
        return;
    }
    if (password.length == 0) {
       [self showAlert:@"Oops" message:@"Password is required"];
        return;
    }
    
    [self showHUD:@"Logging in"];
    [[SHMenuAdminNetworkManager sharedInstance] loginUser:email password:password success:^(UserModel *user) {
        [self hideHUD];
        [[ClientSessionManager sharedClient] setHasSeenLaunch:TRUE];
        [self.presentingViewController dismissViewControllerAnimated:TRUE completion:^{
            MAAssert(self.delegate, @"Delegate is required");
            if ([self.delegate respondsToSelector:@selector(loginDidFinish:)]) {
                [self.delegate loginDidFinish:self];
            }
        }];
    } failure:^(ErrorModel *error) {
        CLS_LOG(@"login issue: %@", error.humanValidations);
        [self hideHUD];
        [self showAlert:@"Oops" message:error.humanValidations];
    }];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification*)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat height = CGRectGetHeight(keyboardFrame);
    
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, height, 0);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
    });
}

- (void)keyboardWillHide:(NSNotification*)notification {
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)clearTextFields {
    self.passwordTextField.text = nil;
    self.emailTextField.text = nil;
}

- (NSArray *)textfieldToHideKeyboard {
    return @[self.emailTextField, self.passwordTextField];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    
    BOOL hide = NO;
    for (UITextField *textfield in [self textfieldToHideKeyboard]) {
        if ([textfield isFirstResponder] && [touch view] != textfield) {
            hide  = YES;
        }
    }
    
    if (hide == YES) {
        [self.view endEditing:YES];
    }
    [super touchesBegan:touches withEvent:event];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
