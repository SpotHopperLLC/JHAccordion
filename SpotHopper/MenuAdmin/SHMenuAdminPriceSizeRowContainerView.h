//
//  PriceSizeRowContainerView.h
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 7/21/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHMenuAdminPriceSizeRowView.h"

#define kPriceSizeRowHeight 30.0f
#define kPriceSizeRowWidth 226.0f

@protocol SHMenuAdminPrizeSizeContainerDelegate;

@interface SHMenuAdminPriceSizeRowContainerView : UIView <SHMenuAdminPriceSizeRowDelegate>

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, weak) id <SHMenuAdminPrizeSizeContainerDelegate> delegate;

- (SHMenuAdminPriceSizeRowView*)addNewPriceSizeRow;
- (BOOL)removePrizeSizeRow:(UIView*)container;

@end

@protocol SHMenuAdminPrizeSizeContainerDelegate <NSObject>

- (void)sizeLabelTapped:(SHMenuAdminPriceSizeRowContainerView*)container row:(SHMenuAdminPriceSizeRowView*)row;
- (void)addPriceAndSizeButtonTapped:(SHMenuAdminPriceSizeRowContainerView*)container;
- (void)removePriceAndSizeButtonTapped:(SHMenuAdminPriceSizeRowContainerView*)container indexOfRemoved:(NSInteger)indexOfRemovedRow;

@optional
- (void)viewShouldScroll;

@end
