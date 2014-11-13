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

@property (strong, nonatomic) NSArray *breweries;
@property (strong, nonatomic) NSArray *allBeerStyles;
@property (strong, nonatomic) NSArray *beerStyles;

@property (weak, nonatomic) SHMenuAdminPickerViewController *breweryPicker;
@property (weak, nonatomic) SHMenuAdminPickerViewController *stylePicker;

@end

@implementation SHMenuAdminAddNewBeerViewController

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
            pickerVC.delegate = self;
            self.breweryPicker = pickerVC;
            self.breweries = @[];
            [pickerVC reloadData];
        }
    }
    else if ([sender isEqual:self.setStyleButton]) {
        if ([segue.destinationViewController isKindOfClass:[SHMenuAdminPickerViewController class]]) {
            SHMenuAdminPickerViewController *pickerVC = (SHMenuAdminPickerViewController *)segue.destinationViewController;
            pickerVC.delegate = self;
            self.stylePicker = pickerVC;
            
            self.beerStyles = @[];
            
            [[DrinkModel fetchBeerStyles] then:^(NSArray *styles) {
                self.allBeerStyles = styles;
                self.beerStyles = styles.copy;
                [pickerVC reloadData];
            } fail:^(id error) {
            } always:nil];
        }
    }
}

#pragma mark - Base Overrides
#pragma mark -

- (UIScrollView *)mainScrollView {
    return self.scrollView;
}

#pragma mark - Private
#pragma mark -

- (void)closePickerView:(SHMenuAdminPickerViewController *)pickerView {
    if ([self.navigationController.topViewController isEqual:pickerView]) {
        [self.navigationController popToViewController:self animated:TRUE];
        
    }
    
    // clear property references immediately
    if ([self.breweryPicker isEqual:pickerView]) {
        self.breweryPicker = nil;
    }
    else if ([self.stylePicker isEqual:pickerView]) {
        self.stylePicker = nil;
    }
}

- (void)saveDrink {
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
    drink.drinkType = [DrinkTypeModel beerDrinkType];
    drink.style = self.selectedBeerStyle;
    drink.spot = self.selectedBrewery;
    
    [DrinkModel createDrink:drink success:^(DrinkModel *drinkModel) {
        if ([self.delegate respondsToSelector:@selector(addNewBeerViewController:didCreateDrink:)]) {
            [self.delegate addNewBeerViewController:self didCreateDrink:drinkModel];
        }
    } failure:^(ErrorModel *errorModel) {
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)cancelButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(addNewBeerViewControllerDidCancel:)]) {
        [self.delegate addNewBeerViewControllerDidCancel:self];
    }
}

- (IBAction)saveButtonTapped:(id)sender {
    [self saveDrink];
}

- (IBAction)setButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"NewBeerToPicker" sender:sender];
}

#pragma mark - SHMenuAdminPickerDelegate
#pragma mark -

- (NSString *)titleTextForPickerView:(SHMenuAdminPickerViewController *)pickerView {
    if ([self.breweryPicker isEqual:pickerView]) {
        return @"Pick a Brewery";
    }
    else if ([self.stylePicker isEqual:pickerView]) {
        return @"Pick a Style";
    }
    
    return nil;
}

- (NSString *)placeholderTextForPickerView:(SHMenuAdminPickerViewController *)pickerView {
    if ([self.breweryPicker isEqual:pickerView]) {
        return @"Search breweries...";
    }
    else if ([self.stylePicker isEqual:pickerView]) {
        return @"Search styles...";
    }
    
    return nil;
}

- (NSInteger)numberOfItemsForPickerView:(SHMenuAdminPickerViewController *)pickerView {
    if ([self.breweryPicker isEqual:pickerView]) {
        return self.breweries.count;
    }
    else if ([self.stylePicker isEqual:pickerView]) {
        return self.beerStyles.count;
    }
    
    return 0;
}

- (NSString *)textForPickerView:(SHMenuAdminPickerViewController *)pickerView atIndexPath:(NSIndexPath *)indexPath {
    if ([self.breweryPicker isEqual:pickerView]) {
        if (indexPath.row < self.breweries.count) {
            SpotModel *brewery = self.breweries[indexPath.row];
            return brewery.name;
        }
    }
    else if ([self.stylePicker isEqual:pickerView]) {
        if (indexPath.row < self.beerStyles.count) {
            return self.beerStyles[indexPath.row];
        }
    }
    
    return nil;
}

- (void)pickerView:(SHMenuAdminPickerViewController *)pickerView didChangeSearchText:(NSString *)text {
    if ([self.breweryPicker isEqual:pickerView]) {
        if (text.length) {
            [pickerView startSearching];
            [[SpotModel queryBreweriesWithText:text page:@1] then:^(NSArray *breweries) {
                [pickerView stopSearching];
                self.breweries = breweries;
                [self.breweryPicker reloadData];
            } fail:^(id error) {
                // TODO: log error
            } always:nil];
        }
        else {
            self.breweries = @[];
            [self.breweryPicker reloadData];
        }
        
    }
    else if ([self.stylePicker isEqual:pickerView]) {
        if (text.length) {
            [pickerView startSearching];
            self.beerStyles = [self.allBeerStyles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", text]];
            [pickerView stopSearching];
            [pickerView reloadData];
        }
        else {
            self.beerStyles = self.allBeerStyles.copy;
            [pickerView reloadData];
        }
    }
}

- (void)pickerView:(SHMenuAdminPickerViewController *)pickerView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.breweryPicker isEqual:pickerView]) {
        if (indexPath.row < self.breweries.count) {
            self.selectedBrewery = self.breweries[indexPath.row];
            self.breweryLabel.text = self.selectedBrewery.name;
        }
    }
    else if ([self.stylePicker isEqual:pickerView]) {
        if (indexPath.row < self.beerStyles.count) {
            self.selectedBeerStyle = self.beerStyles[indexPath.row];
            self.styleLabel.text = self.selectedBeerStyle;

        }
    }
    
    [self closePickerView:pickerView];
}

- (void)pickerViewDidCancel:(SHMenuAdminPickerViewController *)pickerView {
    [self closePickerView:pickerView];
}

@end
