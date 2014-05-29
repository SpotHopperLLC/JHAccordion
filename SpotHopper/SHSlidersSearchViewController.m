//
//  SHSearchViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/22/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHSlidersSearchViewController.h"

#import "SHSlidersSearchTableViewManager.h"

@interface SHSlidersSearchViewController ()

@property (strong, nonatomic) IBOutlet SHSlidersSearchTableViewManager *slidersSearchTableViewManager;

@end

@implementation SHSlidersSearchViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
}

#pragma mark - Public Methods
#pragma mark -

- (void)prepareForMode:(SHMode)mode {
    [[self slidersSearchTableViewManager] prepareForMode:mode];
}

@end
