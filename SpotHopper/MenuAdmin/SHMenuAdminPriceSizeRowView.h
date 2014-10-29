//
//  PriceSizeContainerView.h
//  SpotHopperMenuAdmin
//
//  Created by Tracee Pettigrew on 7/10/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SHMenuAdminPriceSizeRowDelegate;

@interface SHMenuAdminPriceSizeRowView : UIView

@property (nonatomic, strong) UITextField *txtfldPrice;
@property (nonatomic, strong) UILabel *lblSize;
@property (nonatomic, strong) UIButton *btnAddPriceAndSize;
@property (nonatomic, strong) UIButton *btnRemovePriceAndSize;

@property (nonatomic, weak) id <SHMenuAdminPriceSizeRowDelegate> delegate;

@end

@protocol SHMenuAdminPriceSizeRowDelegate <NSObject>

- (void)addPriceAndSizeButtonTapped:(SHMenuAdminPriceSizeRowView*)container;
- (void)removePriceAndSizeButtonTapped:(SHMenuAdminPriceSizeRowView*)container;
- (void)sizeLabelTapped:(SHMenuAdminPriceSizeRowView*)container;

@optional
- (void)viewShouldScroll; 

@end