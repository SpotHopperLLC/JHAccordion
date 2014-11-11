//
//  SHMenuAdminPickerViewController.h
//  SpotHopper
//
//  Created by Brennan Stehling on 11/10/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "BaseViewController.h"

@protocol SHMenuAdminPickerDelegate;

@interface SHMenuAdminPickerViewController : BaseViewController

@property (weak, nonatomic) id<SHMenuAdminPickerDelegate>delegate;

- (void)prepareForBreweries;

- (void)prepareForWineries;

- (void)prepareForBeerStyles;

@end

@protocol SHMenuAdminPickerDelegate <NSObject>

- (void)pickerView:(SHMenuAdminPickerViewController *)pickerView didSelectItem:(id)item;

@end
