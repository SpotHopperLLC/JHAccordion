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

@property (weak, nonatomic) IBOutlet UITextField *txtfldEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtfldPassword;
@property (weak, nonatomic) IBOutlet UIView *container;

@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (nonatomic, assign) BOOL keyboardUp;

@end

@implementation SHMenuAdminLoginViewController

#pragma mark - Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _keyboardUp = NO;
    
    self.navigationController.navigationBarHidden = true;
    self.container.backgroundColor = [UIColor clearColor];
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
    
    if ([self.delegate respondsToSelector:@selector(loginDidFinish:)]) {
        [self.delegate loginDidFinish:self];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - User Action
#pragma mark -

- (IBAction)loginTapped:(id)sender {
    [self login];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self login];
    return YES;
}

#pragma mark - Private - User Login
#pragma mark -

- (void)login {
    NSString *email = [self.txtfldEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = self.txtfldPassword.text;
    
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
        
        if ([user.role isEqualToString:kUserRoleUser]) {
            //show error message not validated
            [self showAlert:@"Oops" message:@"You must be a bar owner or administrator to login"];
            
            //log user out
            [[ClientSessionManager sharedClient] logout];
            [self clearTextFields];
            
            return;
        }
        
        [self hideHUD];
        [[ClientSessionManager sharedClient]setHasSeenLaunch:true];
        [self dismissViewControllerAnimated:true completion:nil];
        
    } failure:^(ErrorModel *error) {
        
        CLS_LOG(@"login issue: %@", error.humanValidations);
        [self hideHUD];
        [self showAlert:@"Oops" message:error.humanValidations];
        
    }];
    
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification*)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES keyboardFrame:keyboardFrame];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO keyboardFrame:keyboardFrame];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES keyboardFrame:keyboardFrame];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO keyboardFrame:keyboardFrame];
    }
}

- (float)offsetForKeyboard {
    return 210.0f;
}

- (void)setViewMovedUp:(BOOL)movedUp keyboardFrame:(CGRect)keyboardFrame {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.container.frame;
    if (_keyboardUp == NO)
    {
        _keyboardUp = YES;
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= [self offsetForKeyboard];
        rect.size.height += [self offsetForKeyboard];
        
        [self.logo setAlpha:0.0f];
    }
    else
    {
        _keyboardUp = NO;
        // revert back to the normal state.
        rect.origin.y += [self offsetForKeyboard];
        rect.size.height -= [self offsetForKeyboard];
        
        [self.logo setAlpha:1.0f];
    }
    self.container.frame = rect;
    
    [UIView commitAnimations];
}

- (void)clearTextFields {
    self.txtfldPassword.text = @"";
    self.txtfldEmail.text = @"";
}

- (NSArray *)textfieldToHideKeyboard {
    return @[self.txtfldEmail, self.txtfldPassword];
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
