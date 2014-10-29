//
//  EditMenuItemTableViewCell.h
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 7/3/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHMenuAdminPriceSizeRowView.h"
#import "SHMenuAdminPriceSizeRowContainerView.h"

@protocol SHMenuAdminEditMenuItemCellDelegate;

@interface SHMenuAdminEditMenuItemTableViewCell : UITableViewCell<SHMenuAdminPrizeSizeContainerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *drinkImage;
@property (weak, nonatomic) IBOutlet UILabel *lblDrinkName;
@property (weak, nonatomic) IBOutlet UILabel *lblDrinkSpecifics;
@property (weak, nonatomic) IBOutlet UILabel *lblBrewSpot;

@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;

@property (weak, nonatomic) IBOutlet UIView *priceSizeWrapper;

//every cell comes with one container
@property (strong, nonatomic) NSMutableArray *containers;

@property (nonatomic, weak) id <SHMenuAdminEditMenuItemCellDelegate> delegate;

- (void)configureCellForAdd;
- (void)configureCellForEdit;

@end

@protocol SHMenuAdminEditMenuItemCellDelegate <NSObject>

- (void)addButtonTapped:(SHMenuAdminEditMenuItemTableViewCell*)cell;
- (void)saveButtonTapped:(SHMenuAdminEditMenuItemTableViewCell*)cell;
- (void)cancelButtonTapped:(SHMenuAdminEditMenuItemTableViewCell*)cell;
- (void)sizeLabelTapped:(SHMenuAdminEditMenuItemTableViewCell*)cell priceSizeContainer:(SHMenuAdminPriceSizeRowView*)row;
- (void)addPriceAndSizeButtonTapped:(SHMenuAdminEditMenuItemTableViewCell*)cell;
- (void)removePriceAndSizeButtonTapped:(SHMenuAdminEditMenuItemTableViewCell*)cell indexOfRemoved:(NSInteger)indexOfRemovedRow;

@optional
- (void)viewShouldScroll;

@end