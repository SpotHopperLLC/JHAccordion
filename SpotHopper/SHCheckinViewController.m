//
//  SHCheckinViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 10/1/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHCheckinViewController.h"

#import "SHAppContext.h"
#import "SpotModel.h"
#import "SpotTypeModel.h"

#import "SHStyleKit+Additions.h"
#import "ImageUtil.h"
#import "SHNotifications.h"
#import "SHLocationManager.h"

#import "Tracker.h"
#import "Tracker+Events.h"
#import "Tracker+People.h"

#define kMeterToMile 0.000621371f
#define kMetersPerMile 1609.344

@interface SHCheckinViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSArray *spots;

@end

@implementation SHCheckinViewController {
    BOOL _isLoadingSpots;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    _isLoadingSpots = TRUE;
    
    self.headerView.backgroundColor = [SHStyleKit color:SHStyleKitColorMyTintTransparentColor];
    
    [self.cancelButton setTitleColor:[SHStyleKit color:SHStyleKitColorMyWhiteColor] forState:UIControlStateNormal];
}

- (NSArray *)viewOptions {
    return @[kDidLoadOptionsNoBackground];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchSpots];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView flashScrollIndicators];
}

#pragma mark - Private
#pragma mark -

- (void)updateSpots:(NSArray *)spots {
    self.spots = spots;
    [self.tableView reloadData];
}

- (BOOL)isSpotAtIndexPath:(NSIndexPath *)indexPath {
    return self.spots.count && indexPath.row < self.spots.count;
}

- (void)fetchSpots {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fetchSpots) object:nil];
    
    CLLocation *location = [[SHLocationManager defaultInstance] location];
    
    if (!location) {
        [self performSelector:@selector(fetchSpots) withObject:nil afterDelay:0.25];
        return;
    }
    
    // hold onto location to use with table delegates
    self.currentLocation = location;
    
    CLLocationDistance maxRadius = 0.25f * kMetersPerMile;
    CLLocationDistance radius = MIN([[SHAppContext defaultInstance] radius], maxRadius);
    
    DebugLog(@"location: %@", location);
    
    if (location && CLLocationCoordinate2DIsValid(location.coordinate)) {
        [[SpotModel fetchSpotsNearLocation:location radius:radius] then:^(NSArray *spots) {
            DebugLog(@"spots: %@", spots);
            _isLoadingSpots = FALSE;
            [self updateSpots:spots];
        } fail:nil always:^{
        }];
    }
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)cancelButtonTapped:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(checkInViewControllerCancelButtonTapped:)]) {
        [self.delegate checkInViewControllerCancelButtonTapped:self];
    }
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isLoadingSpots) {
        return 1;
    }
    else {
        return self.spots.count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (_isLoadingSpots) {
        static NSString *LoadingCellIdentifier = @"LoadingCell";
        cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier forIndexPath:indexPath];
        
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell viewWithTag:1];
        activityIndicator.color = [SHStyleKit color:SHStyleKitColorMyTintTransparentColor];
        [activityIndicator startAnimating];
    }
    else if (indexPath.row < self.spots.count) {
        static NSString *SpotCellIdentifier = @"SpotCell";
        cell = [tableView dequeueReusableCellWithIdentifier:SpotCellIdentifier forIndexPath:indexPath];
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *typeLabel = (UILabel *)[cell viewWithTag:3];
        UILabel *distanceLabel = (UILabel *)[cell viewWithTag:4];
        
        SpotModel *spot = (SpotModel *)self.spots[indexPath.row];
        
        [ImageUtil loadImage:spot.highlightImage placeholderImage:[UIImage imageNamed:@"spot_placeholder"] withThumbImageBlock:^(UIImage *thumbImage) {
            imageView.image = thumbImage;
        } withFullImageBlock:^(UIImage *fullImage) {
            imageView.image = fullImage;
        } withErrorBlock:^(NSError *error) {
            [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
        
        nameLabel.text = spot.name;
        typeLabel.text = spot.spotType.name;
        
        CLLocationDistance meters = [self.currentLocation distanceFromLocation:spot.location];
        CGFloat miles = meters * kMeterToMile;
        distanceLabel.text = [NSString stringWithFormat:@"%0.1f miles", miles];
    }
    else if (indexPath.row == self.spots.count) {
        static NSString *AddNewReviewCellIdentifier = @"AddNewReviewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:AddNewReviewCellIdentifier forIndexPath:indexPath];
    }
    else {
        NSString *text = [NSString stringWithFormat:@"%li, %li (%lu)", (long)indexPath.section, (long)indexPath.row, (unsigned long)self.spots.count];
        DebugLog(@"%@", text);
        
        static NSString *ErrorCellIdentifier = @"ErrorCell";
        cell = [tableView dequeueReusableCellWithIdentifier:ErrorCellIdentifier forIndexPath:indexPath];
        
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        label.text = text;
    }
    
    NSAssert(cell, @"Cell must be defined");
    
    // extra precaution
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InvalidCell"];
    }
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    selectedBackgroundView.backgroundColor = [SHStyleKit color:SHStyleKitColorMyTintTransparentColor];
    cell.selectedBackgroundView = selectedBackgroundView;
    
    return cell;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isLoadingSpots) {
        return 40.0f;
    }
    else if (indexPath.row < self.spots.count) {
        return 60.0f;
    }
    else if (indexPath.row >= self.spots.count) {
        return 60.0f;
    }
    else {
        return 40.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isSpotAtIndexPath:indexPath]) {
        SpotModel *spot = self.spots[indexPath.row];
        
        if ([self.delegate respondsToSelector:@selector(checkInViewController:checkInAtSpot:)]) {
            [self.delegate checkInViewController:self checkInAtSpot:spot];
        }
        
        CLLocation *currentLocation = [[SHAppContext defaultInstance] deviceLocation];
        CLLocationDistance distance = [currentLocation distanceFromLocation:spot.location];
        
        [Tracker trackCheckedInAtSpot:spot position:indexPath.row+1 count:self.spots.count distance:distance];
        [Tracker trackInteraction:@"Checked In at Spot"];
    }
    else {
        [SHNotifications reviewSpot:nil];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    });
}

@end
