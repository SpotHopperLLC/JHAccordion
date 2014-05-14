//
//  SHLocationMenuBarViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/13/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHLocationMenuBarViewController.h"

#import "SHStyleKit.h"

@interface SHLocationMenuBarViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblNear;
@property (weak, nonatomic) IBOutlet UIButton *btnLocation;

@end

@implementation SHLocationMenuBarViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    self.lblNear.textColor = [SHStyleKit mainTextColor];
    self.btnLocation.tintColor = [SHStyleKit mainColor];
    
    [self.btnLocation setTitle:@"Unknown" forState:UIControlStateNormal];
}

#pragma mark - Public
#pragma mark -

- (void)updateLocationTitle:(NSString *)locationTitle {
    [self.btnLocation setTitle:locationTitle forState:UIControlStateNormal];
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)locationButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(locationMenuBarViewControllerDidRequestLocationChange:)]) {
        [self.delegate locationMenuBarViewControllerDidRequestLocationChange:self];
    }
}

@end
