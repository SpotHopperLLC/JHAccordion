//
//  DrinkListViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/13/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define ITEM_SIZE_WIDTH 180.0f
#define ITEM_SIZE_HEIGHT 247.0f
#define ITEM_SIZE_HEIGHT_4_INCH 300.0f
#define kMeterToMile 0.000621371f

#import "DrinkListViewController.h"

#import "UIAlertView+Block.h"
#import "UIView+ViewFromNib.h"
#import "UIViewController+Navigator.h"

#import "TellMeMyLocation.h"

#import "CardLayout.h"
#import "SHButtonLatoLightLocation.h"

#import "SHNavigationController.h"
#import "FindSimilarViewController.h"

#import "DrinkCardCollectionViewCell.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"

#import <CoreLocation/CoreLocation.h>

#import "Tracker.h"

@interface DrinkListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, SHButtonLatoLightLocationDelegate, DrinkCardCollectionViewCellDelegate, CheckinViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewPlaceholder;
@property (weak, nonatomic) IBOutlet UIView *viewLocation;
@property (weak, nonatomic) IBOutlet UIView *viewSpot;
@property (weak, nonatomic) IBOutlet UIButton *btnSpot;

@property (weak, nonatomic) IBOutlet UILabel *lblMatchPercent;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet SHButtonLatoLightLocation *btnLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;

@property (weak, nonatomic) IBOutlet UIView *viewEmpty;

@property (nonatomic, strong) CLLocation *selectedLocation;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) TellMeMyLocation *tellMeMyLocation;

@property (nonatomic, strong) NSMutableDictionary *menuItems;

@end

@implementation DrinkListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Sets title
    [self setTitle:_drinkList.name];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Collection view
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView setCollectionViewLayout:[[CardLayout alloc] initWithItemSize:CGSizeMake(ITEM_SIZE_WIDTH, (IS_FOUR_INCH ? ITEM_SIZE_HEIGHT_4_INCH : ITEM_SIZE_HEIGHT) )]];
    
    // Oh yeah
    if (_spotAt == nil) {
        _spotAt = [_drinkList spot];
    }
    
    // Current location
    _tellMeMyLocation = [[TellMeMyLocation alloc] init];
    [_tellMeMyLocation findMe:kCLLocationAccuracyThreeKilometers found:^(CLLocation *newLocation) {
        _currentLocation = newLocation;
    } failure:^(NSError *error) {
        
    }];
    
    // Locations
    if (_drinkList.featured == NO) {
        [_btnLocation setDelegate:self];
        [_btnLocation updateWithLastLocation];
    } else {
        [_lblLocation setHidden:YES];
        [_btnLocation setHidden:YES];
    }
    
    // Initialize stuff
    _menuItems = @{}.mutableCopy;
    
    // Fetches drinklist
    if (_drinkList.drinks != nil) {
        [_collectionView reloadData];
        [self updateView];
        [self updateMatchPercent];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // Adds contextual footer view
    __block DrinkListViewController *this = self;
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
        
        if (this.drinkList.featured == NO) {
            [footerViewController setMiddleButton:@"Delete" image:[UIImage imageNamed:@"btn_context_delete"]];
        }
        
        [footerViewController setRightButton:@"Info" image:[UIImage imageNamed:@"btn_context_info"]];
    }];
    
}

- (BOOL)footerViewController:(FooterViewController *)footerViewController clickedButton:(FooterViewButtonType)footerViewButtonType {
    if (FooterViewButtonMiddle == footerViewButtonType) {
        [self deleteDrinkList];
        return YES;
    } else if (FooterViewButtonRight == footerViewButtonType) {
        [self showAlert:@"Info" message:kInfoDrinklist];
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Drink List";
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _drinkList.drinks.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DrinkModel *drink = [_drinkList.drinks objectAtIndex:indexPath.row];
    MenuItemModel *menuItem = [_menuItems objectForKey:drink.ID];
    
    DrinkCardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SpotCardCollectionViewCell" forIndexPath:indexPath];
    [cell setDrink:drink menuItem:menuItem];
    [cell setDelegate:self];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DrinkModel *drink = [_drinkList.drinks objectAtIndex:indexPath.row];
    [self goToDrinkProfile:drink];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateMatchPercent];
}

#pragma mark - DrinkCardCollectionViewCellDelegate

- (void)drinkCardCollectionViewCellClickedFindIt:(DrinkCardCollectionViewCell *)cell {
    NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
    DrinkModel *drink = [_drinkList.drinks objectAtIndex:indexPath.row];
    
    [self goToFindDrinksAt:drink];
}

#pragma mark - SHButtonLatoLightLocationDelegate

- (void)locationRequestsUpdate:(SHButtonLatoLightLocation *)button location:(LocationChooserViewController *)viewController {
    SHNavigationController *navController = [[SHNavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)locationUpdate:(SHButtonLatoLightLocation *)button location:(CLLocation *)location name:(NSString *)name {
    [Tracker track:@"Fetching Drinklist Results"];

    [self showHUD:@"Getting new drinks"];
    
    NSNumber *lat = [NSNumber numberWithFloat:location.coordinate.latitude];
    NSNumber *lng = [NSNumber numberWithFloat:location.coordinate.longitude];
    
    if (_spotAt != nil) {
        lat = _spotAt.latitude;
        lng = _spotAt.longitude;
    }
    
    [_drinkList putDrinkList:nil latitude:lat longitude:lng spotId:_spotAt.ID sliders:nil success:^(DrinkListModel *drinkListModel, JSONAPI *jsonApi) {
        [self hideHUD];
        
        _drinkList = drinkListModel;
        
        // Oh yeah
        _spotAt = [_drinkList spot];
        
        [self fetchMenuItems];
        [Tracker track:@"Fetched Drinklist Results" properties:@{@"Success" : @TRUE, @"Count" : [NSNumber numberWithUnsignedInteger:_drinkList.drinks.count]}];
        
    } failure:^(ErrorModel *errorModel) {
        [Tracker track:@"Fetched Drinklist Results" properties:@{@"Success" : @FALSE}];
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
    
    _selectedLocation = location;
}

- (void)locationError:(SHButtonLatoLightLocation *)button error:(NSError *)error {
    [self showAlert:error.localizedDescription message:error.localizedRecoverySuggestion];
}

#pragma mark - CheckinViewControllerDelegate

- (void)checkinViewController:(CheckinViewController *)viewController checkedInToSpot:(SpotModel *)spot {
    [self.navigationController popToViewController:self animated:YES];
    
    _spotAt = spot;
    
    [self showHUD:@"Creating drinklist"];
    [spot getSpot:nil success:^(SpotModel *spotModel, JSONAPI *jsonApi) {
        
        NSNumber *latitude = spotModel.latitude;
        NSNumber *longitude = spotModel.longitude;
        
        /*
         * Gets updated spotlist
         */
        [self showHUD:@"Getting new drinks"];
        [_drinkList putDrinkList:nil latitude:latitude longitude:longitude spotId:spotModel.ID sliders:nil success:^(DrinkListModel *drinkListModel, JSONAPI *jsonApi) {
            [self hideHUD];
            
            _drinkList = drinkListModel;
            
            [self fetchMenuItems];
        } failure:^(ErrorModel *errorModel) {
            [self hideHUD];
            [self showAlert:@"Oops" message:errorModel.human];
        }];
        
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

#pragma mark - Actions

- (IBAction)onClickChooseSpot:(id)sender {
    [self goToCheckin:self];
}

- (void)onClickBack:(id)sender {
    if (_createdWithAdjustSliders == NO) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save Custom Drinklist as..." message:nil delegate:self cancelButtonTitle:@"Discard" otherButtonTitles:@"Save", nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [[alertView textFieldAtIndex:0] setPlaceholder:kDrinkListModelDefaultName];
        [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSString *name = [alertView textFieldAtIndex:0].text;
                if (name.length == 0) {
                    name = kDrinkListModelDefaultName;
                }
                
                [self showHUD:@"Updating name"];
                [_drinkList putDrinkList:name latitude:nil longitude:nil spotId:nil sliders:nil success:^(DrinkListModel *drinkListModel, JSONAPI *jsonApi) {
                    [self hideHUD];
                    [self.navigationController popViewControllerAnimated:YES];
                } failure:^(ErrorModel *errorModel) {
                    [self hideHUD];
                    [self showAlert:@"Oops" message:errorModel.human];
                }];
                
            } else {
                [self doDeleteDrinkList];
            }
        }];
        
    }
}

#pragma mark - Private

- (void)fetchMenuItems {
    
    if (_spotAt == nil) {
        [self updateEverything];
        return;
    }
    
    [_menuItems removeAllObjects];
    
    [self showHUD:@"Getting menu"];
    [_spotAt getMenuItems:nil success:^(NSArray *menuItems, JSONAPI *jsonApi) {
        
        for (MenuItemModel *menuItem in menuItems) {
            [_menuItems setObject:menuItem forKey:menuItem.drink.ID];
        }
        
        [self hideHUD];
        [self updateEverything];
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self updateEverything];
    }];
    
}
    
- (void)updateEverything {
    [_collectionView reloadData];
    
    [self updateView];
    [self updateMatchPercent];
}

- (void)updateView {
    
    [_viewEmpty setHidden:( _drinkList.drinks.count != 0 )];
    [_collectionView setHidden:( _drinkList.drinks.count == 0 )];
    
    [_viewPlaceholder setHidden:YES];
    [_viewLocation setHidden:(_spotAt != nil)];
    [_viewSpot setHidden:(_spotAt == nil)];
    
    NSString *title = _spotAt.name;
    [_btnSpot setTitle:title forState:UIControlStateNormal];
    [_btnSpot setImage:[UIImage imageNamed:@"img_arrow_east.png"] forState:UIControlStateNormal];
    CGFloat textWidth = [self widthForString:title font:_btnSpot.titleLabel.font maxWidth:CGFLOAT_MAX];
    _btnSpot.imageEdgeInsets = UIEdgeInsetsMake(0, (textWidth + 10), 0, 0);
    _btnSpot.titleEdgeInsets = UIEdgeInsetsMake(0, -7, 0, 0);
}

- (void)updateMatchPercent {
    
    if (_drinkList.drinks.count == 0) {
        [_lblMatchPercent setText:@""];
        return;
    }
    
    CGPoint initialPinchPoint = CGPointMake(_collectionView.center.x + _collectionView.contentOffset.x,
                                            _collectionView.center.y + _collectionView.contentOffset.y);
    
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:initialPinchPoint];
    
    DrinkModel *drink = nil;
    if (indexPath != nil && indexPath.row < _drinkList.drinks.count) {
        drink = [_drinkList.drinks objectAtIndex:indexPath.row];
    }
    
    if (drink != nil && drink.match != nil) {
        [_lblMatchPercent setText:[NSString stringWithFormat:@"%@ Match", [drink matchPercent]]];
    }
}

- (void)deleteDrinkList {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:@"Are you sure you want to delete this drinklist?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self doDeleteDrinkList];
        }
    }];
    
}

- (void)doDeleteDrinkList {
    [Tracker track:@"Deleting Drinklist"];
    
    [self showHUD:@"Deleting"];
    [_drinkList deleteDrinkList:nil success:^(DrinkListModel *drinkListModel, JSONAPI *jsonApi) {
        [Tracker track:@"Delete Drinklist" properties:@{@"Success" : @TRUE}];
        [self hideHUD];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(ErrorModel *errorModel) {
        [Tracker track:@"Delete Drinklist" properties:@{@"Success" : @FALSE}];
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

@end
