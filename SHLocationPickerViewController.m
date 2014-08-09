//
//  SHLocationPickerViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 7/8/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHLocationPickerViewController.h"

#import "TellMeMyLocation.h"
#import "SVPulsingAnnotationView.h"

#import "SHStyleKit+Additions.h"
#import "ErrorModel.h"
#import "Tracker.h"

#import <QuartzCore/QuartzCore.h>

#define kMapPadding 10000.0f

#define kMetersPerMile 1609.344

@interface SHLocationPickerViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *placemarks;
@property (strong, nonatomic) NSMutableArray *savedPlacemarks;

@end

@implementation SHLocationPickerViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    NSAssert(self.tableView, @"Outlet is required");
    NSAssert(self.tableView.delegate == self, @"Delegate must be self");
    NSAssert(self.tableView.dataSource == self, @"DataSource must be self");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.hidden = TRUE;
    self.savedPlacemarks = [self savedPlacemarks].mutableCopy;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Location Picker";
}

#pragma mark - Public
#pragma mark -

- (void)setTopContentInset:(CGFloat)topContentInset {
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.top = topContentInset;
    self.tableView.contentInset = insets;
}

- (void)searchWithText:(NSString *)text {
    if (text.length > 0) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:text completionHandler:^(NSArray *placemarks, NSError *error) {
            [self hideHUD];
            if (error || placemarks.count == 0) {
                [self showAlert:@"Oops" message:@"Could not find the location you are looking for"];
            }
            else {
                self.placemarks = placemarks;
                self.tableView.hidden = FALSE;
                [self.tableView reloadData];
            }
        }];
    }
}

#pragma mark - Private
#pragma mark -

- (NSString *)nameForPlacemark:(CLPlacemark *)placemark {
    if (placemark.name.length && placemark.locality.length && placemark.administrativeArea.length) {
        return [NSString stringWithFormat:@"%@, %@, %@", placemark.name, placemark.locality, placemark.administrativeArea];
    }
    else if (placemark.subLocality.length && placemark.locality.length && placemark.administrativeArea.length) {
        return [NSString stringWithFormat:@"%@, %@, %@", placemark.subLocality, placemark.locality, placemark.administrativeArea];
    }
    else if (placemark.locality.length && placemark.administrativeArea.length) {
        return [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
    }
    else if (placemark.name.length) {
        return placemark.name;
    }
    else {
        return nil;
    }
}

+ (void)setSavedPlacemarks:(NSArray *)placemarks {
//    if (firstUseDate) {
//        [[NSUserDefaults standardUserDefaults] setObject:firstUseDate forKey:kFirstUseDate];
//    }
//    else {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFirstUseDate];
//    }
//    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)savedPlacemarks {
//    NSDate *firstUseDate = [[NSUserDefaults standardUserDefaults] objectForKey:kFirstUseDate];
//    return firstUseDate;
    
    return @[];
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return MAX(1, self.placemarks.count);
    }
    else {
        // pre-seeded locations and most recent selections
        // TODO: populated seeded and recent selections as placemarks?
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LocationCellIdentifier = @"LocationCell";
    static NSString *NoMatchCellIdentifier = @"NoMatchCell";

    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        if (self.placemarks.count) {
            CLPlacemark *placemark = self.placemarks[indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:LocationCellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = [self nameForPlacemark:placemark];
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:NoMatchCellIdentifier forIndexPath:indexPath];
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:LocationCellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"TBD";
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // TODO: get selected placemark for first section
        if ([self.delegate respondsToSelector:@selector(locationPickerViewController:didSelectPlacemark:)]) {
            CLPlacemark *placemark = self.placemarks[indexPath.row];
            [self.delegate locationPickerViewController:self didSelectPlacemark:placemark];
        }
    }
    else {
        // TODO: get placemark from seeded/previous selections
    }
}

@end
