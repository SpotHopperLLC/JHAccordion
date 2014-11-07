//
//  SHMenuAdminAddNewBeerViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 11/7/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHMenuAdminAddNewBeerViewController.h"

@interface SHMenuAdminAddNewBeerViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *beerNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *breweryTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *stylePickerView;

@end

@implementation SHMenuAdminAddNewBeerViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    DebugLog(@"%@", NSStringFromSelector(_cmd));
}

- (NSArray *)viewOptions {
    return @[kDidLoadOptionsNoBackground];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Keyboard Support
#pragma mark -

//- (BOOL)keyboardWillShowWithHeight:(CGFloat)height duration:(CGFloat)duration animationOptions:(UIViewAnimationOptions)animationOptions {
//    return [super keyboardWillShowWithHeight:height duration:duration animationOptions:animationOptions];
//}
//
//- (BOOL)keyboardWillHideWithHeight:(CGFloat)height duration:(CGFloat)duration animationOptions:(UIViewAnimationOptions)animationOptions {
//    return [super keyboardWillHideWithHeight:height duration:duration animationOptions:animationOptions];
//}

- (UIScrollView *)mainScrollView {
    return self.scrollView;
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)cancelButtonTapped:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:TRUE completion:^{
        DebugLog(@"Done");
    }];
}

- (IBAction)saveButtonTapped:(id)sender {
    // TODO: save the drink after validation
    
    [self.presentingViewController dismissViewControllerAnimated:TRUE completion:^{
        DebugLog(@"Done");
    }];
}

#pragma mark - UIPickerViewDelegate
#pragma mark -

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
//    UILabel *label = nil;
//    if ([view isKindOfClass:[UILabel class]]) {
//        label = (UILabel *)view;
//    }
//    else {
//        label = [[UILabel alloc] init];
//    }
//    
//    label.text = [NSString stringWithFormat:@"Item %lu", (unsigned long)row];
//    
//    return label;
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    DebugLog(@"Row: %li", (unsigned long)(row + 1));
}

#pragma mark - UIPickerViewDataSource
#pragma mark -

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 10;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"Item %lu", (unsigned long)(row + 1)];
}

@end
