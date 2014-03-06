//
//  SpotListViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/5/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#define ITEM_SIZE_WIDTH 180.0f
#define ITEM_SIZE_HEIGHT 247.0f
#define ITEM_SIZE_HEIGHT_4_INCH 300.0f
#define kMeterToMile 0.000621371f

#import "SpotListViewController.h"

#import "UIAlertView+Block.h"
#import "UIViewController+Navigator.h"

#import "TellMeMyLocation.h"

#import "CardLayout.h"
#import "SHButtonLatoLightLocation.h"

#import "SHNavigationController.h"

#import "SpotCardCollectionViewCell.h"

#import "ClientSessionManager.h"
#import "ErrorModel.h"

#import <CoreLocation/CoreLocation.h>

@interface SpotListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, SHButtonLatoLightLocationDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblMatchPercent;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet SHButtonLatoLightLocation *btnLocation;

@property (nonatomic, strong) CLLocation *selectedLocation;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) TellMeMyLocation *tellMeMyLocation;

@property (nonatomic, assign) BOOL showMap;

@end

@implementation SpotListViewController

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
    [super viewDidLoad];
    
    // Sets title
    [self setTitle:[NSString stringWithFormat:@"Similar to %@", _spotList.name]];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Collection view
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView setCollectionViewLayout:[[CardLayout alloc] initWithItemSize:CGSizeMake(ITEM_SIZE_WIDTH, (IS_FOUR_INCH ? ITEM_SIZE_HEIGHT_4_INCH : ITEM_SIZE_HEIGHT) )]];
    
    // Current location
    _tellMeMyLocation = [[TellMeMyLocation alloc] init];
    [_tellMeMyLocation findMe:kCLLocationAccuracyThreeKilometers found:^(CLLocation *newLocation) {
        _currentLocation = newLocation;
    } failure:^(NSError *error) {
        
    }];
    
    // Locations
    [_btnLocation setDelegate:self];
    [_btnLocation updateWithLastLocation];
    
    // Initialize stuff
    _showMap = NO;
    
    // Fetches spotlist
    [self fetchSpotList];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    // Adds contextual footer view
    __block SpotListViewController *this = self;
    [self addFooterViewController:^(FooterViewController *footerViewController) {
        [footerViewController showHome:YES];
        
        if (this.spotList.featured == NO) {
            [footerViewController setLeftButton:@"Delete" image:[UIImage imageNamed:@"btn_context_delete"]];
        }
        
        [this updateFooterMapListButton:footerViewController];
        [footerViewController setRightButton:@"Info" image:[UIImage imageNamed:@"btn_context_info"]];
    }];

}

- (BOOL)footerViewController:(FooterViewController *)footerViewController clickedButton:(FooterViewButtonType)footerViewButtonType {
    if (FooterViewButtonLeft == footerViewButtonType) {
        [self deleteSpotList];
        return YES;
    } else if (FooterViewButtonMiddle == footerViewButtonType) {
        _showMap = !_showMap;
        [self updateFooterMapListButton:footerViewController];
        return YES;
    } else if (FooterViewButtonRight == footerViewButtonType) {
        return YES;
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _spotList.spots.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SpotModel *spot = [_spotList.spots objectAtIndex:indexPath.row];
    
    SpotCardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SpotCardCollectionViewCell" forIndexPath:indexPath];
    [cell setSpot:spot];

    if (_currentLocation != nil && spot.latitude != nil && spot.longitude != nil) {
        CLLocationDistance distance = [_currentLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:spot.latitude.floatValue longitude:spot.longitude.floatValue]];
        [cell.lblHowFar setText:[NSString stringWithFormat:@"%.1f Miles From You", ( distance * kMeterToMile )]];
    } else {
        [cell.lblHowFar setText:@""];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SpotModel *spot = [_spotList.spots objectAtIndex:indexPath.row];
    [self goToSpotProfile:spot];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateMatchPercent];
}

#pragma mark - SHButtonLatoLightLocationDelegate

- (void)locationRequestsUpdate:(SHButtonLatoLightLocation *)button location:(LocationChooserViewController *)viewController {
    SHNavigationController *navController = [[SHNavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)locationUpdate:(SHButtonLatoLightLocation *)button location:(CLLocation *)location name:(NSString *)name {
    _selectedLocation = location;
    
}

- (void)locationError:(SHButtonLatoLightLocation *)button error:(NSError *)error {
    [self showAlert:error.localizedDescription message:error.localizedRecoverySuggestion];
}

#pragma mark - Actions

- (void)onClickBack:(id)sender {
    if (_createdWithAdjustSliders == NO) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save Custom Spotlist as..." message:nil delegate:self cancelButtonTitle:@"Discard" otherButtonTitles:@"Save", nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSString *name = [alertView textFieldAtIndex:0].text;
                if (name.length == 0) {
                    name = kSpotListModelDefaultName;
                }
                
                [self showHUD:@"Updating name"];
                [_spotList putSpotList:name sliders:nil success:^(SpotListModel *spotListModel, JSONAPI *jsonApi) {
                    [self hideHUD];
                    [self.navigationController popViewControllerAnimated:YES];
                } failure:^(ErrorModel *errorModel) {
                    [self hideHUD];
                    [self showAlert:@"Oops" message:errorModel.human];
                }];
                
            } else {
                [self doDeleteSpotList];
            }
        }];
        
    }
}

#pragma mark - Private

- (void)updateFooterMapListButton:(FooterViewController*)footerViewController {
    if (_showMap == YES) {
        [footerViewController setMiddleButton:@"List" image:[UIImage imageNamed:@"btn_context_list"]];
    } else {
        [footerViewController setMiddleButton:@"Map" image:[UIImage imageNamed:@"btn_context_map"]];
    }
}

- (void)updateMatchPercent {
    CGPoint initialPinchPoint = CGPointMake(_collectionView.center.x + _collectionView.contentOffset.x,
                                            _collectionView.center.y + _collectionView.contentOffset.y);
    
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:initialPinchPoint];
    
    SpotModel *spot = [_spotList.spots objectAtIndex:indexPath.row];
    
    if (index != nil && spot.match != nil) {
        [_lblMatchPercent setText:[NSString stringWithFormat:@"%d%% Match", (int)(spot.match.floatValue * 100)]];
    } else {
        [_lblMatchPercent setText:@""];
    }
}

- (void)fetchSpotList {
    
    [self showHUD:@"Getting spots"];
    [_spotList getSpotList:nil success:^(SpotListModel *spotListModel, JSONAPI *jsonAPi) {
        [self hideHUD];
        
        _spotList = spotListModel;
        [_collectionView reloadData];
        
        [self updateMatchPercent];
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [_collectionView reloadData];
        
        [self updateMatchPercent];
    }];
    
}

- (void)deleteSpotList {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:@"Are you sure you want to delete this spotlist?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self doDeleteSpotList];
        }
    }];
    
}

- (void)doDeleteSpotList {
    [self showHUD:@"Deleting"];
    [_spotList deleteSpotList:nil success:^(SpotListModel *spotListModel, JSONAPI *jsonApi) {
        [self hideHUD];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self showAlert:@"Oops" message:errorModel.human];
    }];
}

@end
