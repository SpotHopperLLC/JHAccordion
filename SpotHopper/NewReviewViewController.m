//
//  NewReviewViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/8/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define kReviewTypes @[@"Spot", @"Beer", @"Cocktail", @"Wine"]
#define kReviewTypeIcons @[@"btn_sidebar_icon_spots", @"icon_beer", @"icon_cocktails", @"icon_wine"]

#import "MyReviewsViewController.h"

#import "CLGeocoder+DoubleLookup.h"
#import "NSString+Common.h"
#import "UIView+ViewFromNib.h"
#import "UIViewController+Navigator.h"

#import "SectionHeaderView.h"
#import "DropdownOptionCell.h"
#import "ReviewSliderCell.h"

#import "ErrorModel.h"

#import "ACEAutocompleteBar.h"
#import <JHAccordion/JHAccordion.h>

#import "NewReviewViewController.h"

@interface NewReviewViewController ()<UITableViewDataSource, UITableViewDelegate, JHAccordionDelegate, ACEAutocompleteDataSource, ACEAutocompleteDelegate, ReviewSliderCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblReviewTypes;
@property (weak, nonatomic) IBOutlet UITableView *tblReviews;

@property (nonatomic, assign) CGRect tblReviewsInitalFrame;

@property (nonatomic, strong) JHAccordion *accordion;
@property (nonatomic, strong) SectionHeaderView *sectionHeaderReviewType;

@property (nonatomic, assign) NSInteger selectedReviewType;

@property (nonatomic, strong) NSArray *spotTypes;
@property (nonatomic, strong) NSArray *drinkTypes;
@property (nonatomic, strong) NSArray *beerStyles;
@property (nonatomic, strong) NSArray *wineVarietals;
@property (nonatomic, strong) NSArray *cocktailBaseAlcohols;

@property (nonatomic, strong) DrinkModel *createdDrink;
@property (nonatomic, strong) SpotModel *createdSpot;

@property (nonatomic, strong) NSArray *sliderTemplates;
@property (nonatomic, strong) NSMutableArray *sliders;

@property (nonatomic, strong) NSDictionary *selectedSpotType;
@property (nonatomic, strong) NSDictionary *selectedCocktailSubtype;

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
@property (weak, nonatomic) IBOutlet UITextField *txtCocktailAlcoholType;

@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

@end

@implementation NewReviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad:@[kDidLoadOptionsBlurredBackground,kDidLoadOptionsDontAdjustForIOS6]];
    
    // Sets title
    [self setTitle:@"New Reviews"];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Configures accordion
    _accordion = [[JHAccordion alloc] initWithTableView:_tblReviewTypes];
    [_accordion setDelegate:self];
    [_accordion openSection:0];
    
    // Configures table
    [_tblReviewTypes setTableFooterView:[[UIView alloc] init]];
    [_tblReviewTypes registerNib:[UINib nibWithNibName:@"DropdownOptionCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DropdownOptionCell"];
    [_tblReviews setTableFooterView:[[UIView alloc] init]];
    [_tblReviews registerNib:[UINib nibWithNibName:@"ReviewSliderCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ReviewSliderCell"];
    [_tblReviews setContentInset:UIEdgeInsetsMake(0, 0, 65.0f, 0)];
    
    // Initializes states
    _selectedReviewType = -1;
    _tblReviewsInitalFrame = CGRectZero;
    _sliders = [NSMutableArray array];
    
    [self fetchFormData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Deselects table row
    [_tblReviews deselectRowAtIndexPath:_tblReviews.indexPathForSelectedRow animated:NO];
    
    // Gets table frame
    if (CGRectEqualToRect(_tblReviewsInitalFrame, CGRectZero)) {
        _tblReviewsInitalFrame = _tblReviews.frame;
    }
    
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // Adds contextual footer view
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
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
    } completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tblReviewTypes) {
        if (section == 0) {
            return kReviewTypes.count;
        }
    } else if (tableView == _tblReviews) {
        if (section == 0) {
            return _sliderTemplates.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tblReviewTypes) {
        if (indexPath.section == 0) {
            NSString *text = [kReviewTypes objectAtIndex:indexPath.row];
            
            DropdownOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DropdownOptionCell" forIndexPath:indexPath];
            [cell.lblText setText:text];
            
            return cell;
        }
    } else if (tableView == _tblReviews) {
         if (indexPath.section == 0) {
            
            SliderTemplateModel *sliderTemplate = [_sliderTemplates objectAtIndex:indexPath.row];
            SliderModel *slider = nil;
            if (indexPath.row < _sliders.count) {
                slider = [_sliders objectAtIndex:indexPath.row];
            }
             
            ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
            [cell setDelegate:self];
            [cell setSliderTemplate:sliderTemplate withSlider:slider];
            
            return cell;
            
        }
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tblReviewTypes) {
        if (indexPath.section == 0) {
            _selectedReviewType = indexPath.row;
            
            [self updateViewHeader:indexPath.section];
            
            [_accordion closeSection:indexPath.section];
            [_tblReviews deselectRowAtIndexPath:indexPath animated:NO];
        }
    } else if (tableView == _tblReviews) {
        
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _tblReviewTypes) {
        if (section == 0) {
            return [self sectionHeaderViewForSection:section];
        }
    } else if (tableView == _tblReviews) {

    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _tblReviewTypes) {
        if (section == 0) {
            return 56.0f;
        }
    } else if (tableView == _tblReviews) {

    }
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // This sets all rows in the closed sections to a height of 0 (so they won't be shown)
    // and the opened section to a height of 44.0
    if (tableView == _tblReviewTypes) {
        if (indexPath.section == 0) {
            return ( [_accordion isSectionOpened:indexPath.section] ? 44.0f : 0.0f);
        }
    } else if (tableView == _tblReviews) {
        if (indexPath.section == 0) {
            if (_selectedReviewType >= 0) {
                return 77.0f;
            }
        }
    }
    
    return 0.0f;
}

#pragma mark - JHAccordionDelegate

- (void)accordionOpeningSection:(NSInteger)section {
    if (section == 0) [_sectionHeaderReviewType setSelected:YES];
    
    [UIView animateWithDuration:0.35f animations:^{
        [_tblReviews setAlpha:0.0f];
        [_btnSubmit setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [_tblReviews setHidden:YES];
        [_btnSubmit setHidden:YES];
        
        [self.view endEditing:YES];
    }];
}

- (void)accordionClosingSection:(NSInteger)section {
    if (section == 0) [_sectionHeaderReviewType setSelected:NO];
    
    [_tblReviews setTableHeaderView:[self formForReviewTypeIndex:_selectedReviewType]];
    [_tblReviews reloadData];
    
    [self fetchSliderTemplates:_selectedReviewType];
}

- (void)accordionOpenedSection:(NSInteger)section {
}

- (void)accordionClosedSection:(NSInteger)section {
    [_tblReviews setAlpha:0.0f];
    [_tblReviews setHidden:NO];
    [_btnSubmit setAlpha:0.0f];
    [_btnSubmit setHidden:NO];
    [UIView animateWithDuration:0.35f animations:^{
        [_tblReviews setAlpha:1.0f];
        [_btnSubmit setAlpha:1.0f];
    } completion:^(BOOL finished) {

    }];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Spot
    if (textField == _txtSpotName) { [_txtSpotType becomeFirstResponder];
    } else if (textField == _txtSpotType) { [_txtSpotAddress becomeFirstResponder];
    } else if (textField == _txtSpotAddress) { [_txtSpotCity becomeFirstResponder];
    } else if (textField == _txtSpotCity) { [_txtSpotState becomeFirstResponder];
    } else if (textField == _txtSpotState) { [_txtSpotState resignFirstResponder];}
    
    // Beer
    if (textField == _txtBeerName) { [_txtBeerBreweryName becomeFirstResponder];
    } else if (textField == _txtBeerBreweryName) { [_txtBeerStyle becomeFirstResponder];
    } else if (textField == _txtBeerStyle) { [_txtBeerStyle resignFirstResponder];}
    
    // Cocktail
    if (textField == _txtCocktailName) { [_txtCocktailAlcoholType becomeFirstResponder];
    } else if (textField == _txtCocktailAlcoholType) { [_txtCocktailAlcoholType resignFirstResponder];}
    
    // Wine
    if (textField == _txtWineStyle) { [_txtWineWineryName becomeFirstResponder];
    } else if (textField == _txtWineWineryName) { [_txtWineName becomeFirstResponder];
    } else if (textField == _txtWineName) { [_txtWineName resignFirstResponder];}
    
    return NO;
}

#pragma mark - Autocomplete Delegate

- (void)textField:(UITextField *)textField didSelectObject:(id)object inInputView:(ACEAutocompleteInputView *)inputView {
    if (textField == _txtSpotType) {
        _selectedSpotType = object;
        textField.text = [_selectedSpotType objectForKey:@"name"];

        [self fetchSliderTemplates:_selectedReviewType];
    } else if (_txtCocktailAlcoholType ) {
        _selectedCocktailSubtype = object;
        textField.text = [_selectedCocktailSubtype objectForKey:@"name"];
    } else if ([object isKindOfClass:[NSString class]] == YES) {
        textField.text = object;
    }
}

#pragma mark - Autocomplete Data Source

- (NSUInteger)minimumCharactersToTrigger:(ACEAutocompleteInputView *)inputView {
    return 0;
}

- (void)inputView:(ACEAutocompleteInputView *)inputView itemsFor:(NSString *)query result:(void (^)(NSArray *items))resultBlock; {
    
    if (resultBlock != nil) {
        // execute the filter on a background thread to demo the asynchronous capability
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            // execute the filter
            
            NSMutableArray *array;
            
            if (_txtSpotType.isFirstResponder) {
                array = [_spotTypes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", query]].mutableCopy;
            } else if (_txtBeerStyle.isFirstResponder){
                array = [_beerStyles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", query]].mutableCopy;
            } else if (_txtWineStyle.isFirstResponder) {
                array = [_wineVarietals filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", query]].mutableCopy;
            } else if (_txtCocktailAlcoholType.isFirstResponder) {
                array = [_cocktailBaseAlcohols filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", query]].mutableCopy;
            }
            
            // return the filtered array in the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(array);
            });
        });
    }
}

- (NSString *)inputView:(ACEAutocompleteInputView *)inputView stringForObject:(id)object atIndex:(NSUInteger)index {
    if (_txtSpotType.isFirstResponder) {
        return [object objectForKey:@"name"];
    } else if (_txtCocktailAlcoholType ) {
        return [object objectForKey:@"name"];
    }
    
    return object;
}

#pragma mark - ReviewSliderCellDelegate

- (void)reviewSliderCell:(ReviewSliderCell *)cell changedValue:(float)value {
    NSIndexPath *indexPath = [_tblReviews indexPathForCell:cell];
    
    SliderTemplateModel *sliderTemplate = [_sliderTemplates objectAtIndex:indexPath.row];
    SliderModel *slider = nil;
    if (indexPath.row < _sliders.count) {
        slider = [_sliders objectAtIndex:indexPath.row];
    } else {
        slider = [[SliderModel alloc] init];
        [slider setSliderTemplate:sliderTemplate];
        [_sliders addObject:slider];
    }
    [slider setValue:[NSNumber numberWithInt:ceil(value * 10)]];
}

#pragma mark - Actions

- (IBAction)onClickSubmit:(id)sender {
    
    // Spot
    if (_selectedReviewType == 0) {
        
        NSString *name = _txtSpotName.text;
        NSString *address = _txtSpotAddress.text;
        NSString *city = _txtSpotAddress.text;
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
        
        // Validating selected drink id exists
        if (_selectedSpotType == nil && [_selectedSpotType objectForKey:@"id"] != nil) {
            [[RavenClient sharedClient] captureMessage:@"Spot type nil when trying to create spo" level:kRavenLogLevelDebugError];
            return;
        }
        NSNumber *spotTypeId = [_selectedSpotType objectForKey:@"id"];
        
        // Looks up zip code from address, city, and state
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder doubleGeocodeAddressDictionary:@{ @"Address" : address, @"City" : city, @"State" : state } completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = placemarks.firstObject;
            if (error || placemark == nil) {
                [self showAlert:@"Oops" message:@"Could not get zip code based on address, city, and state"];
                return;
            }
            
            NSString *zipCode = placemark.postalCode;
                
            NSDictionary *params = @{
                                     kSpotModelParamName: name,
                                     kSpotModelParamAddress: address,
                                     kSpotModelParamCity: city,
                                     kSpotModelParamState: state,
                                     kSpotModelParamZip : zipCode,
                                     kSpotModelParamSpotTypeId: spotTypeId
                                     };
            
            // Send request to create spot
            [self createSpot:params];

        }];
    }
    // Beer
    else if (_selectedReviewType == 1) {
        
        NSString *name = _txtBeerName.text;
        // TOOD: Need to do something with brewery
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
        if (drinkType == nil && [drinkType objectForKey:@"id"] != nil) {
            [[RavenClient sharedClient] captureMessage:@"Drink type nil when trying to create beer" level:kRavenLogLevelDebugError];
            return;
        }
        NSNumber *drinkId = [drinkType objectForKey:@"id"];
        
        NSDictionary *params = @{
                                 kDrinkModelParamName: name,
                                 kDrinkModelParamStyle: style,
                                 kDrinkModelParamDrinkTypeId: drinkId
                                 };
        
        // Send request to create drink
        [self createDrink:params];
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
        if (drinkType == nil && [drinkType objectForKey:@"id"] != nil) {
            [[RavenClient sharedClient] captureMessage:@"Drink type nil when trying to create cocktail" level:kRavenLogLevelDebugError];
            return;
        }
        NSNumber *drinkId = [drinkType objectForKey:@"id"];
        
        // Validating selected drink subtype id exists
        if (_selectedCocktailSubtype == nil && [_selectedCocktailSubtype objectForKey:@"id"] != nil) {
            [[RavenClient sharedClient] captureMessage:@"Drink subtype nil when trying to create cocktail" level:kRavenLogLevelDebugError];
            return;
        }
        NSNumber *drinkSubtypeId = [_selectedCocktailSubtype objectForKey:@"id"];
        
        NSDictionary *params = @{
                                 kDrinkModelParamName: name,
                                 kDrinkModelParamDrinkTypeId: drinkId,
                                 kDrinkModelParamDrinkSubtypeId: drinkSubtypeId
                                 };
        
        // Send request to create drink
        [self createDrink:params];
    }
    // Wine
    else if (_selectedReviewType == 3) {
        NSString *varietal = _txtWineStyle.text;
        // TOOD: Need to do something with brewery
        NSString *name = _txtWineName.text;
        
        // Form text field validations
        if (varietal.length == 0) {
            [self showAlert:@"Oops" message:@"Varietal is required"];
            return;
        }
        
        // Validating selected drink id exists
        NSDictionary *drinkType = [self getDrinkType:_selectedReviewType];
        if (drinkType == nil && [drinkType objectForKey:@"id"] != nil) {
            [[RavenClient sharedClient] captureMessage:@"Drink type nil when trying to create wine" level:kRavenLogLevelDebugError];
            return;
        }
        NSNumber *drinkId = [drinkType objectForKey:@"id"];
        
        if (name.length == 0) {
            name = varietal;
        }
        
        NSDictionary *params = @{
                                 kDrinkModelParamName: name,
                                 kDrinkModelParamDrinkTypeId: drinkId,
                                 kDrinkModelParamVarietal: varietal
                                 };
        
        // Send request to create drink
        [self createDrink:params];
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
        [self showAlert:@"Error creating drink" message:errorModel.human];
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
    [review setRating:@5];
    [review setSliders:_sliders];
    
    [self showHUD:@"Submitting review"];
    [review postReviews:^(ReviewModel *reviewModel, JSONAPI *jsonApi) {
        
        [self hideHUD];
        [self showHUDCompleted:@"Saved!" block:^{
            [self.navigationController popViewControllerAnimated:YES];
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
            _spotTypes = [forms objectForKey:@"spot_types"];
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
                    _cocktailBaseAlcohols = [drinkType objectForKey:@"drink_subtypes"];
                }
            }
        }
        
    } failure:^(ErrorModel *errorModel) {
        
    }];
    
    // Waits for both spots and drinks to finish
    [When when:@[promiseSpotForm, promiseDrinkForm] then:^{

    } fail:^(id error) {
        [self hideHUD];
        [self showAlert:@"Oops" message:@"Looks like there was an error loading forms. Please try again later" block:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } always:^{
        [self hideHUD];
    }];
}

- (void)fetchSliderTemplates:(NSInteger)section {
    
    // Gets sliders
    NSDictionary *params;
    if (section == 0) {
        NSNumber *spotTypeId = [_selectedSpotType objectForKey:@"id"];
        
        if (spotTypeId != nil) {
            params = @{
                       kSliderTemplateModelParamSpotTypeId: spotTypeId
                       };
        }
    } else {
        NSDictionary *drinkType = [self getDrinkType:_selectedReviewType];
        NSNumber *drinkTypeId = [drinkType objectForKey:@"id"];
        
        if (drinkTypeId != nil) {
            params = @{
                       kSliderTemplateModelParamDrinkTypeId: drinkTypeId
                       };
        }
    }
    
    if (params != nil) {
        [self showHUD:@"Loading sliders"];
        [SliderTemplateModel getSliderTemplates:params success:^(NSArray *sliderTemplates, JSONAPI *jsonApi) {
            [self hideHUD];
            _sliderTemplates = sliderTemplates;
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


- (SectionHeaderView*)sectionHeaderViewForSection:(NSInteger)section {
    if (section == 0) {
        if (_sectionHeaderReviewType == nil) {
            _sectionHeaderReviewType = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblReviews.frame), 56.0f)];
            [_sectionHeaderReviewType setBackgroundColor:[UIColor whiteColor]];
            [_sectionHeaderReviewType setText:@"Select Review Type"];
            [_sectionHeaderReviewType setSelected:[_accordion isSectionOpened:section]];
            
            // Sets up for accordion
            [_sectionHeaderReviewType.btnBackground setTag:section];
            [_sectionHeaderReviewType.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            if (_selectedReviewType >= 0) {
                [self updateViewHeader:section];
            }
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
    
    // Single spot fo customize block for styling autocomplete
    void (^customize)(ACEAutocompleteInputView *inputView);
    customize = ^(ACEAutocompleteInputView *inputView) {
        
        // customize the view (optional)
        inputView.font = [UIFont systemFontOfSize:16];
        inputView.textColor = [UIColor blackColor];
        inputView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.8];
        
    };
    
    // Determins which form to use
    if (index == 0) {
        if (_viewFormNewSpot == nil) {
            _viewFormNewSpot = [UIView viewFromNibNamed:@"NewReviewSpotView" withOwner:self];
            
            // Sets autocomplete
            [_txtSpotType setAutocompleteWithDataSource:self delegate:self customize:customize];
        }

        return _viewFormNewSpot;
    } else if (index == 1) {
        if (_viewFormNewBeer == nil) {
            _viewFormNewBeer = [UIView viewFromNibNamed:@"NewReviewBeerView" withOwner:self];
            
            // Sets autocomplete
            [_txtBeerStyle setAutocompleteWithDataSource:self delegate:self customize:customize];
        }

        return _viewFormNewBeer;
    } else if (index == 2) {
        if (_viewFormNewCocktail == nil) {
            _viewFormNewCocktail = [UIView viewFromNibNamed:@"NewReviewCocktailView" withOwner:self];
            
            // Sets autocomplete
            [_txtCocktailAlcoholType setAutocompleteWithDataSource:self delegate:self customize:customize];
        }
        
        return _viewFormNewCocktail;
    } else if (index == 3) {
        if (_viewFormNewWine == nil) {
            _viewFormNewWine = [UIView viewFromNibNamed:@"NewReviewWineView" withOwner:self];
            
            // Sets autocomplete
            [_txtWineStyle setAutocompleteWithDataSource:self delegate:self customize:customize];
        }
        
        return _viewFormNewWine;
    }
    
    return nil;
}

@end
