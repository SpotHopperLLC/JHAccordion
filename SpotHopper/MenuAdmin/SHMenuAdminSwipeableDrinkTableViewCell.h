//
//  SwipeableDrinkCellTableViewCell.h
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 6/20/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SHMenuAdminSwipeableDrinkCellDelegate;

@interface SHMenuAdminSwipeableDrinkTableViewCell : UITableViewCell

#pragma mark - Upper Drink Layer Properties
#pragma mark -
@property (weak, nonatomic) IBOutlet UIImageView *drinkImage;
@property (weak, nonatomic) IBOutlet UILabel *lblDrinkName;
@property (weak, nonatomic) IBOutlet UILabel *lblDrinkSpecifics;
@property (weak, nonatomic) IBOutlet UILabel *lblBrewSpot;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblSlidePrompt;

@property (nonatomic, weak) id <SHMenuAdminSwipeableDrinkCellDelegate> delegate;

- (void)openCell;
- (void)closeCell;
- (void)toggleSwipeGesture:(BOOL)enable;

@end

@protocol SHMenuAdminSwipeableDrinkCellDelegate <NSObject>

- (void)drinkLabelTapped:(SHMenuAdminSwipeableDrinkTableViewCell*)cell;
- (void)photoButtonTapped:(SHMenuAdminSwipeableDrinkTableViewCell*)cell;
- (void)flavorProfileButtonTapped:(SHMenuAdminSwipeableDrinkTableViewCell*)cell;
- (void)editButtonTapped:(SHMenuAdminSwipeableDrinkTableViewCell*)cell;
- (void)deleteButtonTapped:(SHMenuAdminSwipeableDrinkTableViewCell*)cell;

- (void)cellDidOpen:(UITableViewCell *)cell;
- (void)cellDidClose:(UITableViewCell *)cell;

@end
