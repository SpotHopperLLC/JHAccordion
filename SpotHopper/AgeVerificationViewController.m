//
//  AgeVerificationViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 4/1/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "AgeVerificationViewController.h"

#import "UIViewController+Navigator.h"
#import "NSDate+Util.h"

@interface AgeVerificationViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *ageVerificationDatePicker;

@property (strong, nonatomic) NSDate *maximumDateOfBirth;

@end

@implementation AgeVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDate *manyYearsAgo = [[NSDate date] addMonths:12*120*-1];
    NSDate *yearsAgo = [[NSDate date] addYears:-21];
    
    NSCAssert(_ageVerificationDatePicker, @"Outlet is required");
    _ageVerificationDatePicker.maximumDate = [NSDate date];
    _ageVerificationDatePicker.minimumDate = manyYearsAgo;
    _ageVerificationDatePicker.date = [yearsAgo addDays:1];
    
    self.maximumDateOfBirth = yearsAgo;
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Age Verification";
}

- (IBAction)onEnterAgeVerification:(UIButton *)button {
    // verify the age is over 21 to procede or alert the user they cannot continue
    
    if ([_maximumDateOfBirth compare:_ageVerificationDatePicker.date] == NSOrderedDescending) {
        // go immediately to the launch screen after age verification
        UIViewController *presentingVC = self.presentingViewController;
        [self dismissViewControllerAnimated:NO completion:^{
            [presentingVC goToLaunch:NO];
        }];
    }
    else {
        [self showAlert:@"Age Verification" message:@"You must be 21 or older to use this application."];
    }
}

@end
