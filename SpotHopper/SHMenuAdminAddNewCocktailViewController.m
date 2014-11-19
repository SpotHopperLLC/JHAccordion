//
//  SHMenuAdminAddNewCocktailViewControllerViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 11/11/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHMenuAdminAddNewCocktailViewController.h"

#import "SHMenuAdminPickerViewController.h"

#import "DrinkModel.h"
#import "SpotModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubTypeModel.h"
#import "BaseAlcoholModel.h"
#import "ErrorModel.h"

@interface SHMenuAdminAddNewCocktailViewController () <SHMenuAdminPickerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *cocktailNameTextField;

@property (weak, nonatomic) IBOutlet UILabel *baseAlcoholLabel;

@property (weak, nonatomic) IBOutlet UIButton *setBaseAlcoholButton;

@property (weak, nonatomic) SHMenuAdminPickerViewController *baseAlcoholPicker;

@property (strong, nonatomic) NSArray *allBaseAlcohols;

@property (strong, nonatomic) NSArray *baseAlcohols;

@property (strong, nonatomic) BaseAlcoholModel *selectedBaseAlcohol;

@end

@implementation SHMenuAdminAddNewCocktailViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MAAssert(self.scrollView, @"Outlet is required");
}

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
    
    [self.cocktailNameTextField becomeFirstResponder];
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
    if ([sender isEqual:self.setBaseAlcoholButton]) {
        if ([segue.destinationViewController isKindOfClass:[SHMenuAdminPickerViewController class]]) {
            SHMenuAdminPickerViewController *pickerVC = (SHMenuAdminPickerViewController *)segue.destinationViewController;
            pickerVC.delegate = self;
            self.baseAlcoholPicker = pickerVC;
            self.baseAlcohols = @[];
            
            [[BaseAlcoholModel fetchBaseAlcohols] then:^(NSArray *baseAlcohols) {
                self.allBaseAlcohols = baseAlcohols;
                self.baseAlcohols = baseAlcohols.copy;
                [pickerVC reloadData];
            } fail:^(id error) {
                // TODO: handle error
            } always:nil];
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
    if ([self.delegate respondsToSelector:@selector(addNewCocktailViewControllerDidCancel:)]) {
        [self.delegate addNewCocktailViewControllerDidCancel:self];
    }
}

- (IBAction)saveButtonTapped:(id)sender {
    [self saveDrink];
}

- (IBAction)setButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"NewCocktailToPicker" sender:sender];
}

#pragma mark - Private
#pragma mark -

- (void)closePickerView:(SHMenuAdminPickerViewController *)pickerView {
    if ([self.navigationController.topViewController isEqual:pickerView]) {
        [self.navigationController popToViewController:self animated:TRUE];
        
    }
    
    if ([pickerView isEqual:self.baseAlcoholPicker]) {
        self.baseAlcoholPicker = nil;
    }
}

- (void)saveDrink {
    // validation
    if (!self.cocktailNameTextField.text.length) {
        [self showAlert:@"Oops" message:@"Name is required"];
        return;
    }
    else if (!self.selectedBaseAlcohol) {
        [self showAlert:@"Oops" message:@"Base Alcohol is required"];
        return;
    }
    
    DrinkModel *drink = [[DrinkModel alloc] init];
    drink.name = self.cocktailNameTextField.text;
    drink.drinkType = [DrinkTypeModel cocktailDrinkType];
    drink.drinkSubtype = self.drinkSubType;
    drink.baseAlochols = @[self.selectedBaseAlcohol];
    drink.spot = self.spot;
    
    [DrinkModel createDrink:drink success:^(DrinkModel *drinkModel) {
        if ([self.delegate respondsToSelector:@selector(addNewCocktailViewController:didCreateDrink:)]) {
            [self.delegate addNewCocktailViewController:self didCreateDrink:drinkModel];
        }
    } failure:^(ErrorModel *errorModel) {
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

#pragma mark - SHMenuAdminPickerDelegate
#pragma mark -

- (NSString *)titleTextForPickerView:(SHMenuAdminPickerViewController *)pickerView {
    if ([pickerView isEqual:self.baseAlcoholPicker]) {
        return @"Pick a Base Alcohol";
    }
    
    return nil;
}

- (NSString *)placeholderTextForPickerView:(SHMenuAdminPickerViewController *)pickerView {
    if ([pickerView isEqual:self.baseAlcoholPicker]) {
        return @"Search base alcohols...";
    }
    
    return nil;
}

- (NSInteger)numberOfItemsForPickerView:(SHMenuAdminPickerViewController *)pickerView {
    if ([pickerView isEqual:self.baseAlcoholPicker]) {
        return self.baseAlcohols.count;
    }
    
    return 0;
}

- (NSString *)textForPickerView:(SHMenuAdminPickerViewController *)pickerView atIndexPath:(NSIndexPath *)indexPath {
    if ([pickerView isEqual:self.baseAlcoholPicker]) {
        if (indexPath.row < self.baseAlcohols.count) {
            BaseAlcoholModel *baseAlcohol = self.baseAlcohols[indexPath.row];
            return baseAlcohol.name;
        }
    }
    
    return nil;
}

- (void)pickerView:(SHMenuAdminPickerViewController *)pickerView didChangeSearchText:(NSString *)text {
    if ([pickerView isEqual:self.baseAlcoholPicker]) {
        if (text.length) {
            [pickerView startSearching];
            self.baseAlcohols = [self.allBaseAlcohols filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", text]];
            [pickerView stopSearching];
            [pickerView reloadData];
        }
        else {
            self.baseAlcohols = self.allBaseAlcohols.copy;
            [pickerView reloadData];
        }
    }
}

- (void)pickerView:(SHMenuAdminPickerViewController *)pickerView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([pickerView isEqual:self.baseAlcoholPicker]) {
        if (indexPath.row < self.baseAlcohols.count) {
            self.selectedBaseAlcohol = self.baseAlcohols[indexPath.row];
            self.baseAlcoholLabel.text = self.selectedBaseAlcohol.name;
        }
    }
    
    [self closePickerView:pickerView];
}

- (void)pickerViewDidCancel:(SHMenuAdminPickerViewController *)pickerView {
    [self closePickerView:pickerView];
}

#pragma mark - UITextFieldDelegate
#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:TRUE];
    [self saveDrink];
    return TRUE;
}

@end