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

@property (weak, nonatomic) IBOutlet UIButton *btnHome;
@property (weak, nonatomic) IBOutlet UIButton *btnButtonRight;
@property (weak, nonatomic) IBOutlet UIButton *btnButtonMiddle;
@property (weak, nonatomic) IBOutlet UIButton *btnButtonLeft;

@property (weak, nonatomic) IBOutlet UILabel *lblHome;
@property (weak, nonatomic) IBOutlet UILabel *lblRight;
@property (weak, nonatomic) IBOutlet UILabel *lblMiddle;
@property (weak, nonatomic) IBOutlet UILabel *lblLeft;

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public

- (void)showHome:(BOOL)show {
    [_btnHome setHidden:!show];
    [_lblHome setHidden:!show];
}

- (void)setLeftButton:(NSString*)label image:(UIImage*)image {
    [_lblLeft setText:label];
    [_btnButtonLeft setImage:image forState:UIControlStateNormal];
    
    [_lblLeft setHidden:NO];
    [_btnButtonLeft setHidden:NO];
}

- (void)setMiddleButton:(NSString*)label image:(UIImage*)image {
    [_lblMiddle setText:label];
    [_btnButtonMiddle setImage:image forState:UIControlStateNormal];
    
    [_lblMiddle setHidden:NO];
    [_btnButtonMiddle setHidden:NO];
}

- (void)setRightButton:(NSString*)label image:(UIImage*)image {
    [_lblRight setText:label];
    [_btnButtonRight setImage:image forState:UIControlStateNormal];
    
    [_lblRight setHidden:NO];
    [_btnButtonRight setHidden:NO];
}

#pragma mark - Actions

- (IBAction)onClickHome:(id)sender {
    if ([_delegate respondsToSelector:@selector(footerViewController:clickedButton:)]) {
        BOOL handled = [_delegate footerViewController:self clickedButton:FooterViewButtonHome];
        if (handled == NO) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)onClickLeft:(id)sender {
    if ([_delegate respondsToSelector:@selector(footerViewController:clickedButton:)]) {
        [_delegate footerViewController:self clickedButton:FooterViewButtonLeft];
    }
}

- (IBAction)onClickMiddle:(id)sender {
    if ([_delegate respondsToSelector:@selector(footerViewController:clickedButton:)]) {
        [_delegate footerViewController:self clickedButton:FooterViewButtonMiddle];
    }
}

- (IBAction)onClickRight:(id)sender {
    if ([_delegate respondsToSelector:@selector(footerViewController:clickedButton:)]) {
        [_delegate footerViewController:self clickedButton:FooterViewButtonRight];
    }
}

@end
