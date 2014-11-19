//
//  SHMenuAdminAddNewWineViewControllerViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 11/11/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHMenuAdminAddNewWineViewController.h"

#import "SHMenuAdminPickerViewController.h"

#import "DrinkModel.h"
#import "SpotModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubTypeModel.h"
#import "ErrorModel.h"

@interface SHMenuAdminAddNewWineViewController () <SHMenuAdminPickerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *wineNameTextField;

@property (weak, nonatomic) IBOutlet UILabel *wineryLabel;
@property (weak, nonatomic) IBOutlet UILabel *varietalLabel;
@property (weak, nonatomic) IBOutlet UILabel *vintageLabel;
@property (weak, nonatomic) IBOutlet UILabel *colorLabel;

@property (weak, nonatomic) IBOutlet UIButton *setWineryButton;
@property (weak, nonatomic) IBOutlet UIButton *setVarietalButton;
@property (weak, nonatomic) IBOutlet UIButton *setVintageButton;
@property (weak, nonatomic) IBOutlet UIButton *setColorButton;

@property (strong, nonatomic) NSArray *wineries;
@property (strong, nonatomic) NSArray *varietals;
@property (strong, nonatomic) NSArray *vintages;
@property (strong, nonatomic) NSArray *colors;

@property (strong, nonatomic) NSArray *allVarietals;
@property (strong, nonatomic) NSArray *allVintages;
@property (strong, nonatomic) NSArray *allColors;

@property (weak, nonatomic) SHMenuAdminPickerViewController *wineryPicker;
@property (weak, nonatomic) SHMenuAdminPickerViewController *varietalPicker;
@property (weak, nonatomic) SHMenuAdminPickerViewController *vintagePicker;
@property (weak, nonatomic) SHMenuAdminPickerViewController *colorPicker;

@property (strong, nonatomic) SpotModel *selectedWinery;
@property (strong, nonatomic) NSString *selectedVarietal;
@property (strong, nonatomic) NSString *selectedVintage;
@property (strong, nonatomic) DrinkSubTypeModel *selectedColor;

@end

@implementation SHMenuAdminAddNewWineViewController

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
    
    [self.wineNameTextField becomeFirstResponder];
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
    if ([sender isEqual:self.setWineryButton]) {
        if ([segue.destinationViewController isKindOfClass:[SHMenuAdminPickerViewController class]]) {
            SHMenuAdminPickerViewController *pickerVC = (SHMenuAdminPickerViewController *)segue.destinationViewController;
            pickerVC.delegate = self;
            self.wineryPicker = pickerVC;
            self.wineries = @[];
            [pickerVC reloadData];
        }
    }
    else if ([sender isEqual:self.setVarietalButton]) {
        if ([segue.destinationViewController isKindOfClass:[SHMenuAdminPickerViewController class]]) {
            SHMenuAdminPickerViewController *pickerVC = (SHMenuAdminPickerViewController *)segue.destinationViewController;
            pickerVC.delegate = self;
            self.varietalPicker = pickerVC;
            
            self.varietals = @[];
            
            [[DrinkModel fetchWineVarietals] then:^(NSArray *varietals) {
                self.allVarietals = varietals;
                self.varietals = varietals.copy;
                [pickerVC reloadData];
            } fail:^(id error) {
            } always:nil];
        }
    }
    else if ([sender isEqual:self.setVintageButton]) {
        if ([segue.destinationViewController isKindOfClass:[SHMenuAdminPickerViewController class]]) {
            SHMenuAdminPickerViewController *pickerVC = (SHMenuAdminPickerViewController *)segue.destinationViewController;
            pickerVC.delegate = self;
            self.vintagePicker = pickerVC;
            
            // add current year minus 100 years
            NSMutableArray *allVintages = @[].mutableCopy;
            NSDate *now = [NSDate date];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:now];
            NSInteger currentYear = components.year;
            NSInteger year = currentYear;

            while (year > currentYear - 100) {
                [allVintages addObject:[NSString stringWithFormat:@"%li", (long)year]];
                year--;
            }
            
            self.allVintages = allVintages;
            self.vintages = allVintages.copy;
            [pickerVC reloadData];
        }
    }
    else if ([sender isEqual:self.setColorButton]) {
        if ([segue.destinationViewController isKindOfClass:[SHMenuAdminPickerViewController class]]) {
            SHMenuAdminPickerViewController *pickerVC = (SHMenuAdminPickerViewController *)segue.destinationViewController;
            pickerVC.delegate = self;
            self.colorPicker = pickerVC;

            [[DrinkModel fetchWineTypes] then:^(NSArray *wineTypes) {
                self.allColors = wineTypes;
                self.colors = wineTypes.copy;
                [pickerVC reloadData];
            } fail:^(id error) {
            } always:nil];
            
            [pickerVC reloadData];
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
    if ([self.delegate respondsToSelector:@selector(addNewWineViewControllerDidCancel:)]) {
        [self.delegate addNewWineViewControllerDidCancel:self];
    }
}

- (IBAction)saveButtonTapped:(id)sender {
    [self saveDrink];
}

- (IBAction)setButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"NewWineToPicker" sender:sender];
}

#pragma mark - Private
#pragma mark -

- (void)closePickerView:(SHMenuAdminPickerViewController *)pickerView {
    if ([self.navigationController.topViewController isEqual:pickerView]) {
        [self.navigationController popToViewController:self animated:TRUE];
    }
    
    // clear property references immediately
    if ([self.wineryPicker isEqual:pickerView]) {
        self.wineryPicker = nil;
    }
    else if ([self.varietalPicker isEqual:pickerView]) {
        self.varietalPicker = nil;
    }
    else if ([self.vintagePicker isEqual:pickerView]) {
        self.vintagePicker = nil;
    }
    else if ([self.colorPicker isEqual:pickerView]) {
        self.colorPicker = nil;
    }
}

- (void)saveDrink {
    // validation
    if (!self.wineNameTextField.text.length) {
        [self showAlert:@"Oops" message:@"Name is required"];
        return;
    }
    else if (!self.selectedWinery) {
        [self showAlert:@"Oops" message:@"Winery is required"];
        return;
    }
    else if (!self.selectedVarietal.length) {
        [self showAlert:@"Oops" message:@"Varietal is required"];
        return;
    }
    
    DrinkModel *drink = [[DrinkModel alloc] init];
    drink.name = self.wineNameTextField.text;
    drink.drinkType = [DrinkTypeModel wineDrinkType];
    drink.spot = self.selectedWinery;
    if (self.selectedVintage.length) {
        drink.vintage = [NSNumber numberWithInteger:[self.selectedVintage integerValue]];
    }
    drink.varietal = self.selectedVarietal;
    
    [DrinkModel createDrink:drink success:^(DrinkModel *drinkModel) {
        if ([self.delegate respondsToSelector:@selector(addNewWineViewController:didCreateDrink:)]) {
            [self.delegate addNewWineViewController:self didCreateDrink:drinkModel];
        }
    } failure:^(ErrorModel *errorModel) {
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

#pragma mark - SHMenuAdminPickerDelegate
#pragma mark -

- (NSString *)titleTextForPickerView:(SHMenuAdminPickerViewController *)pickerView {
    if ([pickerView isEqual:self.wineryPicker]) {
        return @"Pick a Winery";
    }
    else if ([pickerView isEqual:self.varietalPicker]) {
        return @"Pick a Varietal";
    }
    else if ([pickerView isEqual:self.vintagePicker]) {
        return @"Pick a Vintage";
    }
    else if ([pickerView isEqual:self.colorPicker]) {
        return @"Pick a Color";
    }
    
    return nil;
}

- (NSString *)placeholderTextForPickerView:(SHMenuAdminPickerViewController *)pickerView {
    if ([pickerView isEqual:self.wineryPicker]) {
        return @"Search wineries...";
    }
    else if ([pickerView isEqual:self.varietalPicker]) {
        return @"Search varietals...";
    }
    else if ([pickerView isEqual:self.vintagePicker]) {
        return @"Search vintages...";
    }
    else if ([pickerView isEqual:self.colorPicker]) {
        return @"Search colors...";
    }

    return nil;
}

- (NSInteger)numberOfItemsForPickerView:(SHMenuAdminPickerViewController *)pickerView {
    if ([pickerView isEqual:self.wineryPicker]) {
        return self.wineries.count;
    }
    else if ([pickerView isEqual:self.varietalPicker]) {
        return self.varietals.count;
    }
    else if ([pickerView isEqual:self.vintagePicker]) {
        return self.vintages.count;
    }
    else if ([pickerView isEqual:self.colorPicker]) {
        return self.colors.count;
    }

    return 0;
}

- (NSString *)textForPickerView:(SHMenuAdminPickerViewController *)pickerView atIndexPath:(NSIndexPath *)indexPath {
    if ([pickerView isEqual:self.wineryPicker]) {
        if (indexPath.row < self.wineries.count) {
            SpotModel *winery = self.wineries[indexPath.row];
            return winery.name;
        }
    }
    else if ([pickerView isEqual:self.varietalPicker]) {
        if (indexPath.row < self.varietals.count) {
            NSString *varietal = self.varietals[indexPath.row];
            return varietal;
        }
    }
    else if ([pickerView isEqual:self.vintagePicker]) {
        if (indexPath.row < self.vintages.count) {
            NSString *vintage = self.vintages[indexPath.row];
            return vintage;
        }
    }
    else if ([pickerView isEqual:self.colorPicker]) {
        if (indexPath.row < self.colors.count) {
            DrinkSubTypeModel *color = self.colors[indexPath.row];
            return color.name;
        }
    }

    return nil;
}

- (void)pickerView:(SHMenuAdminPickerViewController *)pickerView didChangeSearchText:(NSString *)text {
    if ([pickerView isEqual:self.wineryPicker]) {
        if (text.length) {
            [pickerView startSearching];
            [[SpotModel queryWineriesWithText:text page:@1] then:^(NSArray *wineries) {
                [pickerView stopSearching];
                self.wineries = wineries;
                [pickerView reloadData];
            } fail:^(id error) {
                // TODO: log error
            } always:nil];
        }
        else {
            self.wineries = @[];
            [pickerView reloadData];
        }
    }
    else if ([pickerView isEqual:self.varietalPicker]) {
        if (text.length) {
            [pickerView startSearching];
            self.varietals = [self.allVarietals filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", text]];
            [pickerView stopSearching];
            [pickerView reloadData];
        }
        else {
            self.varietals = self.allVarietals.copy;
            [pickerView reloadData];
        }
    }
    else if ([pickerView isEqual:self.vintagePicker]) {
        if (text.length) {
            [pickerView startSearching];
            self.vintages = [self.allVintages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", text]];
            [pickerView stopSearching];
            [pickerView reloadData];
        }
        else {
            self.vintages = self.allVintages.copy;
            [pickerView reloadData];
        }
    }
    else if ([pickerView isEqual:self.colorPicker]) {
        if (text.length) {
            [pickerView startSearching];
            self.colors = [self.allColors filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", text]];
            [pickerView stopSearching];
            [pickerView reloadData];
        }
        else {
            self.colors = self.allColors.copy;
            [pickerView reloadData];
        }
    }
}

- (void)pickerView:(SHMenuAdminPickerViewController *)pickerView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([pickerView isEqual:self.wineryPicker]) {
        if (indexPath.row < self.wineries.count) {
            self.selectedWinery = self.wineries[indexPath.row];
            self.wineryLabel.text = self.selectedWinery.name;
        }
    }
    else if ([pickerView isEqual:self.varietalPicker]) {
        if (indexPath.row < self.varietals.count) {
            self.selectedVarietal = self.varietals[indexPath.row];
            self.varietalLabel.text = self.selectedVarietal;
        }
    }
    else if ([pickerView isEqual:self.vintagePicker]) {
        if (indexPath.row < self.vintages.count) {
            self.selectedVintage = self.vintages[indexPath.row];
            self.vintageLabel.text = self.selectedVintage;
        }
    }
    else if ([pickerView isEqual:self.colorPicker]) {
        if (indexPath.row < self.colors.count) {
            DrinkSubTypeModel *color = self.colors[indexPath.row];
            self.selectedColor = color;
            self.colorLabel.text = color.name;
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
