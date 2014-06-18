//
//  SHLocationMenuBarViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 5/13/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHLocationMenuBarViewController.h"

#import "SHStyleKit.h"
#import "SHStyleKit+Additions.h"

@interface SHLocationMenuBarViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblNear;
@property (weak, nonatomic) IBOutlet UIButton *btnLocation;
@property (weak, nonatomic) IBOutlet UIImageView *navigationArrowImageView;

@end

@implementation SHLocationMenuBarViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    self.lblNear.textColor = [SHStyleKit myTextColor];
    self.btnLocation.tintColor = [SHStyleKit myTextColor];
    self.navigationArrowImageView.image = [SHStyleKit drawImage:SHStyleKitDrawingNavigationArrowRightIcon color:SHStyleKitColorMyTextColor size:CGSizeMake(20, 20)];
    
    [self.btnLocation setTitle:@"Locating..." forState:UIControlStateNormal];
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
