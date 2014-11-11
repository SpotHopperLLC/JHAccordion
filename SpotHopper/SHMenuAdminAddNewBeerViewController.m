//
//  SHMenuAdminAddNewBeerViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 11/7/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHMenuAdminAddNewBeerViewController.h"

#import "SHMenuAdminPickerViewController.h"

#import "DrinkModel.h"
#import "SpotModel.h"
#import "DrinkTypeModel.h"
#import "ErrorModel.h"

@interface SHMenuAdminAddNewBeerViewController () <SHMenuAdminPickerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *beerNameTextField;

@property (weak, nonatomic) IBOutlet UILabel *breweryLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleLabel;

@property (weak, nonatomic) IBOutlet UIButton *setBreweryButton;
@property (weak, nonatomic) IBOutlet UIButton *setStyleButton;

@property (strong, nonatomic) SpotModel *selectedBrewery;
@property (strong, nonatomic) NSString *selectedBeerStyle;

@end

@implementation SHMenuAdminAddNewBeerViewController

#pragma mark - View Lifecycle
#pragma mark -

- (NSArray *)viewOptions {
    return @[kDidLoadOptionsNoBackground];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.beerNameTextField becomeFirstResponder];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isEqual:self.setBreweryButton]) {
        if ([segue.destinationViewController isKindOfClass:[SHMenuAdminPickerViewController class]]) {
            SHMenuAdminPickerViewController *pickerVC = (SHMenuAdminPickerViewController *)segue.destinationViewController;
            [pickerVC prepareForBreweries];
            pickerVC.delegate = self;
        }
    }
    else if ([sender isEqual:self.setStyleButton]) {
        if ([segue.destinationViewController isKindOfClass:[SHMenuAdminPickerViewController class]]) {
            SHMenuAdminPickerViewController *pickerVC = (SHMenuAdminPickerViewController *)segue.destinationViewController;
            [pickerVC prepareForBeerStyles];
            pickerVC.delegate = self;
        }
    }
}

#pragma mark - Base Overrides
#pragma mark -

- (UIScrollView *)mainScrollView {
    return self.scrollView;
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)cancelButtonTapped:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:TRUE completion:^{
    }];
}

- (IBAction)saveButtonTapped:(id)sender {
    // validation
    if (!self.beerNameTextField.text.length) {
        [self showAlert:@"Oops" message:@"Name is required"];
        return;
    }
    else if (!self.selectedBrewery.name.length) {
        [self showAlert:@"Oops" message:@"Brewery is required"];
        return;
    }
    else if (!self.selectedBeerStyle.length) {
        [self showAlert:@"Oops" message:@"Style is required"];
        return;
    }
    
    DrinkModel *drink = [[DrinkModel alloc] init];
    drink.name = self.beerNameTextField.text;
    drink.style = self.selectedBeerStyle;
    drink.drinkType = [DrinkTypeModel beerDrinkType];
    drink.spot = self.selectedBrewery;
    
    [DrinkModel createDrink:drink success:^(DrinkModel *drinkModel) {
        if ([self.delegate respondsToSelector:@selector(addNewBeerViewController:didCreateDrink:)]) {
            [self.delegate addNewBeerViewController:self didCreateDrink:drinkModel];
        }
    } failure:^(ErrorModel *errorModel) {
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

- (IBAction)setBreweryButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"NewBeerToPicker" sender:sender];
}

- (IBAction)setStyleButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"NewBeerToPicker" sender:sender];
}

#pragma mark - SHMenuAdminPickerDelegate
#pragma mark -

- (void)pickerView:(SHMenuAdminPickerViewController *)pickerView didSelectItem:(id)item {
    if ([item isKindOfClass:[SpotModel class]]) {
        SpotModel *spot = (SpotModel *)item;
        self.selectedBrewery = spot;
        self.breweryLabel.text = spot.name;
    }
    else if ([item isKindOfClass:[NSString class]]) {
        NSString *style = (NSString *)item;
        self.selectedBeerStyle = style;
        self.styleLabel.text = style;
    }
    
    if ([self.navigationController.topViewController isEqual:pickerView]) {
        [self.navigationController popToViewController:self animated:TRUE];
    }
}

@end
