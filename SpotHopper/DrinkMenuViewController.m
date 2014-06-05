//
//  DrinkMenuViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/14/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "DrinkMenuViewController.h"

#import "SectionHeaderView.h"

#import "UIViewController+Navigator.h"

#import "MenuItemSubtypeCell.h"

#import "ErrorModel.h"
#import "DrinkModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubtypeModel.h"
#import "MenuItemModel.h"
#import "MenuTypeModel.h"
#import "Tracker.h"

#import "JHAccordion.h"

@interface DrinkMenuViewController ()<UITableViewDataSource, UITableViewDelegate, JHAccordionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblMenu;

@property (nonatomic, strong) NSArray *drinkTypes;
@property (nonatomic, strong) NSDictionary *menuTypes;
@property (nonatomic, strong) NSMutableDictionary *drinkSubtypes;
@property (nonatomic, strong) NSArray *menuItems;

@property (nonatomic, strong) NSArray *drinkTypesUpdate;

@property (nonatomic, strong) JHAccordion *accordion;

@property (nonatomic, strong) SectionHeaderView *sectionHeaderBeer;
@property (nonatomic, strong) SectionHeaderView *sectionHeaderCocktails;
@property (nonatomic, strong) SectionHeaderView *sectionHeaderLiquor;
@property (nonatomic, strong) SectionHeaderView *sectionHeaderWine;

@property (nonatomic, strong) UIStoryboard *commonStoryboard;

@end

@implementation DrinkMenuViewController {
    BOOL _isUpdatingTableView;
}

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
    [self setTitle:@"Full Drink Menu"];
    
    // Shows sidebar button in nav
//    [self showSidebarButton:YES animated:YES];
    
    // Configures accordion
    _accordion = [[JHAccordion alloc] initWithTableView:_tblMenu];
    [_accordion setDelegate:self];
    
    // Configures table
    [_tblMenu setTableFooterView:[[UIView alloc] init]];
    
    // Adding table header
    UILabel *labelHeader = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblMenu.frame), 72.0f)];
    [labelHeader setBackgroundColor:[UIColor clearColor]];
    [labelHeader setFont:[UIFont fontWithName:@"Lato-Light" size:26.0f]];
    [labelHeader setTextColor:[UIColor darkGrayColor]];
    [labelHeader setMinimumScaleFactor:0.5];
    [labelHeader setTextAlignment:NSTextAlignmentCenter];
    [labelHeader setText:_spot.name];
    [_tblMenu setTableHeaderView:labelHeader];
    
    // Initilalizes stuff
    _drinkSubtypes = [NSMutableDictionary dictionary];
    
    [self fetchMenuItems];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // Deselects cell
    [_tblMenu deselectRowAtIndexPath:[_tblMenu indexPathForSelectedRow] animated:NO];
    
    // Adds contextual footer view
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
        [footerViewController setRightButton:@"Info" image:[UIImage imageNamed:@"btn_context_info"]];
    }];
}

- (BOOL)footerViewController:(FooterViewController *)footerViewController clickedButton:(FooterViewButtonType)footerViewButtonType {
    if (FooterViewButtonRight == footerViewButtonType) {
        [self showAlert:@"Info" message:kInfoMenu];
        return YES;
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Drink Menu";
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _drinkTypes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DrinkTypeModel *drinkType = [_drinkTypes objectAtIndex:section];
    NSArray *drinkSubtypes =[_drinkSubtypes objectForKey:drinkType.ID];
    return drinkSubtypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get drink type for section
    DrinkTypeModel *drinkType = [_drinkTypes objectAtIndex:indexPath.section];
    if (drinkType != nil) {
        
        MenuTypeModel *menutType = [[_drinkSubtypes objectForKey:drinkType.ID] objectAtIndex:indexPath.row];
        
        MenuItemSubtypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemSubtypeCell" forIndexPath:indexPath];
        [cell.lblName setText:menutType.name];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DrinkTypeModel *drinkType = [_drinkTypes objectAtIndex:indexPath.section];
    MenuTypeModel *menuType = [[_drinkSubtypes objectForKey:drinkType.ID] objectAtIndex:indexPath.row];

    // Adds all selected drink subtypes to array
    NSArray *menuItemsToPassOn = [_menuItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"menuType.ID = %@", menuType.ID]];
    
    [self goToMenuOfferings:_spot drinkType:drinkType menuType:menuType menuItems:menuItemsToPassOn];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ( [_accordion isSectionOpened:indexPath.section] ? 44.0f : 0.0f);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DrinkTypeModel *drinkType = [_drinkTypes objectAtIndex:section];
    
    // Only shows header if there are drinks in this section
    if (drinkType != nil && [[_drinkSubtypes objectForKey:drinkType.ID] count] > 0) {
        return [self sectionHeaderViewForSection:section];
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DrinkTypeModel *drinkType = [_drinkTypes objectAtIndex:section];
    
    // Only shows header if there are drinks in this section
    if (drinkType != nil && [[_drinkSubtypes objectForKey:drinkType.ID] count] > 0) {
        return 65.0f;
    }
    
    return 0.0f;
}

#pragma mark - JHAccordionDelegate

- (void)accordion:(JHAccordion *)accordion openingSection:(NSInteger)section {
    SectionHeaderView *sectionHeader = [self sectionHeaderViewForSection:section];
    [sectionHeader setSelected:YES];
}

- (void)accordion:(JHAccordion *)accordion closingSection:(NSInteger)section {
    SectionHeaderView *sectionHeader = [self sectionHeaderViewForSection:section];
    [sectionHeader setSelected:NO];
}

- (void)accordion:(JHAccordion *)accordion openedSection:(NSInteger)section {
}

- (void)accordion:(JHAccordion *)accordion closedSection:(NSInteger)section {
    [_tblMenu reloadData];
}

- (void)accordion:(JHAccordion*)accordion willUpdateTableView:(UITableView *)tableView {
    _isUpdatingTableView = TRUE;
}

- (void)accordion:(JHAccordion*)accordion didUpdateTableView:(UITableView *)tableView {
    _isUpdatingTableView = FALSE;
//    [self updateFeaturedSpotlists];
//    [self updateMySpotlists];
}

#pragma mark - Private

- (void)fetchMenuItems {
    
    [self showHUD:@"Loading menu"];
    
    // Gets menu items
    Promise *promiseMenuItems = [_spot getMenuItems:@{ kMenuItemParamsInStock : @"true" } success:^(NSArray *menuItemModels, JSONAPI *jsonApi) {
        _menuItems = menuItemModels;
        _menuTypes = [[jsonApi linked] objectForKey:@"menu_types"];
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
    
    // Gets drink form data
    Promise *promiseDrinkForm = [DrinkModel getDrinks:@{kDrinkModelParamsPageSize:@0} success:^(NSArray *drinkModels, JSONAPI *jsonApi) {
        
        NSDictionary *forms = [jsonApi objectForKey:@"form"];
        if (forms != nil) {
            // Orders drink types
            _drinkTypesUpdate = [DrinkTypeModel jsonAPIResources:[forms objectForKey:@"drink_types"] withLinked:nil];
            _drinkTypesUpdate = [_drinkTypesUpdate sortedArrayUsingComparator:^NSComparisonResult(DrinkTypeModel *obj1, DrinkTypeModel *obj2) {
                return [obj1.name compare:obj2.name];
            }];
            [self updateDrinkTypes];
        }
        
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
    
    // Waits for both spots and drinks to finish
    [When when:@[promiseMenuItems, promiseDrinkForm] then:^{
        
        // Loops through all menu types to save off drink subtypes in dictionary
        for (NSNumber *menuTypeId in [_menuTypes allKeys]) {
            
            MenuTypeModel *menuType = [_menuTypes objectForKey:menuTypeId];

            // Creates new array for drink type if not created before
            NSMutableArray *menuTypesForDrinkType = [_drinkSubtypes objectForKey:menuType.drinkType.ID];
            if (menuTypesForDrinkType == nil) {
                menuTypesForDrinkType = [NSMutableArray array];
                [_drinkSubtypes setObject:menuTypesForDrinkType forKey:menuType.drinkType.ID];
            }
            
            // Adds menu type so we can display in table
            [menuTypesForDrinkType addObject:menuType];
        }
        
        [_tblMenu reloadData];
    } fail:^(id error) {
        [self hideHUD];
        [self showAlert:@"Oops" message:@"Looks like there was an error loading the menu. Please try again later" block:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } always:^{
        [self hideHUD];
    }];
    
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
    
    DrinkTypeModel *drinkType = [_drinkTypes objectAtIndex:section];
    
    if ([drinkType.name isEqualToString:kDrinkTypeNameBeer] == YES) {
        if (_sectionHeaderBeer == nil) {
            _sectionHeaderBeer = [self instantiateSectionHeaderView];
            [_sectionHeaderBeer setIconImage:[UIImage imageNamed:@"icon_beer"]];
            
            [_sectionHeaderBeer.lblText setText:drinkType.name];
            
            [_sectionHeaderBeer.btnBackground setTag:section];
            [_sectionHeaderBeer.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            [_sectionHeaderBeer setSelected:[_accordion isSectionOpened:section]];
        }
        
        return _sectionHeaderBeer;
    } else if ([drinkType.name isEqualToString:kDrinkTypeNameCocktail] == YES) {
        if (_sectionHeaderCocktails == nil) {
            _sectionHeaderCocktails = [self instantiateSectionHeaderView];
            [_sectionHeaderCocktails setIconImage:[UIImage imageNamed:@"icon_cocktails"]];
            
            [_sectionHeaderCocktails.lblText setText:drinkType.name];
            
            [_sectionHeaderCocktails.btnBackground setTag:section];
            [_sectionHeaderCocktails.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            [_sectionHeaderCocktails setSelected:[_accordion isSectionOpened:section]];
        }
        
        return _sectionHeaderCocktails;
    } else if ([drinkType.name isEqualToString:kDrinkTypeNameLiquor] == YES) {
        if (_sectionHeaderLiquor == nil) {
            _sectionHeaderLiquor = [self instantiateSectionHeaderView];
            [_sectionHeaderLiquor setIconImage:[UIImage imageNamed:@"icon_liquor"]];
            
            [_sectionHeaderLiquor.lblText setText:drinkType.name];
            
            [_sectionHeaderLiquor.btnBackground setTag:section];
            [_sectionHeaderLiquor.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            [_sectionHeaderLiquor setSelected:[_accordion isSectionOpened:section]];
        }
        
        return _sectionHeaderLiquor;
    } else if ([drinkType.name isEqualToString:kDrinkTypeNameWine] == YES) {
        if (_sectionHeaderWine == nil) {
            _sectionHeaderWine = [self instantiateSectionHeaderView];
            [_sectionHeaderWine setIconImage:[UIImage imageNamed:@"icon_wine"]];
            
            [_sectionHeaderWine.lblText setText:drinkType.name];
            
            [_sectionHeaderWine.btnBackground setTag:section];
            [_sectionHeaderWine.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            [_sectionHeaderWine setSelected:[_accordion isSectionOpened:section]];
        }
        
        return _sectionHeaderWine;

    }
    return nil;
}

- (void)updateDrinkTypes {
    if (!_isUpdatingTableView && _drinkTypesUpdate) {
        _drinkTypes = _drinkTypesUpdate;
        _drinkTypesUpdate = nil;
        [_tblMenu reloadData];
    }
    else if (_isUpdatingTableView && _drinkTypesUpdate) {
        // update later when the table may be done updating
        [self performSelector:@selector(updateDrinkTypes) withObject:nil afterDelay:0.25];
    }
}

@end
