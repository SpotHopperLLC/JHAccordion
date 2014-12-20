//
//  SHDiagnosticsViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 12/16/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHDiagnosticsViewController.h"

#import "SHAppUtil.h"

#import "SHDiagnosticsLocationDetailViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

#define kIndexLocations 0
#define kIndexMessages 1
#define kIndexInteractions 2

@interface SHDiagnosticsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSArray *locations;
@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) NSArray *interactions;

@end

@implementation SHDiagnosticsViewController {
    NSDateFormatter *_dateFormatter;
}

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self.tableView addSubview:refreshControl];
    
    [self refreshData];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)resetButtonTapped:(id)sender {
    [[SHAppUtil defaultInstance] resetLastCheckInPromptDate];
    [self showAlert:@"Reset" message:@"You have reset the prompts!"];
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    [self refreshData];
}

#pragma mark - Data Methods
#pragma mark -

- (void)refreshData {
    self.locations = nil;
    self.messages = nil;
    self.interactions = nil;
    [self.tableView reloadData];
    
    if (self.segmentedControl.selectedSegmentIndex == kIndexLocations) {
        [self fetchLocations];
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexMessages) {
        [self fetchMessages];
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexInteractions) {
        [self fetchInteractions];
    }
}

- (void)fetchLocations {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    PFQuery *query = [PFQuery queryWithClassName:@"LocationLog"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query setLimit:100];
    [query orderByDescending:@"createdAt"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            DebugLog(@"Error: %@", error);
        }
        else {
            self.locations = objects;
            self.tableView.contentOffset = CGPointMake(0, 0);
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
    }];
}

- (void)fetchMessages {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    PFQuery *query = [PFQuery queryWithClassName:@"MessageLog"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query setLimit:100];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            DebugLog(@"Error: %@", error);
        }
        else {
            self.messages = objects;
            self.tableView.contentOffset = CGPointMake(0, 0);
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
    }];
}

- (void)fetchInteractions {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    PFQuery *query = [PFQuery queryWithClassName:@"InteractionLog"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query setLimit:100];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            DebugLog(@"Error: %@", error);
        }
        else {
            self.interactions = objects;
            self.tableView.contentOffset = CGPointMake(0, 0);
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }
    }];
}

- (NSDictionary *)dictionaryForRow:(NSIndexPath *)indexPath {
    NSDictionary *dictionary = nil;
    
    if (self.segmentedControl.selectedSegmentIndex == kIndexLocations) {
        PFObject *obj = self.locations[indexPath.row];
        PFGeoPoint *point = [obj objectForKey:@"location"];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
        
        dictionary = @{
                       @"location" : location,
                       @"text1" : @"Loading...",
                       @"text2" : [NSString stringWithFormat:@"%f, %f", point.latitude, point.longitude],
                       @"text3" : [self stringFromDate:obj.createdAt]
                       };
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexMessages) {
        PFObject *obj = self.messages[indexPath.row];
        PFGeoPoint *point = [obj objectForKey:@"location"];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
        
        NSString *message = [obj objectForKey:@"message"];
        NSString *spot = [obj objectForKey:@"spot"];
        NSNumber *distance = [obj objectForKey:@"distance"];
        
        NSString *text2 = nil;
        if (spot.length) {
            text2 = [NSString stringWithFormat:@"%@ (%.1f meters)", spot, distance.doubleValue];
        }
        else {
            text2 = @"N/A";
        }
        
        dictionary = @{
                       @"location" : location,
                       @"text1" : message,
                       @"text2" : text2,
                       @"text3" : [self stringFromDate:obj.createdAt]
                       };
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexInteractions) {
        PFObject *obj = self.interactions[indexPath.row];
        PFGeoPoint *point = [obj objectForKey:@"location"];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
        
        dictionary = @{
                       @"location" : location,
                       @"text1" : [obj objectForKey:@"interaction"],
                       @"text2" : [self stringFromDate:obj.createdAt],
                       @"text3" : @""
                       };
        
    }
    
    return dictionary;
}

#pragma mark - Formatting
#pragma mark -

- (NSString *)stringFromDate:(NSDate *)date {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MM/dd h:mm a"];
    }
    
    return [_dateFormatter stringFromDate:date];
}

#pragma mark - Location Support
#pragma mark -

- (void)fetchNameForLocation:(CLLocation *)location withCompletionBlock:(void (^)(NSString *name, NSError *error))completionBlock {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        if (placemark) {
            NSString *name = [NSString stringWithFormat:@"%@, %@", placemark.thoroughfare, placemark.locality];
            if (completionBlock) {
                completionBlock(name, nil);
            }
        }
        else {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"No placemark available"};
            NSError *error = [NSError errorWithDomain:@"Location" code:101 userInfo:userInfo];
            
            if (completionBlock) {
                completionBlock(nil, error);
            }
        }
    }];
}

#pragma mark - Rendering Table Cells
#pragma mark -

- (UITableViewCell *)renderLocationCellInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ComboCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    MKMapView *mapView = (MKMapView *)[cell viewWithTag:1];
    UILabel *label1 = (UILabel *)[cell viewWithTag:2];
    UILabel *label2 = (UILabel *)[cell viewWithTag:3];
    UILabel *label3 = (UILabel *)[cell viewWithTag:4];
    
    NSDictionary *dictionary = [self dictionaryForRow:indexPath];
    CLLocation *location = dictionary[@"location"];
    
    CLLocationDistance radius = 50.0;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius);
    [mapView setRegion:region animated:FALSE];
    
    label1.text = dictionary[@"text1"];
    label2.text = dictionary[@"text2"];
    label3.text = dictionary[@"text3"];
    
    [self fetchNameForLocation:location withCompletionBlock:^(NSString *name, NSError *error) {
        MAAssert([NSThread isMainThread], @"Must be main thread");
        if (error) {
            DebugLog(@"Error: %@", error);
        }
        else {
            label1.text = name;
        }
    }];
    
    return cell;
}

- (UITableViewCell *)renderMessageCellInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ComboCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    MKMapView *mapView = (MKMapView *)[cell viewWithTag:1];
    UILabel *label1 = (UILabel *)[cell viewWithTag:2];
    UILabel *label2 = (UILabel *)[cell viewWithTag:3];
    UILabel *label3 = (UILabel *)[cell viewWithTag:4];
    
    NSDictionary *dictionary = [self dictionaryForRow:indexPath];
    CLLocation *location = dictionary[@"location"];
    
    CLLocationDistance radius = 50.0;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius);
    [mapView setRegion:region animated:FALSE];
    
    label1.text = dictionary[@"text1"];
    label2.text = dictionary[@"text2"];
    label3.text = dictionary[@"text3"];
    
    return cell;
}

- (UITableViewCell *)renderInteractionCellInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ComboCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    MKMapView *mapView = (MKMapView *)[cell viewWithTag:1];
    UILabel *label1 = (UILabel *)[cell viewWithTag:2];
    UILabel *label2 = (UILabel *)[cell viewWithTag:3];
    UILabel *label3 = (UILabel *)[cell viewWithTag:4];
    
    NSDictionary *dictionary = [self dictionaryForRow:indexPath];
    CLLocation *location = dictionary[@"location"];
    
    CLLocationDistance radius = 50.0;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius);
    [mapView setRegion:region animated:FALSE];
    
    label1.text = dictionary[@"text1"];
    label2.text = dictionary[@"text2"];
    label3.text = dictionary[@"text3"];
    
    return cell;
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    
    if (self.segmentedControl.selectedSegmentIndex == kIndexLocations) {
        number = self.locations.count;
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexMessages) {
        number = self.messages.count;
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexInteractions) {
        number = self.interactions.count;
    }
    
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (self.segmentedControl.selectedSegmentIndex == kIndexLocations) {
        cell = [self renderLocationCellInTableView:tableView atIndexPath:indexPath];
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexMessages) {
        cell = [self renderMessageCellInTableView:tableView atIndexPath:indexPath];
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexInteractions) {
        cell = [self renderInteractionCellInTableView:tableView atIndexPath:indexPath];
    }
    
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DummyCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Error!";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFObject *obj = nil;
        
        NSMutableArray *objects = nil;
        
        if (self.segmentedControl.selectedSegmentIndex == kIndexLocations && indexPath.row < self.locations.count) {
            obj = self.locations[indexPath.row];
            objects = self.locations.mutableCopy;
        }
        else if (self.segmentedControl.selectedSegmentIndex == kIndexMessages && indexPath.row < self.messages.count) {
            obj = self.messages[indexPath.row];
            objects = self.messages.mutableCopy;
        }
        else if (self.segmentedControl.selectedSegmentIndex == kIndexInteractions && indexPath.row < self.interactions.count) {
            obj = self.interactions[indexPath.row];
            objects = self.interactions.mutableCopy;
        }

        if (obj) {
            [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    DebugLog(@"Error: %@", error);
                }
                else if (succeeded) {
                    [objects removeObject:obj];
                    
                    if (self.segmentedControl.selectedSegmentIndex == kIndexLocations) {
                        self.locations = objects;
                    }
                    else if (self.segmentedControl.selectedSegmentIndex == kIndexMessages) {
                        self.messages = objects;
                    }
                    else if (self.segmentedControl.selectedSegmentIndex == kIndexInteractions) {
                        self.interactions = objects;
                    }
                    
                    // now remove this row
                    [self.tableView beginUpdates];
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                }
            }];
        }
    }
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dictionary = [self dictionaryForRow:indexPath];
    NSString *text1 = dictionary[@"text1"];
    NSString *text2 = dictionary[@"text2"];
    NSString *text3 = dictionary[@"text3"];
    
    CGFloat maxWidth = 216;
    UIFont *font1 = [UIFont boldSystemFontOfSize:16];
    UIFont *font2 = [UIFont systemFontOfSize:14];
    
    CGFloat height1 = [[SHAppUtil defaultInstance] heightForString:text1 font:font1 maxWidth:maxWidth];
    CGFloat height2 = [[SHAppUtil defaultInstance] heightForString:text2 font:font2 maxWidth:maxWidth];
    CGFloat height3 = [[SHAppUtil defaultInstance] heightForString:text3 font:font2 maxWidth:maxWidth];
    
    return MAX(96.0, height1 + height2 + height3 + 24.0);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    SHDiagnosticsLocationDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DiagnosticsLocationDetailVC"];
    if (self.segmentedControl.selectedSegmentIndex == kIndexLocations) {
        vc.obj = self.locations[indexPath.row];
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexMessages) {
        vc.obj = self.messages[indexPath.row];
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexInteractions) {
        vc.obj = self.interactions[indexPath.row];
    }
    
    [self.navigationController pushViewController:vc animated:TRUE];
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

@end
