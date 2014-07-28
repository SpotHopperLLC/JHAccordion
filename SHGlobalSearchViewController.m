//
//  SHGlobalSearchViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 7/26/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHGlobalSearchViewController.h"

#import "DrinkModel.h"
#import "SpotModel.h"
#import "ErrorModel.h"
#import "Tracker.h"

@interface SHGlobalSearchViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSTimer *searchTimer;

@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSMutableArray *results;

@end

@implementation SHGlobalSearchViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Tracking
#pragma mark -

- (NSString *)screenName {
    return @"Search";
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    
    if (indexPath.row < _results.count) {
        JSONAPIResource *result = [_results objectAtIndex:indexPath.row];
        
        if ([result isKindOfClass:[DrinkModel class]]) {
            DrinkModel *drink = (DrinkModel *)result;
            DebugLog(@"drink: %@", drink);
        } else if ([result isKindOfClass:[SpotModel class]]) {
            SpotModel *spot = (SpotModel *)result;
            DebugLog(@"spot: %@", spot);
        }
    }
    
    return cell;
    
}

@end
