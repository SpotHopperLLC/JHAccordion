//
//  SHMenuAdminLoginViewController.m
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 7/2/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import "SHMenuAdminLoginViewController.h"

#import <Crashlytics/Crashlytics.h>
#import <MessageUI/MessageUI.h>
#import <BlocksKit/MFMailComposeViewController+BlocksKit.h>
#import <BlocksKit/MFMessageComposeViewController+BlocksKit.h>

#import "SHMenuAdminHomeViewController.h"

#import "UserModel.h"
#import "ErrorModel.h"

#import "SHMenuAdminNetworkManager.h"
#import "ClientSessionManager.h"
#import "Tracker.h"

#define kUserRoleUser @"user"

@interface SHMenuAdminLoginViewController () <UITextFieldDelegate>

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
//    self.emailTextField.text = @"Aleksandarivanovic@yahoo.com";
//    self.passwordTextField.text = @"password";
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

- (IBAction)emailSupportButtonTapped:(id)sender {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    if (![MFMailComposeViewController canSendMail]) {
        [self showAlert:@"Oops" message:@"Your device has not been set up for mail. Please configure your mail account and try again."];
        return;
    }
    
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    [vc setSubject:@"SpotHopper Admin Support"];
    [vc setToRecipients:@[@"support@spothopperapp.com"]];
    [vc bk_setCompletionBlock:^(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *error) {
        [controller.presentingViewController dismissViewControllerAnimated:TRUE completion:^{
            DebugLog(@"Done");
        }];
    }];
    
    [self presentViewController:vc animated:TRUE completion:^{
        DebugLog(@"Done");
    }];
}

- (IBAction)forgotPasswordButtonTapped:(id)sender {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    if (!self.emailTextField.text.length) {
        [self showAlert:@"Oops" message:@"Please enter your email in the text field."];
        return;
    }
    
    [[ClientSessionManager sharedClient] forgotPasswordWithEmail:self.emailTextField.text withCompletionBlock:^(NSError *error) {
        if (error) {
            DebugLog(@"Error: %@", error);
            [self showAlert:@"Oops" message:@"Sorry, an error occurred while processing this request. Please try again."];
        }
        else {
            [self showAlert:@"Check your Email" message:@"An email has been sent which will allow you to reset your password. If you have any trouble please email support."];
        }
    }];
}

- (IBAction)tapGestureRecognized:(id)sender {
    if (![sender isKindOfClass:[UITextField class]] &&
        ![sender isKindOfClass:[UIButton class]]) {
        [self.view endEditing:TRUE];
    }
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
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, height, 0);
    self.scrollView.contentInset = insets;
    self.scrollView.scrollIndicatorInsets = insets;

    // move the content up enough so it is all visible
    CGFloat availableHeight = CGRectGetHeight(self.view.frame) - height;
    if (self.scrollView.contentSize.height > availableHeight) {
        CGFloat offset = self.scrollView.contentSize.height  - availableHeight;
        self.scrollView.contentOffset = CGPointMake(0.0, offset);
    }
}

- (void)keyboardWillHide:(NSNotification*)notification {
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.scrollView.contentInset = insets;
    self.scrollView.scrollIndicatorInsets = insets;
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

#pragma mark - UITextFieldDelegate
#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.emailTextField]) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.passwordTextField]) {
        [self.view endEditing:TRUE];
        [self login];
    }
    return YES;
}

@end
