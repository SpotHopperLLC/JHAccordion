//
//  SHMenuAdminSearchViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 4/1/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>

#import "SHMenuAdminSearchViewController.h"
#import "SHMenuAdminAddNewBeerViewController.h"
#import "SHMenuAdminAddNewWineViewController.h"
#import "SHMenuAdminAddNewCocktailViewController.h"

#import "NSNumber+Helpers.h"
#import "UIView+AutoLayout.h"

#import "UserModel.h"
#import "DrinkModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubtypeModel.h"
#import "MenuItemModel.h"
#import "SpotModel.h"
#import "BaseAlcoholModel.h"
#import "ErrorModel.h"

#import "Tracker.h"

#import "SHMenuAdminDrinkTableViewCell.h"
#import "SHMenuAdminSpotTableViewCell.h"

#import "SHMenuAdminNetworkManager.h"
#import "ImageUtil.h"
#import "ClientSessionManager.h"

#import "SHMenuAdminStyleSupport.h"

#define kDrinkModelParamManufacturer @"manufacturer_id"
#define kPageSize @15

#define kMaxAddressWidth 200.0f

@interface SHMenuAdminSearchViewController () <SHMenuAdminAddNewBeerDelegate, SHMenuAdminAddNewWineDelegate, SHMenuAdminAddNewCocktailDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableviewBottomConstraint;
@property (assign, nonatomic) CGFloat startingTableviewBottomConstraint;

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;

@property (strong, nonatomic) NSTimer *searchTimer;

@property (strong, nonatomic) NSNumber *page;
@property (strong, nonatomic) NSArray *results;

@end

@implementation SHMenuAdminSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register pull to refresh
    [self registerRefreshTableView:_tableView withReloadType:kPullRefreshTypeBoth];
    
    [self styleView];
    
    self.startingTableviewBottomConstraint = self.tableviewBottomConstraint.constant;
    
    if (self.isHouseCocktail && !self.spot) {
        NSAssert(self.spot, @"spot must be defined if searching for house cocktails");
    }
    
    if ([self.drinkType isWine] && !self.menuType) {
        NSAssert(self.menuType, @"menu type must be defined if searching wines");
    }
    
    if (self.isSpotSearch) {
        self.searchTextField.placeholder = @"Search for spot named...";
    }
    
//    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
//        DebugLog(@"iOS 8.x+");
//        
//        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
//        UIVibrancyEffect *effect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
//        UIVisualEffectView *veView = [[UIVisualEffectView alloc] initWithEffect:effect];
//        veView.translatesAutoresizingMaskIntoConstraints = NO;
//        [self.view insertSubview:veView belowSubview:self.tableView];
//        [veView pinEdges:JRTViewPinAllEdges toSameEdgesOfView:self.tableView];
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //hide navbar
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [self.searchTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DebugLog(@"segue: %@", segue.identifier);
    
    if ([@"SearchToNewBeer" isEqualToString:segue.identifier]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nc = (UINavigationController *)segue.destinationViewController;
            if ([nc.topViewController isKindOfClass:[SHMenuAdminAddNewBeerViewController class]]) {
                SHMenuAdminAddNewBeerViewController *vc = (SHMenuAdminAddNewBeerViewController *)nc.topViewController;
                vc.delegate = self;
            }
        }
    }
    else if ([@"SearchToNewWine" isEqualToString:segue.identifier]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nc = (UINavigationController *)segue.destinationViewController;
            if ([nc.topViewController isKindOfClass:[SHMenuAdminAddNewWineViewController class]]) {
                SHMenuAdminAddNewWineViewController *vc = (SHMenuAdminAddNewWineViewController *)nc.topViewController;
                vc.delegate = self;
            }
        }
    }
    else if ([@"SearchToNewCocktail" isEqualToString:segue.identifier]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nc = (UINavigationController *)segue.destinationViewController;
            if ([nc.topViewController isKindOfClass:[SHMenuAdminAddNewCocktailViewController class]]) {
                SHMenuAdminAddNewCocktailViewController *vc = (SHMenuAdminAddNewCocktailViewController *)nc.topViewController;
                vc.spot = self.spot;
                vc.drinkType = self.drinkType;
                vc.drinkSubType = self.drinkSubType;
                vc.delegate = self;
            }
        }
    }

}

#pragma mark - Base Overrides
#pragma mark -

- (UIScrollView *)mainScrollView {
    return self.tableView;
}

#pragma mark - Keyboard Support
#pragma mark -

- (BOOL)keyboardWillShowWithHeight:(CGFloat)height duration:(CGFloat)duration animationOptions:(UIViewAnimationOptions)animationOptions {
    [self adjustForKeyboardHeight:height];
    return [super keyboardWillShowWithHeight:height duration:duration animationOptions:animationOptions];
}

- (BOOL)keyboardWillHideWithHeight:(CGFloat)height duration:(CGFloat)duration animationOptions:(UIViewAnimationOptions)animationOptions {
    [self adjustForKeyboardHeight:0];
    return [super keyboardWillHideWithHeight:height duration:duration animationOptions:animationOptions];
}

#pragma mark - Tracking
#pragma mark -

- (NSString *)screenName {
    return @"Search";
}

#pragma mark - Rendering Cells
#pragma mark -

- (void)renderCell:(UITableViewCell *)cell withItem:(id)item {
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *subtitle1Label = (UILabel *)[cell viewWithTag:3];
    UILabel *subtitle2Label = (UILabel *)[cell viewWithTag:4];
    
    if ([item isKindOfClass:[SpotModel class]]) {
        SpotModel *spot = (SpotModel *)item;
        [ImageUtil loadThumbnailImage:spot.highlightImage imageView:imageView placeholderImage:spot.placeholderImage];
        titleLabel.text = spot.name;
    }
    else if ([item isKindOfClass:[DrinkModel class]]) {
        DrinkModel *drink = (DrinkModel *)item;
        [ImageUtil loadThumbnailImage:drink.highlightImage imageView:imageView placeholderImage:drink.placeholderImage];
        
        titleLabel.text = drink.name;
        subtitle1Label.text = drink.spot.name.length ? drink.spot.name : nil;
        
        if (drink.isBeer) {
            subtitle2Label.text = drink.style;
        }
        else if (drink.isWine) {
            subtitle2Label.text = [drink.vintage stringValue];
        }
        else if (drink.isCocktail) {
            BaseAlcoholModel *baseAlcohol = [drink.baseAlochols firstObject];
            subtitle2Label.text = baseAlcohol.name.length ? baseAlcohol.name : nil;
        }
    }

}

#pragma mark - SHMenuAdminAddNewBeerDelegate
#pragma mark -

- (void)addNewBeerViewControllerDidCancel:(SHMenuAdminAddNewBeerViewController *)vc {
    [self.presentedViewController dismissViewControllerAnimated:TRUE completion:^{
        DebugLog(@"Done");
    }];
}

- (void)addNewBeerViewController:(SHMenuAdminAddNewBeerViewController *)vc didCreateDrink:(DrinkModel *)drink {
    [vc.presentingViewController dismissViewControllerAnimated:TRUE completion:^{
        if ([self.delegate respondsToSelector:@selector(searchViewController:selectedDrink:)]) {
            [self.delegate searchViewController:self selectedDrink:drink];
        }
    }];
}

#pragma mark - SHMenuAdminAddNewWineDelegate
#pragma mark -

- (void)addNewWineViewControllerDidCancel:(SHMenuAdminAddNewWineViewController *)vc {
    [self.presentedViewController dismissViewControllerAnimated:TRUE completion:^{
        DebugLog(@"Done");
    }];
}

- (void)addNewWineViewController:(SHMenuAdminAddNewWineViewController *)vc didCreateDrink:(DrinkModel *)drink {
    [vc.presentingViewController dismissViewControllerAnimated:TRUE completion:^{
        if ([self.delegate respondsToSelector:@selector(searchViewController:selectedDrink:)]) {
            [self.delegate searchViewController:self selectedDrink:drink];
        }
    }];
}

#pragma mark - SHMenuAdminAddNewCocktailDelegate
#pragma mark -

- (void)addNewCocktailViewControllerDidCancel:(SHMenuAdminAddNewCocktailViewController *)vc {
    [self.presentedViewController dismissViewControllerAnimated:TRUE completion:^{
        DebugLog(@"Done");
    }];
}

- (void)addNewCocktailViewController:(SHMenuAdminAddNewCocktailViewController *)vc didCreateDrink:(DrinkModel *)drink {
    [vc.presentingViewController dismissViewControllerAnimated:TRUE completion:^{
        if ([self.delegate respondsToSelector:@selector(searchViewController:selectedDrink:)]) {
            [self.delegate searchViewController:self selectedDrink:drink];
        }
    }];
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.results) {
        return self.results.count + 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.results.count) {
        id item = self.results[indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell" forIndexPath:indexPath];
        [self renderCell:cell withItem:item];
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewDrinkCell" forIndexPath:indexPath];
        return cell;
    }
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
    
    if (indexPath.row < self.results.count) {
        id item = [self.results objectAtIndex:indexPath.row];
        if ([item isKindOfClass:[SpotModel class]]) {
            SpotModel *spot = (SpotModel *)item;
            
            if ([self.delegate respondsToSelector:@selector(searchViewController:selectedSpot:)]) {
                //delegate to the homeviewcontroller to
                //1. fetch menu items w/ new spot's id
                //2. display menu items
                [self.delegate searchViewController:self selectedSpot:spot];
            }
        }
        else if ([item isKindOfClass:[DrinkModel class]]) {
            DrinkModel *drink = (DrinkModel *)item;
            
            for (MenuItemModel *menuItem in self.filteredMenuItems) {
                if ([menuItem.drink isEqual:drink]) {
                    //display
                    [self showAlert:[NSString stringWithFormat:@"Duplicate %@", self.drinkType] message:[NSString stringWithFormat:@"%@ is already a part of your %@ selection.", menuItem.drink.name, self.menuType]];
                    
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    
                    return;
                }
            }
            
            //delegate to the homeviewcontroller to add a new cell with the DrinkModel info
            if ([self.delegate respondsToSelector:@selector(searchViewController:selectedDrink:)]) {
                [self.delegate searchViewController:self selectedDrink:drink];
            }
        }
    }
    else {
        [self startCreatingNewDrink];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 68.0f;

    if (self.isSpotSearch) {
//        SpotModel *spot = [self.results objectAtIndex:indexPath.row];
//       
//        if (spot.addressCityState) {
//             height += [self heightForString:spot.addressCityState font:[UIFont fontWithName:@"Lato-Italic" size:14.0f] maxWidth:kMaxAddressWidth];
//        }
//        else {
//            height = 85.0f;
//        }
        
        height = 80.0f;
    }
    
    return height;
}

#pragma mark - JHPullToRefresh
#pragma mark -

- (void)reloadTableViewDataPullDown {
    // Starts search over
    [self runSearch];
}

- (void)reloadTableViewDataPullUp {
    // Increments pages
    self.page = [self.page increment];
    
    // Does search
    [self doSearch];
}

#pragma mark - UITextFieldDelegate
#pragma mark -

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self performSelector:@selector(runSearch) withObject:nil afterDelay:0.25];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self performSelector:@selector(runSearch) withObject:nil afterDelay:0.25];
    
    return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private
#pragma mark -

- (void)runSearch {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(runSearch) object:nil];
    
    // Resets pages and clears results
    self.page = @1;
        
    if (self.searchTextField.text.length) {
        [self doSearch];
    }
    else {
        [self dataDidFinishRefreshing];
    }
}

- (void)doSearch {
    if (self.isSpotSearch) {
        UserModel *user = [ClientSessionManager sharedClient].currentUser;

        //search spots
        [self startSearching];
        [UserModel fetchSpotsForUser:user query:self.searchTextField.text page:@1 pageSize:kPageSize success:^(NSArray *spots) {
            self.results = spots;
            
            [self sortResultsAfterFetch];
            [self dataDidFinishRefreshing];
            [self stopSearching];
        } failure:^(ErrorModel *errorModel) {
            [self stopSearching];
            [self showAlert:@"Network error" message:@"Please try again"];
            CLS_LOG(@"network error searching for spots. Error: %@", errorModel.humanValidations);
        }];
    }
    else {
        //search drinks
        [self startSearching];
        
        SpotModel * spot = self.isHouseCocktail ? self.spot : nil;
        [DrinkModel fetchDrinksForDrinkType:self.drinkType drinkSubType:self.drinkSubType query:self.searchTextField.text page:self.page pageSize:kPageSize spot:spot success:^(NSArray *drinks) {
            
            NSMutableArray *filteredDrinks = @[].mutableCopy;
            
            //if a wine, only show wines with the correct drink type
            if ([self.drinkType isWine]) {
                for (DrinkModel *drink in drinks) {
                    if ([drink.drinkSubtype.name isEqualToString:self.menuType]) {
                        [filteredDrinks addObject:drink];
                    }
                }
            }
            else {
                // Adds drinks to results
                [filteredDrinks addObjectsFromArray:drinks];
            }
            
            self.results = filteredDrinks;
            
            [self sortResultsAfterFetch];
            [self dataDidFinishRefreshing];
            [self stopSearching];
        } failure:^(ErrorModel *errorModel) {
            [self stopSearching];
            [self showAlert:@"Network error" message:@"Please try again"];
            CLS_LOG(@"network error searching for drinks. Error: %@", errorModel.humanValidations);
        }];
    }
}

- (void)startSearching {
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    activityIndicatorView.hidesWhenStopped = TRUE;
    activityIndicatorView.tag = 100;
    
    CGRect frame = activityIndicatorView.frame;
    frame.size.width += 5.0f;
    UIView *containerView = [[UIView alloc] initWithFrame:frame];
    [containerView addSubview:activityIndicatorView];
    
    self.searchTextField.rightView = containerView;
    self.searchTextField.rightViewMode = UITextFieldViewModeAlways;
    [activityIndicatorView startAnimating];
}

- (void)stopSearching {
    UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)[self.searchTextField.rightView viewWithTag:100];
    [activityIndicatorView stopAnimating];
    self.searchTextField.rightView = nil;
    self.searchTextField.rightViewMode = UITextFieldViewModeNever;
}

- (void)sortResultsAfterFetch {
    NSMutableArray *sorted = self.results.mutableCopy;
    [sorted sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *revObj1 = [obj1 valueForKey:@"relevance"];
        NSNumber *revObj2 = [obj2 valueForKey:@"relevance"];
        return [revObj2 compare:revObj1];
    }];
    self.results = sorted;
}

- (void)startCreatingNewDrink {
    if ([self.drinkType isBeer]) {
        [self performSegueWithIdentifier:@"SearchToNewBeer" sender:self];
    }
    else if ([self.drinkType isWine]) {
        [self performSegueWithIdentifier:@"SearchToNewWine" sender:self];
    }
    else if ([self.drinkType isCocktail]) {
        [self performSegueWithIdentifier:@"SearchToNewCocktail" sender:self];
    }
}

#pragma mark - Styling
#pragma mark -

- (void)styleView {
    self.headerView.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].LIGHT_ORANGE;
    
    self.searchTextField.placeholder = [NSString stringWithFormat:@"Find %@ named...", [self.drinkType.name lowercaseString]];
    self.searchTextField.font = [UIFont fontWithName:@"Lato-Regular" size:14.0f];
    self.searchTextField.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].DARK_ORANGE;
    self.searchTextField.textColor = [UIColor whiteColor];
    
    self.searchLabel.font = [UIFont fontWithName:@"Lato-Regular" size:20.0f];
}

@end
