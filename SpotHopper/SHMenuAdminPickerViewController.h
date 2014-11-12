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

- (void)reloadData;

- (void)startSearching;

- (void)stopSearching;

@end

@protocol SHMenuAdminPickerDelegate <NSObject>

@required

- (NSString *)titleTextForPickerView:(SHMenuAdminPickerViewController *)pickerView;

- (NSString *)placeholderTextForPickerView:(SHMenuAdminPickerViewController *)pickerView;

- (NSInteger)numberOfItemsForPickerView:(SHMenuAdminPickerViewController *)pickerView;

- (NSString *)textForPickerView:(SHMenuAdminPickerViewController *)pickerView atIndexPath:(NSIndexPath *)indexPath;

- (void)pickerView:(SHMenuAdminPickerViewController *)pickerView didChangeSearchText:(NSString *)searchText;

- (void)pickerView:(SHMenuAdminPickerViewController *)pickerView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)pickerViewDidCancel:(SHMenuAdminPickerViewController *)pickerView;

@end
