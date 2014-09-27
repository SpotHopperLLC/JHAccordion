//
//  AccountSettingsViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/31/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kGenders @[ @"Female", @"Male" ]

#import "AccountSettingsViewController.h"

#import "NSDate+Globalize.h"
#import "UIAlertView+Block.h"

#import "ClientSessionManager.h"
#import "UserModel.h"
#import "ErrorModel.h"
#import "Tracker.h"

@interface AccountSettingsViewController ()<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtBirthday;
@property (weak, nonatomic) IBOutlet UITextField *txtSex;

@property (weak, nonatomic) IBOutlet UILabel *lblVersion;

@property (nonatomic, strong) UIDatePicker *pickerBirthday;
@property (nonatomic, strong) UIPickerView *pickerSex;

@property (nonatomic, strong) UserModel *user;

@property (nonatomic, strong) NSDate *selectedBirthday;
@property (nonatomic, strong) NSString *selectedSex;

@end

@implementation AccountSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Sets title
    [self setTitle:@"Account Settings"];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Sets picker for birthday
    _pickerBirthday = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, 320, 216)];
    [_pickerBirthday setBackgroundColor:[UIColor whiteColor]];
    [_pickerBirthday setDatePickerMode:UIDatePickerModeDate];
    
    // Configure picker...
    [_txtBirthday setInputView:_pickerBirthday];
    [_txtBirthday setInputAccessoryView:[self keyboardToolBar:@selector(onClickChooseBirthday:)]];
    
    // Sets picker for sex
    _pickerSex = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 216)];
    [_pickerSex setBackgroundColor:[UIColor whiteColor]];
    [_pickerSex setDataSource:self];
    [_pickerSex setDelegate:self];
    
    // Configure picker...
    [_txtSex setInputView:_pickerSex];
    [_txtSex setInputAccessoryView:[self keyboardToolBar:@selector(onClickChooseSex:)]];
    
    NSString *versionString = [NSString stringWithFormat:@"v%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    _lblVersion.text = versionString;
    
    [self fetchUser];
}

- (NSArray *)viewOptions {
    return @[kDidLoadOptionsBlurredBackground,kDidLoadOptionsDontAdjustForIOS6];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Account Settings";
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _txtName) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == _pickerSex) {
        return kGenders.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == _pickerSex) {
        return [kGenders objectAtIndex:row];
    }
    return nil;
}

#pragma mark - Actions

- (void)onClickBack:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save" message:@"Would you like to save these settings?" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
    
        if (buttonIndex == 1) {
            [self doPut];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }];
    
}

- (void)onClickChooseBirthday:(id)sender {
    _selectedBirthday = [_pickerBirthday date];
    [self.view endEditing:YES];
    
    _txtBirthday.text = [_selectedBirthday stringAsShortDate];
}

- (void)onClickChooseSex:(id)sender {
    _selectedSex = [kGenders objectAtIndex:[_pickerSex selectedRowInComponent:0]];
    [self.view endEditing:YES];
    
    _txtSex.text = _selectedSex;
}

- (IBAction)onClickLogout:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Logout" message:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [[ClientSessionManager sharedClient] logout];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - Private

- (UIToolbar *)keyboardToolBar:(SEL)sel {
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar sizeToFit];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:sel];
    
    NSArray *itemsArray = @[flex, nextButton];
    
    [toolbar setItems:itemsArray];
    
    return toolbar;
}

- (void)updateView {
    // Set stuff
    [_txtName setText:_user.name];
    
    _selectedBirthday = _user.birthday;
    if (_selectedBirthday != nil) [_pickerBirthday setDate:_selectedBirthday];
    [_txtBirthday setText:_selectedBirthday.stringAsShortDate];
    
    _selectedSex = _user.gender;
    [_txtSex setText:_selectedSex];
}

- (void)fetchUser {
    UserModel *user = [ClientSessionManager sharedClient].currentUser;
    if (user != nil) {
        [self showHUD:@"Getting settings"];
        [user getUser:nil success:^(UserModel *userModel, NSHTTPURLResponse *response) {
            [self hideHUD];
            
            _user = userModel;
            [self updateView];
            
        } failure:^(ErrorModel *errorModel) {
            [self hideHUD];
            [self showAlert:@"Oops" message:errorModel.human];
            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    } else {
        [self notLoggedIn];
    }
}

- (void)doPut {
    
    [self.view endEditing:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:_txtName.text forKey:kUserModelParamName];
    if (_selectedBirthday != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        [params setObject:[dateFormatter stringFromDate:_selectedBirthday] forKey:kUserModelParamBirthday];
    }
    if (_selectedSex != nil) {
        [params setObject:_selectedSex forKey:kUserModelParamGender];
    }
    
    UserModel *user = [ClientSessionManager sharedClient].currentUser;
    if (user != nil) {
        [self showHUD:@"Saving"];
        [user putUser:params success:^(UserModel *userModel, NSHTTPURLResponse *response) {
            [self hideHUD];
            
            [[ClientSessionManager sharedClient] setCurrentUser:userModel];
            
            [self showHUDCompleted:@"Saved!" block:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failure:^(ErrorModel *errorModel) {
            [self hideHUD];
            [self showAlert:@"Oops" message:errorModel.human];
            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    } else {
        [self notLoggedIn];
    }
    
}

- (void)notLoggedIn {
    [self showAlert:@"Oops" message:@"You need to be logged in to edit your account" block:^{
        [[ClientSessionManager sharedClient] logout];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
