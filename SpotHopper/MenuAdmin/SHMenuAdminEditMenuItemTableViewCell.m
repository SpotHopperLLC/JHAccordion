//
//  EditMenuItemTableViewCell.m
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 7/3/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import "SHMenuAdminEditMenuItemTableViewCell.h"
#import "UIView+AutoLayout.h"
#import "SHMenuAdminStyleSupport.h"

#define kMaxContainers 5

#define kPriceSizeContainerHeight 30.0f
#define kPriceSizeContainerWidth 226.0f

#define kAddTitle @"Add!"
#define kSaveTitle @"Save!"

@interface SHMenuAdminEditMenuItemTableViewCell()<UITextFieldDelegate> {
    BOOL isConfiguredForAdd;
}

@end

@implementation SHMenuAdminEditMenuItemTableViewCell

- (void)awakeFromNib {
    [super prepareForReuse];
    //initialize all the stuffffs

    isConfiguredForAdd = FALSE;
    //clear prototype views
    for (UIView *view in self.priceSizeWrapper.subviews) {
        [view removeFromSuperview];
    }

    [self styleCell];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self styleCell];
}

#pragma mark - Actions
#pragma mark -

- (IBAction)menuButtonTapped:(id)sender {
    
    if (sender == self.btnCancel) {
        if ([self.delegate respondsToSelector:@selector(cancelButtonTapped:)]) {
            [self.delegate cancelButtonTapped:self];
        }
    }
    else if (sender == self.btnSave) {
        if (isConfiguredForAdd){
            if ([self.delegate respondsToSelector:@selector(addButtonTapped:)]) {
                [self.delegate addButtonTapped:self];
            }
        }
        else {
            if ([self.delegate respondsToSelector:@selector(saveButtonTapped:)]) {
                [self.delegate saveButtonTapped:self];
            }
        }
    }
    
}

- (void)addPriceAndSizeButtonTapped:(SHMenuAdminPriceSizeRowContainerView*)container {
    if ([self.delegate respondsToSelector:@selector(addPriceAndSizeButtonTapped:)]) {
        NSLog(@"add btn pressed: edit menu cell");
        [self.delegate addPriceAndSizeButtonTapped:self];
    }
}

- (void)removePriceAndSizeButtonTapped:(SHMenuAdminPriceSizeRowContainerView*)container indexOfRemoved:(NSInteger)indexOfRemovedRow{
    if ([self.delegate respondsToSelector:@selector(removePriceAndSizeButtonTapped:indexOfRemoved:)]) {
        NSLog(@"remove btn pressed: edit menu cell");
        [self.delegate removePriceAndSizeButtonTapped:self indexOfRemoved:indexOfRemovedRow];
    }
}

- (void)sizeLabelTapped:(SHMenuAdminPriceSizeRowContainerView*)container row:(SHMenuAdminPriceSizeRowView *)row{
    if ([self.delegate respondsToSelector:@selector(sizeLabelTapped:priceSizeContainer:)]) {
        NSLog(@"size label pressed: edit menu cell");
        [self.delegate sizeLabelTapped:self priceSizeContainer:row];
    }
}

- (void)viewShouldScroll {
    if ([self.delegate respondsToSelector:@selector(viewShouldScroll)]) {
        [self.delegate viewShouldScroll];
    }
}

- (void)configureCellForAdd {
    isConfiguredForAdd = TRUE;
    [self.btnSave setTitle:kAddTitle forState:UIControlStateNormal];
}

- (void)configureCellForEdit {
    isConfiguredForAdd = FALSE;
    [self.btnSave setTitle:kSaveTitle forState:UIControlStateNormal];
}

#pragma mark - Styling
#pragma mark -

- (void)styleCell {
    UIFont *regLato = [UIFont fontWithName:@"Lato-Regular" size:12.0f];
    
    self.lblDrinkName.font = [UIFont fontWithName:@"Lato-Bold" size:18.0f];
    
    self.lblDrinkSpecifics.font = regLato;
    self.lblBrewSpot.font = regLato;
    
    self.btnCancel.titleLabel.font = regLato;
    self.btnCancel.titleLabel.textColor = [SHMenuAdminStyleSupport sharedInstance].ORANGE;
    
    self.btnSave.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:18.0f];
    self.btnSave.titleLabel.textColor = [SHMenuAdminStyleSupport sharedInstance].ORANGE;
}

@end
