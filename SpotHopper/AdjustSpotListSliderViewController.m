//
//  AdjustSpotListSliderViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/5/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "AdjustSpotListSliderViewController.h"

@interface AdjustSpotListSliderViewController ()

@end

@implementation AdjustSpotListSliderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onClickClose:(id)sender {
    if ([_delegate respondsToSelector:@selector(adjustSliderListSliderViewControllerDelegateClickClose:)]) {
        [_delegate adjustSliderListSliderViewControllerDelegateClickClose:self];
    }
}

#pragma mark - Private

@end
