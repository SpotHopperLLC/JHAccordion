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

#import "SHPlacemark.h"

#import <QuartzCore/QuartzCore.h>

#define kMapPadding 10000.0f

#define kMetersPerMile 1609.344

@interface SHLocationPickerViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *placemarks;
@property (strong, nonatomic) NSArray *savedPlacemarks;

@property (strong, nonatomic) NSArray *subRegions;

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
    
    self.placemarks = nil;
    self.savedPlacemarks = [self loadSavedPlacemarks].mutableCopy;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Location Picker";
}

#pragma mark - Keyboard
#pragma mark -

- (void)keyboardWillShow:(NSNotification *)notification {
	CGFloat height = [self getKeyboardHeight:notification forBeginning:TRUE];
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.bottom = height;
    self.tableView.contentInset = inset;
    self.tableView.scrollIndicatorInsets = inset;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.bottom = 0;
    self.tableView.contentInset = inset;
    self.tableView.scrollIndicatorInsets = inset;
}

#pragma mark - Public
#pragma mark -

- (void)setTopContentInset:(CGFloat)topContentInset {
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.top = topContentInset;
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
}

- (void)searchWithText:(NSString *)text {
    if (text.length > 0) {
        if ([self.delegate respondsToSelector:@selector(locationPickerViewControllerStartedSearching:)]) {
            [self.delegate locationPickerViewControllerStartedSearching:self];
        }
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:text completionHandler:^(NSArray *placemarks, NSError *error) {
            if ([self.delegate respondsToSelector:@selector(locationPickerViewControllerStoppedSearching:)]) {
                [self.delegate locationPickerViewControllerStoppedSearching:self];
            }

            if (error || placemarks.count == 0) {
                [self showAlert:@"Oops" message:@"Could not find the location you are looking for"];
            }
            else {
                // convert the placemarks and use the weighted region if one is available
                NSMutableArray *convertedPlacemarks = @[].mutableCopy;
                
                for (CLPlacemark *placemark in placemarks) {
                    NSArray *regions = [self findRegionsInRegion:(CLCircularRegion *)placemark.region];
                    SHPlacemark *convertedPlacemark = [SHPlacemark placemarkFromOtherPlacemark:placemark];
                    if (regions.count) {
                        for (CLCircularRegion *region in regions) {
                            SHPlacemark *copiedPlacemark = convertedPlacemark.copy;
                            copiedPlacemark.name = region.identifier;
                            copiedPlacemark.region = region;
                            [convertedPlacemarks addObject:copiedPlacemark];
                        }
                    }
                    else {
                        [convertedPlacemarks addObject:convertedPlacemark];
                    }
                }
                
                self.placemarks = convertedPlacemarks;
                [self.tableView reloadData];
            }
        }];
    }
}

#pragma mark - Private
#pragma mark -

#define kLocationPickerPlacemarks @"LocationPickerPlacemarks"

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

- (void)storeSavedPlacemarks:(NSArray *)placemarks {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (placemarks.count) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:placemarks];
        [userDefaults setObject:data forKey:kLocationPickerPlacemarks];
    }
    else {
        [userDefaults removeObjectForKey:kLocationPickerPlacemarks];
    }
    
    [userDefaults synchronize];
}

- (NSArray *)loadSavedPlacemarks {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefaults objectForKey:kLocationPickerPlacemarks];
    NSArray *placemarks = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (!placemarks.count) {
        // pre-seed NYC and MKE
        placemarks = [self seedPlacemarks];
    }
    
    NSArray *sorted = [SHPlacemark sortedPlacemarks:placemarks];
    
    return sorted;
}

- (void)addSavedPlacemark:(SHPlacemark *)placemark {
    NSAssert(self.savedPlacemarks, @"Saved Placemars must be defined");
    
    NSMutableArray *savedPlacemarks = self.savedPlacemarks.mutableCopy;
    
    if ([savedPlacemarks containsObject:placemark]) {
        NSUInteger index = [savedPlacemarks indexOfObject:placemark];
        placemark.lastUsedDate = [NSDate date];
        [savedPlacemarks replaceObjectAtIndex:index withObject:placemark];
    }
    else {
        [savedPlacemarks addObject:placemark];
    }
    
    NSArray *sorted = [SHPlacemark sortedPlacemarks:savedPlacemarks];
    
    NSUInteger max = 15;
    if (sorted.count > max) {
         sorted = [sorted subarrayWithRange:NSMakeRange(0, max)];
    }
    
    [self storeSavedPlacemarks:sorted];
}

- (NSArray *)seedPlacemarks {
    SHPlacemark *nycPlacemark = [[SHPlacemark alloc] init];
    nycPlacemark.name = @"New York, NY";
    nycPlacemark.region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(40.723779f, -73.991289f) radius:12839.244641 identifier:@"NYC"];
    nycPlacemark.lastUsedDate = [NSDate date];
    
    SHPlacemark *mkePlacemark = [[SHPlacemark alloc] init];
    mkePlacemark.name = @"Milwaukee, WI";
    mkePlacemark.region = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(43.038902f, -87.906474f) radius:18466.410595 identifier:@"MKE"];
    mkePlacemark.lastUsedDate = [NSDate date];
    
    return @[nycPlacemark, mkePlacemark];
}

- (NSArray *)loadSubRegions {
    NSMutableArray *regions = @[].mutableCopy;
    
    // Chicago
    [regions addObject:@{@"name" : @"The Loop, Chicago, IL", @"latitude": [NSNumber numberWithDouble:41.875721f], @"longitude": [NSNumber numberWithDouble:-87.626308f], @"radius": [NSNumber numberWithDouble:1007.979220f], @"weight" : [NSNumber numberWithInteger:5]}];
    [regions addObject:@{@"name" : @"South Loop, Chicago, IL", @"latitude": [NSNumber numberWithDouble:41.857952f], @"longitude": [NSNumber numberWithDouble:-87.623562f], @"radius": [NSNumber numberWithDouble:1008.256287f], @"weight" : [NSNumber numberWithInteger:5]}];
    [regions addObject:@{@"name" : @"West Loop, Chicago, IL", @"latitude": [NSNumber numberWithDouble:41.880178f], @"longitude": [NSNumber numberWithDouble:-87.637326f], @"radius": [NSNumber numberWithDouble:929.372164f], @"weight" : [NSNumber numberWithInteger:5]}];
    [regions addObject:@{@"name" : @"River North, Chicago, IL", @"latitude": [NSNumber numberWithDouble:41.894487f], @"longitude": [NSNumber numberWithDouble:-87.623871f], @"radius": [NSNumber numberWithDouble:1007.686503f], @"weight" : [NSNumber numberWithInteger:5]}];
    
    // Milwaukee
    [regions addObject:@{@"name" : @"Downtown, Milwaukee, WI", @"latitude": [NSNumber numberWithDouble:43.040123f], @"longitude": [NSNumber numberWithDouble:-87.905526f], @"radius": [NSNumber numberWithDouble:989.609747f], @"weight" : [NSNumber numberWithInteger:5]}];
    [regions addObject:@{@"name" : @"East Side, Milwaukee, WI", @"latitude": [NSNumber numberWithDouble:43.061268f], @"longitude": [NSNumber numberWithDouble:-87.886075f], @"radius": [NSNumber numberWithDouble:494.635767f], @"weight" : [NSNumber numberWithInteger:5]}];
    [regions addObject:@{@"name" : @"Shorewood, Milwaukee, WI", @"latitude": [NSNumber numberWithDouble:43.086669f], @"longitude": [NSNumber numberWithDouble:-87.885982f], @"radius": [NSNumber numberWithDouble:459.613738f], @"weight" : [NSNumber numberWithInteger:5]}];
    [regions addObject:@{@"name" : @"Riverwest, Milwaukee, WI", @"latitude": [NSNumber numberWithDouble:43.068234f], @"longitude": [NSNumber numberWithDouble:-87.901862f], @"radius": [NSNumber numberWithDouble:459.750550f], @"weight" : [NSNumber numberWithInteger:5]}];
    [regions addObject:@{@"name" : @"Bay View, Milwaukee, WI", @"latitude": [NSNumber numberWithDouble:42.999030f], @"longitude": [NSNumber numberWithDouble:-87.898900f], @"radius": [NSNumber numberWithDouble:920.528064f], @"weight" : [NSNumber numberWithInteger:5]}];
    [regions addObject:@{@"name" : @"Walker's Point, Milwaukee, WI", @"latitude": [NSNumber numberWithDouble:43.026456f], @"longitude": [NSNumber numberWithDouble:-87.913727f], @"radius": [NSNumber numberWithDouble:920.121502f], @"weight" : [NSNumber numberWithInteger:5]}];
    
    // Minneapolis
    [regions addObject:@{@"name" : @"Minneapolis, MN", @"latitude": [NSNumber numberWithDouble:44.977605f], @"longitude": [NSNumber numberWithDouble:-93.265293f], @"radius": [NSNumber numberWithDouble:1265.132380f], @"weight" : [NSNumber numberWithInteger:5]}];
    
    // Gainesville
    [regions addObject:@{@"name" : @"Gainesville, FL", @"latitude": [NSNumber numberWithDouble:29.651427f], @"longitude": [NSNumber numberWithDouble:-82.325733f], @"radius": [NSNumber numberWithDouble:621.729872f], @"weight" : [NSNumber numberWithInteger:5]}];
    
    // San Diego
    [regions addObject:@{@"name" : @"San Diego, CA", @"latitude": [NSNumber numberWithDouble:32.717821f], @"longitude": [NSNumber numberWithDouble:-117.156564f], @"radius": [NSNumber numberWithDouble:2274.388419f], @"weight" : [NSNumber numberWithInteger:5]}];
    
    // Denver
    [regions addObject:@{@"name" : @"Downtown, Denver, CO", @"latitude": [NSNumber numberWithDouble:39.743472f], @"longitude": [NSNumber numberWithDouble:-104.987865f], @"radius": [NSNumber numberWithDouble:2262.046594f], @"weight" : [NSNumber numberWithInteger:5]}];
    
    // New York
    [regions addObject:@{@"name" : @"Manhattan, New York, NY", @"latitude": [NSNumber numberWithDouble:40.761784f], @"longitude": [NSNumber numberWithDouble:-73.980931f], @"radius": [NSNumber numberWithDouble:1025.156963f], @"weight" : [NSNumber numberWithInteger:5]}];
    [regions addObject:@{@"name" : @"Queens, New York, NY", @"latitude": [NSNumber numberWithDouble:40.731768f], @"longitude": [NSNumber numberWithDouble:-73.799172f], @"radius": [NSNumber numberWithDouble:1025.614422f], @"weight" : [NSNumber numberWithInteger:7]}];
    [regions addObject:@{@"name" : @"Long Beach, New York, NY", @"latitude": [NSNumber numberWithDouble:40.607669f], @"longitude": [NSNumber numberWithDouble:-73.655765f], @"radius": [NSNumber numberWithDouble:4110.030619f], @"weight" : [NSNumber numberWithInteger:8]}];
    [regions addObject:@{@"name" : @"The Bronx, New York, NY", @"latitude": [NSNumber numberWithDouble:40.826368f], @"longitude": [NSNumber numberWithDouble:-73.911144f], @"radius": [NSNumber numberWithDouble:1024.171701f], @"weight" : [NSNumber numberWithInteger:7]}];
    [regions addObject:@{@"name" : @"Brooklyn, New York, NY", @"latitude": [NSNumber numberWithDouble:40.641567f], @"longitude": [NSNumber numberWithDouble:-73.939783f], @"radius": [NSNumber numberWithDouble:4107.969373f], @"weight" : [NSNumber numberWithInteger:5]}];
    
    // San Francisco
    [regions addObject:@{@"name" : @"SOMA, San Francisco, CA", @"latitude": [NSNumber numberWithDouble:37.783899f], @"longitude": [NSNumber numberWithDouble:-122.399481f], @"radius": [NSNumber numberWithDouble:1069.133073f], @"weight" : [NSNumber numberWithInteger:8]}];
    [regions addObject:@{@"name" : @"NOPA, San Francisco, CA", @"latitude": [NSNumber numberWithDouble:37.772349f], @"longitude": [NSNumber numberWithDouble:-122.447911f], @"radius": [NSNumber numberWithDouble:1069.298025f], @"weight" : [NSNumber numberWithInteger:7]}];
    [regions addObject:@{@"name" : @"Fischerman's Wharf, San Francisco, CA", @"latitude": [NSNumber numberWithDouble:37.808111f], @"longitude": [NSNumber numberWithDouble:-122.415446f], @"radius": [NSNumber numberWithDouble:534.393125f], @"weight" : [NSNumber numberWithInteger:7]}];
    [regions addObject:@{@"name" : @"Castro, San Francisco, CA", @"latitude": [NSNumber numberWithDouble:37.759695f], @"longitude": [NSNumber numberWithDouble:-122.434809f], @"radius": [NSNumber numberWithDouble:267.369347f], @"weight" : [NSNumber numberWithInteger:8]}];
    
    return regions;
}

- (NSArray *)findRegionsInRegion:(CLCircularRegion *)region {
    if (!self.subRegions.count) {
        self.subRegions = [self loadSubRegions];
    }
    
    NSMutableArray *regions = @[].mutableCopy;
    
    for (NSDictionary *subRegion in self.subRegions) {
        CLLocationDegrees latitude = [subRegion[@"latitude"] floatValue];
        CLLocationDegrees longitude = [subRegion[@"longitude"] floatValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        if ([region containsCoordinate:coordinate]) {
            NSString *name = subRegion[@"name"];
            CLLocationDistance radius = [subRegion[@"radius"] doubleValue];
            CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinate radius:radius identifier:name];
            [regions addObject:region];
        }
    }
    
    return regions;
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (!self.placemarks) {
            return 0;
        }
        else {
            return MAX(1, self.placemarks.count);
        }
    }
    else {
        // pre-seeded locations and most recent selections
        // TODO: populated seeded and recent selections as placemarks?
        return self.savedPlacemarks.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *LocationCellIdentifier = @"LocationCell";
    static NSString *NoMatchCellIdentifier = @"NoMatchCell";

    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        if (self.placemarks.count) {
            SHPlacemark *placemark = self.placemarks[indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:LocationCellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = placemark.name;
            cell.textLabel.textColor = [SHStyleKit color:SHStyleKitColorMyTextColor];
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:NoMatchCellIdentifier forIndexPath:indexPath];
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:LocationCellIdentifier forIndexPath:indexPath];
        if (indexPath.row < self.savedPlacemarks.count) {
            SHPlacemark *placemark = self.savedPlacemarks[indexPath.row];
            cell.textLabel.text = placemark.name;
            cell.textLabel.textColor = [SHStyleKit color:SHStyleKitColorMyTextColor];
        }
        else {
            cell.textLabel.text = nil;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Saved Locations";
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SHPlacemark *placemark = nil;
    if (indexPath.section == 0 && indexPath.row < self.placemarks.count) {
        placemark = self.placemarks[indexPath.row];
    }
    else if (indexPath.section == 1 && indexPath.row < self.savedPlacemarks.count) {
        placemark = self.savedPlacemarks[indexPath.row];
    }
    
    if (placemark) {
        
        
        DebugLog(@"[coordinates addObject:@{@\"name\" : @\"%@\", @\"latitude\": [NSNumber numberWithDouble:%ff], @\"longitude\": [NSNumber numberWithDouble:%ff], @\"weight\" : [NSNumber numberWithInteger:5]}];", placemark.name, placemark.region.center.latitude, placemark.region.center.longitude);
        
        
        [self addSavedPlacemark:placemark];
        if ([self.delegate respondsToSelector:@selector(locationPickerViewController:didSelectPlacemark:)]) {
            [self.delegate locationPickerViewController:self didSelectPlacemark:placemark];
        }
    }
}

@end
