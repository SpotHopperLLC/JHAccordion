//
//  SHSectionHeaderView.m
//  SpotHopper
//
//  Created by Brennan Stehling on 6/1/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHSectionHeaderView.h"

@implementation SHSectionHeaderView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
//    // Content view
//    _viewContent = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame) - 47.0f, CGRectGetWidth(self.frame), 47.0f)];
//    [_viewContent setBackgroundColor:[UIColor clearColor]];
//    [_viewContent setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
//    [self addSubview:_viewContent];
//    
//    // Background view
//    _btnBackground = [[UIButton alloc] initWithFrame:_viewContent.frame];
//    [_btnBackground setContentMode:UIViewContentModeScaleToFill];
//    [_btnBackground setBackgroundImage:[UIImage imageNamed:@"table_header_background"] forState:UIControlStateNormal];
//    [_btnBackground setBackgroundImage:[UIImage imageNamed:@"table_header_background_selected"] forState:UIControlStateSelected];
//    [_viewContent addSubview:_btnBackground];
//    
//    // Icon view
//    _imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 7.0f, 30.0f, 36.0f)];
//    [_imgIcon setContentMode:UIViewContentModeCenter];
//    [_viewContent addSubview:_imgIcon];
//    
//    // Label
//    _lblText = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(45.0f, 6.0f, 200.0f, 36.0f)];
//    [_lblText setBackgroundColor:[UIColor clearColor]];
//    [_lblText setTextColor:[UIColor whiteColor]];
//    [_lblText setFont:[UIFont fontWithName:@"Lato-Light" size:18.0f]];
//    [_lblText setUserInteractionEnabled:NO];
//    [_viewContent addSubview:_lblText];
//    
//    // Image arrow
//    _imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_viewContent.frame) - 47.0f, 11.0f, 27.0f, 27.0f)];
//    [_imgArrow setImage:[UIImage imageNamed:@"img_expand_south"]];
//    [_viewContent addSubview:_imgArrow];
}

//- (void)fillSubview:(UIView *)subview inSuperView:(UIView *)superview {
//    NSDictionary *views = NSDictionaryOfVariableBindings(subview);
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|" options:0 metrics:nil views:views]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|" options:0 metrics:nil views:views]];
//}

- (void)prepareView {
//    NSCAssert(self.btnBackground, @"Outlet is required.");
//    NSCAssert(self.imgIcon, @"Outlet is required.");
//    NSCAssert(self.lblText, @"Outlet is required.");
//    NSCAssert(self.imgArrow, @"Outlet is required.");
    
    // Label
    [self.lblText setFont:[UIFont fontWithName:@"Lato-Light" size:18.0f]];
    [self.lblText setUserInteractionEnabled:NO];
}

#pragma mark - Public

- (void)setIconImage:(UIImage*)image {
    self.imgIcon.image = image;
}

- (void)setText:(NSString *)text {
    self.lblText.text = text;
}

- (void)setSelected:(BOOL)selected {
    [self setSelected:selected animated:FALSE];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    float radians = selected ? M_PI : 0;
    [UIView animateWithDuration:0.35 animations:^{
        self.imgArrow.transform = CGAffineTransformMakeRotation(radians);
    }];
}

@end
