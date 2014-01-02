//
//  FooterViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/2/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "FooterViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface FooterViewController ()

@property (weak, nonatomic) IBOutlet UIView *viewBackground;

@end

@implementation FooterViewController

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
    
    // Adding shadow to background view
//    [_viewBackground.layer setShadowColor:[UIColor darkGrayColor].CGColor];
//    [_viewBackground.layer setShadowOffset:CGSizeMake(0.0f, 0.0f)];
//    [_viewBackground.layer setShadowRadius:5.0f];
//    [_viewBackground.layer setShadowOpacity:1.0f];
    
    CAGradientLayer *topShadow = [CAGradientLayer layer];
    topShadow.frame = CGRectMake(0, 0, self.view.bounds.size.width, 5);
    topShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.0f] CGColor], (id)[[UIColor colorWithWhite:0.0 alpha:0.25f] CGColor], nil];
    [self.view.layer insertSublayer:topShadow atIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
