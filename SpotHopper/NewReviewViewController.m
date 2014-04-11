//
//  NewReviewViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/8/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kSpotTypeFilterBrewery @"brewery"
#define kSpotTypeFilterWinery @"winery"

#define kSpotReviewType 0
#define kReviewTypeIcons @[@"btn_sidebar_icon_spots", @"icon_beer", @"icon_cocktails", @"icon_wine"]

#import "MyReviewsViewController.h"

#import "SHButtonLatoLight.h"
#import "CLGeocoder+DoubleLookup.h"
#import "NSString+Common.h"
#import "UIView+ViewFromNib.h"
#import "UIViewController+Navigator.h"

#import "SectionHeaderView.h"
#import "AutoCompleteCell.h"
#import "DropdownOptionCell.h"
#import "ReviewSliderCell.h"

#import "ReviewsMenuViewController.h"
#import "SearchNewReviewViewController.h"

#import "ErrorModel.h"
#import "BaseAlcoholModel.h"

#import <JHAccordion/JHAccordion.h>
#import <JHAutoCompleteTextField/JHAutoCompleteTextField.h>

#import "NewReviewViewController.h"

@interface NewReviewViewController ()<UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, JHAccordionDelegate, JHAutoCompleteDataSource, JHAutoCompleteDelegate, ReviewSliderCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblReviews;
@property (weak, nonatomic) IBOutlet UITableView *tblReviewTypes;

@property (nonatomic, assign) CGRect tblReviewsInitalFrame;

@property (nonatomic, strong) SectionHeaderView *sectionHeaderReviewType;

@property (nonatomic, strong) JHAccordion *accordionAdvanced;
@property (nonatomic, strong) SectionHeaderView *sectionHeaderAdvanced;

@property (nonatomic, assign) NSInteger selectedReviewType;

@property (nonatomic, strong) NSArray *spotTypes;
@property (nonatomic, strong) NSArray *brewerySpotTypes;
@property (nonatomic, strong) NSArray *winerySpotTypes;
@property (nonatomic, strong) NSArray *drinkTypes;
@property (nonatomic, strong) NSArray *beerStyles;
@property (nonatomic, strong) NSArray *wineVarietals;
@property (nonatomic, strong) NSArray *cocktailTypes;
@property (nonatomic, strong) NSArray *cocktailBaseAlcohols;

@property (nonatomic, strong) DrinkModel *createdDrink;
@property (nonatomic, strong) SpotModel *createdSpot;

@property (nonatomic, strong) SliderModel *reviewRatingSlider;
@property (nonatomic, strong) NSArray *sliderTemplates;
@property (nonatomic, strong) NSMutableArray *sliders;
@property (nonatomic, strong) NSMutableArray *advancedSliders;

@property (nonatomic, strong) SpotModel *selectedDrinkSpot;
@property (nonatomic, strong) NSDictionary *selectedSpotType;
@property (nonatomic, strong) NSDictionary *selectedCocktailSubtype;
@property (nonatomic, strong) BaseAlcoholModel *selectedCocktailBaseAlcohol;

// Forms
@property (nonatomic, strong) UIView *viewFormNewSpot;
@property (nonatomic, strong) UIView *viewFormNewBeer;
@property (nonatomic, strong) UIView *viewFormNewCocktail;
@property (nonatomic, strong) UIView *viewFormNewWine;

// Spot
@property (weak, nonatomic) IBOutlet UITextField *txtSpotName;
@property (weak, nonatomic) IBOutlet UITextField *txtSpotType;
@property (weak, nonatomic) IBOutlet UITextField *txtSpotAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtSpotCity;
@property (weak, nonatomic) IBOutlet UITextField *txtSpotState;
@property (nonatomic, strong) UIPickerView *pickerViewSpotType;
@property (nonatomic, strong) UISegmentedControl *segControlForSpotType;
@property (nonatomic, strong) UIPickerView *pickerViewState;
@property (nonatomic, strong) UISegmentedControl *segControlForState;

// Beer
@property (weak, nonatomic) IBOutlet UITextField *txtBeerName;
@property (weak, nonatomic) IBOutlet UITextField *txtBeerBreweryName;
@property (weak, nonatomic) IBOutlet UITextField *txtBeerStyle;

// Wine
@property (weak, nonatomic) IBOutlet UITextField *txtWineStyle;
@property (weak, nonatomic) IBOutlet UITextField *txtWineWineryName;
@property (weak, nonatomic) IBOutlet UITextField *txtWineName;

// Cocktail
@property (weak, nonatomic) IBOutlet UITextField *txtCocktailName;
@property (weak, nonatomic) IBOutlet UITextField *txtCocktailType;
@property (weak, nonatomic) IBOutlet UITextField *txtCocktailAlcoholType;
@property (nonatomic, strong) UIPickerView *pickerViewCocktailType;
@property (nonatomic, strong) UISegmentedControl *segControlForCocktailType;
@property (nonatomic, strong) UIPickerView *pickerViewCocktailBaseAlcoholType;
@property (nonatomic, strong) UISegmentedControl *segControlForCocktailAlcoholType;

@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

@property (nonatomic, strong) UIStoryboard *commonStoryboard;

@end

@implementation NewReviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsBlurredBackground,kDidLoadOptionsDontAdjustForIOS6]];
    
    // Sets title
    [self setTitle:@"New Reviews"];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Configures accordion - advanced sliders
    _accordionAdvanced = [[JHAccordion alloc] initWithTableView:_tblReviews];
    [_accordionAdvanced setDelegate:self];
    [_accordionAdvanced openSection:0];
    
    // Configures table
    [_tblReviews setTableFooterView:[[UIView alloc] init]];
    [_tblReviews registerNib:[UINib nibWithNibName:@"ReviewSliderCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ReviewSliderCell"];
    
    // Initializes states
    _selectedReviewType = [kReviewTypes indexOfObject:_reviewType];
    _tblReviewsInitalFrame = CGRectZero;
    _sliders = [NSMutableArray array];
    _reviewRatingSlider = [ReviewModel ratingSliderModel];
    
    [_tblReviews setTableHeaderView:[self formForReviewTypeIndex:_selectedReviewType]];
    [self fetchFormData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Deselects table row
    [_tblReviews deselectRowAtIndexPath:_tblReviews.indexPathForSelectedRow animated:NO];
    
    [_btnSubmit setHidden:TRUE];
    
    // Gets table frame
    if (CGRectEqualToRect(_tblReviewsInitalFrame, CGRectZero)) {
        _tblReviewsInitalFrame = _tblReviews.frame;
    }
    
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Keyboard

- (NSArray *)textfieldToHideKeyboard {
    return @[];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    [self keyboardWillHideOrShow:notification show:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [self keyboardWillHideOrShow:notification show:NO];
}

- (void)keyboardWillHideOrShow:(NSNotification*)notification show:(BOOL)show {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect frame = _tblReviews.frame;
    if (show == YES) {
        frame.size.height = CGRectGetHeight(self.view.frame) - CGRectGetMinY(frame) - CGRectGetHeight(keyboardFrame);
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            frame.size.height -= 20.0f;
        }
    } else {
        frame = _tblReviewsInitalFrame;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        [_tblReviews setFrame:frame];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _tblReviewTypes) {
        return 1;
    } else if (tableView == _tblReviews) {
        return 3;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tblReviewTypes) {
        return 0;
    } else if (tableView == _tblReviews) {
        if (section == 0) {
            if (_selectedReviewType > 0) {
                return 1;
            }
        } else if (section == 1) {
            return _sliders.count;
        } else if (section == 2) {
            return _advancedSliders.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tblReviews) {
        if (indexPath.section == 0) {
            ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
            [cell setDelegate:self];
            [cell setSliderTemplate:_reviewRatingSlider.sliderTemplate withSlider:_reviewRatingSlider showSliderValue:YES];
            
            return cell;
        } else if (indexPath.section == 1) {
            
            SliderModel *slider = [_sliders objectAtIndex:indexPath.row];
             
            ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
            [cell setDelegate:self];
            [cell setSliderTemplate:slider.sliderTemplate withSlider:slider showSliderValue:NO];
            
            return cell;
        } else if (indexPath.section == 2) {
            
            SliderModel *slider = [_advancedSliders objectAtIndex:indexPath.row];
            
            ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
            [cell setDelegate:self];
            [cell setSliderTemplate:slider.sliderTemplate withSlider:slider showSliderValue:NO];
            
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexfPath:(NSIndexPath *)indexPath {
    if (tableView == _tblReviews) {
        
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _tblReviewTypes) {
        if (section == 0) {
            return [self sectionHeaderViewForSection:section];
        }
    }
    else if (tableView == _tblReviews) {
        if (section == 2) {
            if (_sectionHeaderAdvanced == nil) {
                _sectionHeaderAdvanced = [self instantiateSectionHeaderView];
                [_sectionHeaderAdvanced setBackgroundColor:[UIColor clearColor]];
                [_sectionHeaderAdvanced setText:@"Advanced"];
                [_sectionHeaderAdvanced setSelected:[_accordionAdvanced isSectionOpened:section]];
                
                // Sets up for accordion
                [_sectionHeaderAdvanced.btnBackground setTag:section];
                [_sectionHeaderAdvanced.btnBackground addTarget:_accordionAdvanced action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            }
            return _sectionHeaderAdvanced;
        }
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _tblReviewTypes) {
        if (section == 0) {
            return 65.0f;
        }
    } else if (tableView == _tblReviews) {
        if (section == 2) {
            if (_advancedSliders.count > 0) {
                return 65.0f;
            }
        }
    }
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tblReviews) {
        if (indexPath.section == 0 || indexPath.section == 1) {
            if (_selectedReviewType >= 0) {
                return 77.0f;
            }
        } else if (indexPath.section == 2) {
            return ( [_accordionAdvanced isSectionOpened:indexPath.section] ? 77.0f : 0.0f);
        }
    }
    
    return 0.0f;
}

#pragma mark - JHAccordionDelegate

- (void)accordion:(JHAccordion *)accordion openingSection:(NSInteger)section {
    if (accordion == _accordionAdvanced) {
        if (section == 2) [_sectionHeaderAdvanced setSelected:YES];
    }
}

- (void)accordion:(JHAccordion *)accordion closingSection:(NSInteger)section {
    if (accordion == _accordionAdvanced) {
        if (section == 2) [_sectionHeaderAdvanced setSelected:NO];
    }
}

- (void)accordion:(JHAccordion *)accordion openedSection:(NSInteger)section {
    CGRect sectionRect = [_tblReviews rectForSection:section];
    
    CGFloat tableHeight = CGRectGetHeight(_tblReviews.frame);
    if (sectionRect.origin.y > tableHeight) {
        CGFloat newOffset = sectionRect.origin.y - (tableHeight / 3);
        CGPoint offset = CGPointMake(0.0, newOffset);
        [_tblReviews setContentOffset:offset animated:TRUE];
    }
}

- (void)accordion:(JHAccordion *)accordion closedSection:(NSInteger)section {

}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == _txtSpotType) {
        _selectedSpotType = nil;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == _txtSpotType) {
        if (_selectedSpotType == nil) {
            [_txtSpotType setText:@""];
            [_sliders removeAllObjects];
            _sliderTemplates = nil;
            [_tblReviews reloadData];
        }
    }
}

#pragma mark - JHAutoCompleteDataSource

- (void)autocomplete:(JHAutoCompleteView *)autocompleteView withQuery:(NSString *)query withBlock:(JHAutoCompleteResultsBlock)resultsBlock {
    
    if (resultsBlock != nil) {
        
        if (autocompleteView.textfield == _txtBeerBreweryName ||
            autocompleteView.textfield == _txtWineWineryName) {
            
            NSArray *spotTypeId = nil;
            if (autocompleteView.textfield == _txtBeerBreweryName) {
                NSArray *brewerySpotTypeIds = [_brewerySpotTypes valueForKeyPath:@"id"];
                spotTypeId = [brewerySpotTypeIds lastObject];
            } else if (autocompleteView.textfield == _txtWineWineryName) {
                NSArray *winerySpotTypeIds = [_winerySpotTypes valueForKeyPath:@"id"];
                spotTypeId = [winerySpotTypeIds lastObject];
            }
            
            if (spotTypeId == nil) {
                return;
            }
            
            NSDictionary *params = @{
                                     kSpotModelParamQuery : query,
                                     kSpotModelParamQuerySpotTypeId : spotTypeId
                                     };
            
            [SpotModel getSpots:params success:^(NSArray *spotModels, JSONAPI *jsonApi) {
                // Returning results onnew main queue
                resultsBlock(spotModels);
            } failure:^(ErrorModel *errorModel) {
                
            }];
            
            return;
        }
        
        // Performs filtering in background - could easily be an async network call
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            NSArray *array;
            if (autocompleteView.textfield == _txtSpotType) {
                if (query.length > 0) {
                    array = [_spotTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", query]];
                } else {
                    array = _spotTypes.copy;
                }
            } else if (autocompleteView.textfield == _txtBeerStyle){
                if (query.length > 0) {
                    array = [_beerStyles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", query]];
                } else {
                    array = _beerStyles.copy;
                }
            } else if (autocompleteView.textfield == _txtWineStyle) {
                array = [_wineVarietals filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", query]];
            }
            
            // Returning results on main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                resultsBlock(array);
            });
        });
    }
}

- (NSString *)autocomplete:(JHAutoCompleteView *)autocompleteView stringForObject:(id)object atIndex:(NSInteger)index {
    if (_txtSpotType.isFirstResponder) {
        return [object objectForKey:@"name"];
    }
    
    return object;
}

#pragma mark - JHAutoCompleteDelegate

- (NSInteger)autocompleteMinumumNumberOfCharters:(JHAutoCompleteView *)autocompleteView {
    // Shows all results always for spot type and cocktail
    if (autocompleteView.textfield == _txtSpotType || autocompleteView.textfield == _txtBeerStyle) {
        return 0;
    }
    
    return 1;
}

- (void)autocompleteWillShow:(JHAutoCompleteView *)autocompleteView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_tblReviews setContentOffset:CGPointMake(0.0f, CGRectGetMinY(autocompleteView.textfield.frame) - 15.0f) animated:YES];
    });
}

- (BOOL)autocompleteHasKeyboardAccessory:(JHAutoCompleteView *)autocomplteView {
    return YES;
}

- (CGFloat)autocompleteHeight {
    return 100.0f;
}

- (CGFloat)autocomplete:(JHAutoCompleteView *)autocomplete heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)autoComplete:(JHAutoCompleteView *)autocomplete withCell:(UITableViewCell *)cell withRowAtIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    AutoCompleteCell *autoCompleteCell = (AutoCompleteCell*)cell;
    if (autocomplete.textfield == _txtSpotType) {
        autoCompleteCell.lblTitle.text = [object objectForKey:@"name"];
    } else if ([object isKindOfClass:[NSString class]] == YES) {
        autoCompleteCell.lblTitle.text = object;
    } else if (autocomplete.textfield == _txtBeerBreweryName) {
        SpotModel *spot = (SpotModel*)object;
        autoCompleteCell.lblTitle.text = spot.name;
    } else if (autocomplete.textfield == _txtWineWineryName) {
        SpotModel *spot = (SpotModel*)object;
        autoCompleteCell.lblTitle.text = spot.name;
    }
}

- (void)autocomplete:(JHAutoCompleteView *)autocompleteView selectedObject:(id)object atIndex:(NSInteger)index {
    UITextField *textField = autocompleteView.textfield;
    if (textField == _txtSpotType) {
        _selectedSpotType = object;
        textField.text = [_selectedSpotType objectForKey:@"name"];
        
        [self fetchSliderTemplates:_selectedReviewType];
    } else if (textField == _txtBeerBreweryName) {
        _selectedDrinkSpot = object;
        textField.text = _selectedDrinkSpot.name;
    } else if (textField == _txtWineWineryName) {
        _selectedDrinkSpot = object;
        textField.text = _selectedDrinkSpot.name;
    } else if ([object isKindOfClass:[NSString class]] == YES) {
        textField.text = object;
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == _pickerViewSpotType) {
        return _spotTypes.count;
    } else if (pickerView == _pickerViewState) {
        return kStateList.count;
    } else if (pickerView == _pickerViewCocktailType) {
        return _cocktailTypes.count;
    } else if (pickerView == _pickerViewCocktailBaseAlcoholType) {
        return _cocktailBaseAlcohols.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == _pickerViewSpotType) {
        NSDictionary *spotType = [_spotTypes objectAtIndex:row];
        return [spotType objectForKey:@"name"];
    } else if (pickerView == _pickerViewState) {
        return [kStateList objectAtIndex:row];
    } else if (pickerView == _pickerViewCocktailType) {
        NSDictionary *cocktailType = [_cocktailTypes objectAtIndex:row];
        return [cocktailType objectForKey:@"name"];
    } else if (pickerView == _pickerViewCocktailBaseAlcoholType) {
        BaseAlcoholModel *baseAlcohol = [_cocktailBaseAlcohols objectAtIndex:row];
        return baseAlcohol.name;
    }
    return nil;
}

#pragma mark - ReviewSliderCellDelegate

- (void)reviewSliderCell:(ReviewSliderCell *)cell changedValue:(CGFloat)value {
    
    // Sets slider to darker/selected color for good
    [cell.slider setUserMoved:YES];
    
    NSIndexPath *indexPath = [_tblReviews indexPathForCell:cell];
    
    if (indexPath.section == 0) {
        [_reviewRatingSlider setValue:[NSNumber numberWithFloat:(value * 10)]];
    } else if (indexPath.section == 1) {
        SliderModel *slider = [_sliders objectAtIndex:indexPath.row];
        [slider setValue:[NSNumber numberWithFloat:(value * 10)]];
    } else if (indexPath.section == 2) {
        SliderModel *slider = [_advancedSliders objectAtIndex:indexPath.row];
        [slider setValue:[NSNumber numberWithFloat:(value * 10)]];
    }
}

- (void)reviewSliderCell:(ReviewSliderCell*)cell finishedChangingValue:(CGFloat)value {
    // move table view of sliders up a little to make the next slider visible
    [self slideCell:cell aboveTableViewMidwayPoint:_tblReviews];
    
    if (_btnSubmit.hidden) {
        [_btnSubmit setHidden:FALSE];
        [_btnSubmit setTitle:@"Submit Review" forState:UIControlStateNormal];
        
        // 1) position it below the superview (out of view)
        // 2) set to hidden = false
        // 3) animate it up into position
        // 4) update the table with insets so it will not cover sliders
        
        CGFloat buttonHeight = CGRectGetHeight(_btnSubmit.frame);
        CGFloat viewHeight = CGRectGetHeight(self.view.frame);
        
        CGRect hiddenFrame = _btnSubmit.frame;
        hiddenFrame.origin.y = viewHeight;
        _btnSubmit.frame = hiddenFrame;
        _btnSubmit.hidden = FALSE;
        [self.view bringSubviewToFront:_btnSubmit];
        
        [UIView animateWithDuration:0.5 animations:^{
            CGRect visibleFrame = _btnSubmit.frame;
            visibleFrame.origin.y = viewHeight - buttonHeight;
            _btnSubmit.frame = visibleFrame;
            _tblReviews.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, buttonHeight, 0.0f);
            _tblReviews.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, buttonHeight, 0.0f);
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - Actions

- (void)onClickChooseSpotType:(id)sender {
    _selectedSpotType = [_spotTypes objectAtIndex:[_pickerViewSpotType selectedRowInComponent:0]];
    [self.view endEditing:YES];
    
    _txtSpotType.text = [_selectedSpotType objectForKey:@"name"];
    [self fetchSliderTemplates:_selectedReviewType];
}

- (void)onClickChooseState:(id)sender {
    NSString *state = [kStateList objectAtIndex:[_pickerViewState selectedRowInComponent:0]];
    [self.view endEditing:YES];
    
    _txtSpotState.text = state;
}

- (void)onClickChooseCocktailType:(id)sender {
    _selectedCocktailSubtype = [_cocktailTypes objectAtIndex:[_pickerViewCocktailType selectedRowInComponent:0]];
    [self.view endEditing:YES];
    
    _txtCocktailType.text = [_selectedCocktailSubtype objectForKey:@"name"];
}

- (void)onClickChooseCocktailAlcoholType:(id)sender {
    _selectedCocktailBaseAlcohol = [_cocktailBaseAlcohols objectAtIndex:[_pickerViewCocktailBaseAlcoholType selectedRowInComponent:0]];
    [self.view endEditing:YES];
    
    _txtCocktailAlcoholType.text = _selectedCocktailBaseAlcohol.name;
}

- (IBAction)onClickSubmit:(id)sender {
    
    // Validating selected spot id exists first
    // since a spot type is required to show sliders
    if (_selectedReviewType == kSpotReviewType && ( _selectedSpotType == nil || [_selectedSpotType objectForKey:@"id"] == nil )) {
        [self showAlert:@"Oops" message:@"Please select a spot type before submitting"];
        return;
    }
    
    /*
     * Make sure all required spotlist shave been modified
     */
    if (_selectedReviewType != kSpotReviewType && _reviewRatingSlider != nil && _reviewRatingSlider.value == nil) {
        [self showAlert:@"Oops" message:@"Please adjust the rating slider before submitting"];
        return;
    }
    
    // Checks to make sure one value has been slid
    BOOL oneSliderSlid = NO;
    for (SliderModel *slider in _sliders) {
        if (slider.value != nil) {
            oneSliderSlid = YES;
            break;
        }
    }
    
    // Alerts if no sliders slid
    if (oneSliderSlid == NO) {
        [self showAlert:@"Oops" message:@"Please adjust at least one slider before submitting"];
        return;
    }
    
    // Spot
    if (_selectedReviewType == kSpotReviewType) {
        
        NSString *name = _txtSpotName.text;
        NSString *address = _txtSpotAddress.text;
        NSString *city = _txtSpotCity.text;
        NSString *state = _txtSpotState.text;
        
        // Form text field validations
        if (name.length == 0) {
            [self showAlert:@"Oops" message:@"Name is required"];
            return;
        } else if (address.length == 0) {
            [self showAlert:@"Oops" message:@"Address is required"];
            return;
        } else if (city.length == 0) {
            [self showAlert:@"Oops" message:@"City is required"];
            return;
        } else if (state.length == 0) {
            [self showAlert:@"Oops" message:@"State is required"];
            return;
        }

        NSNumber *spotTypeId = [_selectedSpotType objectForKey:@"id"];
        
        // Looks up zip code from address, city, and state
        [self showHUD:@"Verifying address"];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder doubleGeocodeAddressDictionary:@{ @"Address" : address, @"City" : city, @"State" : state } completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = placemarks.firstObject;
            if (error || placemark == nil) {
                [self showAlert:@"Oops" message:@"Could not get zip code based on address, city, and state"];
                return;
            }
            
            NSString *zipCode = placemark.postalCode;
                
            NSMutableDictionary *params = @{
                                     kSpotModelParamName: name,
                                     kSpotModelParamAddress: address,
                                     kSpotModelParamCity: city,
                                     kSpotModelParamState: state,
                                     kSpotModelParamZip : zipCode,
                                     kSpotModelParamSpotTypeId: spotTypeId
                                     }.mutableCopy;
            
            if (_spotBasedOffOf != nil) {
                if (_spotBasedOffOf.latitude != nil && _spotBasedOffOf.longitude != nil) {
                    [params setObject:_spotBasedOffOf.latitude forKey:kSpotModelParamLatitude];
                    [params setObject:_spotBasedOffOf.longitude forKey:kSpotModelParamLongitude];
                }
                
                if (_spotBasedOffOf.foursquareId.length > 0) {
                    [params setObject:_spotBasedOffOf.foursquareId forKey:kSpotModelParamFoursquareId];
                }
                
            } else if (placemark.location != nil) {
                [params setObject:[NSNumber numberWithFloat:placemark.location.coordinate.latitude] forKey:kSpotModelParamLatitude];
                [params setObject:[NSNumber numberWithFloat:placemark.location.coordinate.longitude] forKey:kSpotModelParamLongitude];
            }
            
            // Send request to create spot
            [self hideHUD];
            [self createSpot:params];

        }];
    }
    // Beer
    else if (_selectedReviewType == 1) {
        
        NSString *name = _txtBeerName.text;
        NSString *breweryName = _txtBeerBreweryName.text;
        NSString *style = _txtBeerStyle.text;
        
        // Form text field validations
        if (name.length == 0) {
            [self showAlert:@"Oops" message:@"Name is required"];
            return;
        } else if (style.length == 0) {
            [self showAlert:@"Oops" message:@"Style is required"];
            return;
        }
        
        // Validating selected drink id exists
        NSDictionary *drinkType = [self getDrinkType:_selectedReviewType];
        if (drinkType == nil || [drinkType objectForKey:@"id"] == nil) {
            [self showAlert:@"Oops" message:@"Not able to submit a beer right now"];
            [[RavenClient sharedClient] captureMessage:@"Drink type nil when trying to create beer" level:kRavenLogLevelDebugError];
            return;
        }
        NSNumber *drinkId = [drinkType objectForKey:@"id"];
        
        NSMutableDictionary *params = @{
                                 kDrinkModelParamName: name,
                                 kDrinkModelParamStyle: style,
                                 kDrinkModelParamDrinkTypeId: drinkId
                                 }.mutableCopy;
        
        // Makes sure the selected drink spot is selected and that the selected drink spot is equal to the text field
        if (_selectedDrinkSpot != nil && [_selectedDrinkSpot.name isEqualToString:breweryName]) {
            [params setObject:_selectedDrinkSpot.ID forKey:kDrinkModelParamSpotId];

            [self createDrink:params];
        } else if (breweryName.length > 0) {
            
            [self showHUD:@"Creating brewery"];
            [SpotModel postSpot:@{
                                  kSpotModelParamName : breweryName
                                  } success:^(SpotModel *spotModel, JSONAPI *jsonApi) {
                                      [self hideHUD];
                                      
                                      // Set created spot id
                                      [params setObject:spotModel.ID forKey:kDrinkModelParamSpotId];
                                      
                                      // Send request to create drink
                                      [self createDrink:params];
                                      
            } failure:^(ErrorModel *errorModel) {
                [self hideHUD];
                [self showAlert:@"Oops" message:errorModel.human];
            }];
            
        } else {
            // Send request to create drink
            [self createDrink:params];
        }

    }
    // Cocktail
    else if (_selectedReviewType == 2) {
        NSString *name = _txtCocktailName.text;
        
        // Form text field validations
        if (name.length == 0) {
            [self showAlert:@"Oops" message:@"Name is required"];
            return;
        }
        
        // Validating selected drink id exists
        NSDictionary *drinkType = [self getDrinkType:_selectedReviewType];
        if (drinkType == nil || [drinkType objectForKey:@"id"] == nil) {
            [self showAlert:@"Oops" message:@"Not able to submit a cocktail right now"];
            return;
        }
        NSNumber *drinkId = [drinkType objectForKey:@"id"];
        
        // Validating selected drink subtype id exists
        if (_selectedCocktailSubtype == nil || [_selectedCocktailSubtype objectForKey:@"id"] == nil) {
            [self showAlert:@"Oops" message:@"A cocktail type is required"];
            return;
        }
        NSNumber *drinkSubtypeId = [_selectedCocktailSubtype objectForKey:@"id"];
        
        // Validating selected base alcohol
        if (_selectedCocktailBaseAlcohol == nil) {
            [self showAlert:@"Oops" message:@"A base alcohol is required"];
            return;
        }
        
        NSDictionary *params = @{
                                 kDrinkModelParamName: name,
                                 kDrinkModelParamDrinkTypeId: drinkId,
                                 kDrinkModelParamDrinkSubtypeId: drinkSubtypeId,
                                 kDrinkModelParamBaseAlcohols : @[ _selectedCocktailBaseAlcohol.ID ]
                                 };
        
        // Send request to create drink
        [self createDrink:params];
    }
    // Wine
    else if (_selectedReviewType == 3) {
        NSString *varietal = _txtWineStyle.text;
        NSString *wineryName = _txtWineWineryName.text;
        NSString *name = _txtWineName.text;
        
        // Form text field validations
        if (varietal.length == 0) {
            [self showAlert:@"Oops" message:@"Varietal is required"];
            return;
        }
        
        // Validating selected drink id exists
        NSDictionary *drinkType = [self getDrinkType:_selectedReviewType];
        if (drinkType == nil || [drinkType objectForKey:@"id"] == nil) {
            [self showAlert:@"Oops" message:@"Not able to submit a wine right now"];
            [[RavenClient sharedClient] captureMessage:@"Drink type nil when trying to create wine" level:kRavenLogLevelDebugError];
            return;
        }
        NSNumber *drinkId = [drinkType objectForKey:@"id"];
        
        if (name.length == 0) {
            name = varietal;
        }
        
        NSMutableDictionary *params = @{
                                 kDrinkModelParamName: name,
                                 kDrinkModelParamDrinkTypeId: drinkId,
                                 kDrinkModelParamVarietal: varietal
                                 }.mutableCopy;
        
        // Makes sure the selected drink spot is selected and that the selected drink spot is equal to the text field
        if (_selectedDrinkSpot != nil && [_selectedDrinkSpot.name isEqualToString:wineryName]) {
            [params setObject:_selectedDrinkSpot.ID forKey:kDrinkModelParamSpotId];
            
            [self createDrink:params];
        } else if (wineryName.length > 0) {
            
            [self showHUD:@"Creating winery"];
            [SpotModel postSpot:@{
                                  kSpotModelParamName : wineryName,
                                  } success:^(SpotModel *spotModel, JSONAPI *jsonApi) {
                                      [self hideHUD];
                                      
                                      // Set created spot id
                                      [params setObject:spotModel.ID forKey:kDrinkModelParamSpotId];
                                      
                                      // Send request to create drink
                                      [self createDrink:params];
                                      
                                  } failure:^(ErrorModel *errorModel) {
                                      [self hideHUD];
                                      [self showAlert:@"Oops" message:errorModel.human];
                                  }];
            
        } else {
            // Send request to create drink
            [self createDrink:params];
        }
    }
    
}

#pragma mark - Private - API Create

- (void)createSpot:(NSDictionary*)params  {
    
    [self showHUD:@"Creating spot"];
    [SpotModel postSpot:params success:^(SpotModel *spotModel, JSONAPI *jsonApi) {
        [self hideHUD];
        [self createReview:spotModel drink:nil];
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Error creating spot" message:errorModel.human];
    }];
    
}

- (void)createDrink:(NSDictionary*)params  {
    
    [self showHUD:@"Creating drink"];
    [DrinkModel postDrink:params success:^(DrinkModel *drinkModel, JSONAPI *jsonAPI) {
        [self hideHUD];
        [self createReview:nil drink:drinkModel];
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Error creating drink" message:errorModel.human];
    }];
    
}

- (void)createReview:(SpotModel*)spot drink:(DrinkModel*)drink {
    ReviewModel *review = [[ReviewModel alloc] init];
    [review setDrink:drink];
    [review setSpot:spot];
    if (spot != nil) {
        [review setRating:@0];
    } else {
        [review setRating:_reviewRatingSlider.value];
    }
    
    NSMutableArray *sliders = [NSMutableArray array];
    [sliders addObjectsFromArray:_sliders];
    [sliders addObjectsFromArray:_advancedSliders];
    
    [review setSliders:sliders];
    
    [self showHUD:@"Submitting review"];
    [review postReviews:^(ReviewModel *reviewModel, JSONAPI *jsonApi) {
        
        [self hideHUD];
        [self showHUDCompleted:@"Saved!" block:^{

            // Searches in stack for ReviewsMenuViewController to pop to
            UIViewController *reviewsMenuViewController;
            for (UIViewController *viewController in self.navigationController.viewControllers) {
                if ([viewController isKindOfClass:[ReviewsMenuViewController class]] == YES) {
                    reviewsMenuViewController = viewController;
                    break;
                }
            }
            
            // Pops back to last view controller if not found
            if (reviewsMenuViewController != nil) {
                [self.navigationController popToViewController:reviewsMenuViewController animated:YES];
            } else {
                
                if ([_delegate respondsToSelector:@selector(newReviewViewController:submittedReview:)]) {
                    [_delegate newReviewViewController:self submittedReview:reviewModel];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
            }
        }];
        
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

#pragma mark - Private

- (void)fetchFormData {
    
    // Shows progress hud
    [self showHUD:@"Loading forms"];
    
    // Gets spot form data
    Promise *promiseSpotForm = [SpotModel getSpots:@{kSpotModelParamsPageSize:@0} success:^(NSArray *spotModels, JSONAPI *jsonApi) {
        
        NSDictionary *forms = [jsonApi objectForKey:@"form"];
        if (forms != nil) {
            
            NSArray *allSpotTypes = [forms objectForKey:@"spot_types"];
            
            _spotTypes = [allSpotTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"visible_to_users == YES"]];
            _brewerySpotTypes = [allSpotTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", kSpotTypeFilterBrewery]];
            _winerySpotTypes = [allSpotTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", kSpotTypeFilterWinery]];

        }
        
    } failure:^(ErrorModel *errorModel) {
        
    }];
    
    // Gets drink form data
    Promise *promiseDrinkForm = [DrinkModel getDrinks:@{kDrinkModelParamsPageSize:@0} success:^(NSArray *drinkModels, JSONAPI *jsonApi) {
        
        NSDictionary *forms = [jsonApi objectForKey:@"form"];
        if (forms != nil) {
            _beerStyles = [[forms objectForKey:@"styles"] sortedArrayUsingSelector:@selector(compare:)];
            _wineVarietals = [[forms objectForKey:@"varietals"] sortedArrayUsingSelector:@selector(compare:)];
            
            _drinkTypes = [forms objectForKey:@"drink_types"];
            for (NSDictionary *drinkType in _drinkTypes) {
                if ([[[drinkType objectForKey:@"name"] lowercaseString] isEqualToString:@"cocktail"] == YES) {
                    _cocktailTypes = [drinkType objectForKey:@"drink_subtypes"];
                }
            }
        }
        
    } failure:^(ErrorModel *errorModel) {
        
    }];
    
    // Gets drink form data
    Promise *promiseBaseAlcohols = [BaseAlcoholModel getBaseAlcohols:nil success:^(NSArray *baseAlcoholModels, JSONAPI *jsonAPI) {
        _cocktailBaseAlcohols = [baseAlcoholModels sortedArrayUsingComparator:^NSComparisonResult(BaseAlcoholModel *obj1, BaseAlcoholModel *obj2) {
            return [obj1.name caseInsensitiveCompare:obj2.name];
        }];
    } failure:^(ErrorModel *errorModel) {
        
    }];
    
    // Waits for both spots and drinks to finish
    [When when:@[promiseSpotForm, promiseDrinkForm, promiseBaseAlcohols] then:^{

    } fail:^(id error) {
        [self hideHUD];
        [self showAlert:@"Oops" message:@"Looks like there was an error loading forms. Please try again later" block:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } always:^{
        [self hideHUD];
        
        // Fetch the slider tempaltes for drinks
        if (_selectedReviewType > kSpotReviewType) {
            [self fetchSliderTemplates:_selectedReviewType];
        }
        
    }];
}

- (void)fetchSliderTemplates:(NSInteger)section {
    
    // Gets sliders
    NSDictionary *params;
    if (section == 0) {
        NSNumber *spotTypeId = [_selectedSpotType objectForKey:@"id"];
        
        if (spotTypeId != nil) {
            params = @{
                       kSliderTemplateModelParamSpotTypeId: spotTypeId,
                       kSliderTemplateModelParamsPageSize: @100,
                       kSliderTemplateModelParamPage: @1
                       };
        }
    } else {
        NSDictionary *drinkType = [self getDrinkType:_selectedReviewType];
        NSNumber *drinkTypeId = [drinkType objectForKey:@"id"];
        
        if (drinkTypeId != nil) {
            params = @{
                       kSliderTemplateModelParamDrinkTypeId: drinkTypeId,
                       kSliderTemplateModelParamsPageSize: @100,
                       kSliderTemplateModelParamPage: @1
                       };
        }
    }
    
    if (params != nil) {
        [self showHUD:@"Loading sliders"];
        [SliderTemplateModel getSliderTemplates:params success:^(NSArray *sliderTemplates, JSONAPI *jsonApi) {
            [self hideHUD];
            _sliderTemplates = sliderTemplates;
            
            // Creating sliders
            [_sliders removeAllObjects];
            for (SliderTemplateModel *sliderTemplate in _sliderTemplates) {
                SliderModel *slider = [[SliderModel alloc] init];
                [slider setSliderTemplate:sliderTemplate];
                [_sliders addObject:slider];
            }
            
            // Filling advanced sliders if nil
            if (_advancedSliders == nil) {
                _advancedSliders = [NSMutableArray array];
                
                // Moving advanced sliders into their own array
                for (SliderModel *slider in _sliders) {
                    if (slider.sliderTemplate.required == NO) {
                        [_advancedSliders addObject:slider];
                    }
                }
                
                // Removing advances sliders from basic array
                for (SliderModel *slider in _advancedSliders) {
                    [_sliders removeObject:slider];
                }
            }
            
            // Reloading table
            [_tblReviews reloadData];
            
        } failure:^(ErrorModel *errorModel) {
            [self hideHUD];
        }];
    }
}

- (NSDictionary*)getDrinkType:(NSInteger)section {
    for (NSDictionary *drinkType in _drinkTypes) {
        if (section == 1 && [[drinkType objectForKey:@"name"] isEqualToString:kDrinkTypeNameBeer]) {
            return drinkType;
        } else if (section == 2 && [[drinkType objectForKey:@"name"] isEqualToString:kDrinkTypeNameCocktail]) {
            return drinkType;
        } else if (section == 3 && [[drinkType objectForKey:@"name"] isEqualToString:kDrinkTypeNameWine]) {
            return drinkType;
        }
    }
    return nil;
}

- (SectionHeaderView *)instantiateSectionHeaderView {
    // load the VC and get the view (to allow for easily laying out the custom section header)
    if (!_commonStoryboard) {
        _commonStoryboard = [UIStoryboard storyboardWithName:@"Common" bundle:nil];
    }
    UIViewController *vc = [_commonStoryboard instantiateViewControllerWithIdentifier:@"SectionHeaderScene"];
    SectionHeaderView *sectionHeaderView = (SectionHeaderView *)[vc.view viewWithTag:100];
    [sectionHeaderView removeFromSuperview];
    [sectionHeaderView prepareView];
    
    return sectionHeaderView;
}

- (SectionHeaderView*)sectionHeaderViewForSection:(NSInteger)section {
    if (section == 0) {
        if (_sectionHeaderReviewType == nil) {
            _sectionHeaderReviewType = [self instantiateSectionHeaderView];
            [_sectionHeaderReviewType setBackgroundColor:[UIColor whiteColor]];
            NSString *text = [kReviewTypes objectAtIndex:_selectedReviewType];
            [_sectionHeaderReviewType setText:text];
            [_sectionHeaderReviewType setSelected:YES];
        }
        
        return _sectionHeaderReviewType;
    }
    return nil;
}

- (void)updateViewHeader:(NSInteger)section {
    if (section == 0) {
        [_sectionHeaderReviewType setIconImage:[UIImage imageNamed:[kReviewTypeIcons objectAtIndex:_selectedReviewType]]];
        [_sectionHeaderReviewType setText:[kReviewTypes objectAtIndex:_selectedReviewType]];
    }
}

- (UIView*)formForReviewTypeIndex:(NSInteger)index {
    
    // Determins which form to use
    if (index == 0) {
        if (_viewFormNewSpot == nil) {
            _viewFormNewSpot = [UIView viewFromNibNamed:@"NewReviewSpotView" withOwner:self];
            
            if (_spotBasedOffOf != nil) {
                [_txtSpotName setText:_spotBasedOffOf.name];
                [_txtSpotAddress setText:_spotBasedOffOf.address];
                [_txtSpotCity setText:_spotBasedOffOf.city];
                [_txtSpotState setText:_spotBasedOffOf.state];
            }
            
            // Sets spot type picker view
            _pickerViewSpotType = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 216)];
            [_pickerViewSpotType setBackgroundColor:[UIColor whiteColor]];
            [_pickerViewSpotType setDataSource:self];
            [_pickerViewSpotType setDelegate:self];
            
            //Configure picker...
            [_txtSpotType setInputView:_pickerViewSpotType];
            [_txtSpotType setInputAccessoryView:[self keyboardToolBarForSpotType]];
            
            // Sets state picker view
            _pickerViewState = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 216)];
            [_pickerViewState setBackgroundColor:[UIColor whiteColor]];
            [_pickerViewState setDataSource:self];
            [_pickerViewState setDelegate:self];
            
            //Configure picker...
            [_txtSpotState setInputView:_pickerViewState];
            [_txtSpotState setInputAccessoryView:[self keyboardToolBarForState]];
        }

        return _viewFormNewSpot;
    }
    else if (index == 1) {
        if (_viewFormNewBeer == nil) {
            _viewFormNewBeer = [UIView viewFromNibNamed:@"NewReviewBeerView" withOwner:self];
            
            // Sets autocomplete
            [_txtBeerStyle setAutocompleteWithDataSource:self delegate:self];
            [_txtBeerStyle registerAutoCompleteCell:[UINib nibWithNibName:@"AutoCompleteCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AutoCompleteCellView"];
            [_txtBeerStyle showAutoCompleteTableAlways:YES];
            
            // Sets autocomplete
            [_txtBeerBreweryName setAutocompleteWithDataSource:self delegate:self];
            [_txtBeerBreweryName registerAutoCompleteCell:[UINib nibWithNibName:@"AutoCompleteCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AutoCompleteCellView"];
        }

        return _viewFormNewBeer;
    }
    else if (index == 2) {
        if (_viewFormNewCocktail == nil) {
            _viewFormNewCocktail = [UIView viewFromNibNamed:@"NewReviewCocktailView" withOwner:self];
        }
        
        // Sets cocktail type picker view
        _pickerViewCocktailType = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 216)];
        [_pickerViewCocktailType setBackgroundColor:[UIColor whiteColor]];
        [_pickerViewCocktailType setDataSource:self];
        [_pickerViewCocktailType setDelegate:self];
        
        // Configure picker...
        [_txtCocktailType setInputView:_pickerViewCocktailType];
        [_txtCocktailType setInputAccessoryView:[self keyboardToolBarForCocktailType]];
        
        // Sets cocktail alcohol type picker view
        _pickerViewCocktailBaseAlcoholType = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 216)];
        [_pickerViewCocktailBaseAlcoholType setBackgroundColor:[UIColor whiteColor]];
        [_pickerViewCocktailBaseAlcoholType setDataSource:self];
        [_pickerViewCocktailBaseAlcoholType setDelegate:self];
        
        // Configure picker...
        [_txtCocktailAlcoholType setInputView:_pickerViewCocktailBaseAlcoholType];
        [_txtCocktailAlcoholType setInputAccessoryView:[self keyboardToolBarForCocktailAlcoholType]];
        
        return _viewFormNewCocktail;
    }
    else if (index == 3) {
        if (_viewFormNewWine == nil) {
            _viewFormNewWine = [UIView viewFromNibNamed:@"NewReviewWineView" withOwner:self];
            
            // Sets autocomplete
            [_txtWineStyle setAutocompleteWithDataSource:self delegate:self];
            [_txtWineStyle registerAutoCompleteCell:[UINib nibWithNibName:@"AutoCompleteCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AutoCompleteCellView"];
            
            // Sets autocomplete
            [_txtWineWineryName setAutocompleteWithDataSource:self delegate:self];
            [_txtWineWineryName registerAutoCompleteCell:[UINib nibWithNibName:@"AutoCompleteCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AutoCompleteCellView"];
        }
        
        return _viewFormNewWine;
    }
    
    return nil;
}

- (UIToolbar *)keyboardToolBarForSpotType {
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar sizeToFit];
    
    [self.segControlForSpotType setEnabled:NO forSegmentAtIndex:0];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onClickChooseSpotType:)];
    
    NSArray *itemsArray = @[flex, nextButton];
    
    [toolbar setItems:itemsArray];
    
    return toolbar;
}

- (UIToolbar *)keyboardToolBarForState {
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar sizeToFit];
    
    [self.segControlForSpotType setEnabled:NO forSegmentAtIndex:0];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onClickChooseState:)];
    
    NSArray *itemsArray = @[flex, nextButton];
    
    [toolbar setItems:itemsArray];
    
    return toolbar;
}

- (UIToolbar *)keyboardToolBarForCocktailType {
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar sizeToFit];
    
    [self.segControlForCocktailType setEnabled:NO forSegmentAtIndex:0];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onClickChooseCocktailType:)];
    
    NSArray *itemsArray = @[flex, nextButton];
    
    [toolbar setItems:itemsArray];
    
    return toolbar;
}

- (UIToolbar *)keyboardToolBarForCocktailAlcoholType {
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar sizeToFit];
    
    [self.segControlForCocktailAlcoholType setEnabled:NO forSegmentAtIndex:0];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onClickChooseCocktailAlcoholType:)];
    
    NSArray *itemsArray = @[flex, nextButton];
    
    [toolbar setItems:itemsArray];
    
    return toolbar;
}

@end
