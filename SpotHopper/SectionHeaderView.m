//
//  SectionHeaderView.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/6/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "SectionHeaderView.h"

@interface SectionHeaderView()

@end

@implementation SectionHeaderView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithWidth:(CGFloat)width {
    self = [self initWithFrame:CGRectMake(0.0f, 0.0f, width, 56.0f)];
    if (self) {
        
    }
    return self;
}

- (void)setup {
    
    // Content view
    _viewContent = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame) - 56.0f, CGRectGetWidth(self.frame), 56.0f)];
    [_viewContent setBackgroundColor:[UIColor clearColor]];
    [_viewContent setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self addSubview:_viewContent];
    
    // Background view
    _btnBackground = [[UIButton alloc] initWithFrame:_viewContent.frame];
    [_btnBackground setContentMode:UIViewContentModeScaleToFill];
    [_btnBackground setBackgroundImage:[UIImage imageNamed:@"table_header_background"] forState:UIControlStateNormal];
    [_btnBackground setBackgroundImage:[UIImage imageNamed:@"table_header_background_selected"] forState:UIControlStateSelected];
    [_viewContent addSubview:_btnBackground];
    
    // Icon view
    _imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 7.0f, 30.0f, 36.0f)];
    [_imgIcon setContentMode:UIViewContentModeCenter];
    [_viewContent addSubview:_imgIcon];
    
    // Label
    _lblText = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(45.0f, 6.0f, 200.0f, 36.0f)];
    [_lblText setBackgroundColor:[UIColor clearColor]];
    [_lblText setTextColor:[UIColor whiteColor]];
    [_lblText setFont:[UIFont fontWithName:@"Lato-Light" size:18.0f]];
    [_lblText setUserInteractionEnabled:NO];
    [_viewContent addSubview:_lblText];
    
    // Image arrow
    _imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_viewContent.frame) - 47.0f, 11.0f, 27.0f, 27.0f)];
    [_imgArrow setImage:[UIImage imageNamed:@"img_expand_east.png"]];
    [_viewContent addSubview:_imgArrow];
}

#pragma mark - Public

- (void)setIconImage:(UIImage*)image {
    [_imgIcon setImage:image];
}

- (void)setText:(NSString *)text {
    [_lblText setText:text];
}

- (void)setSelected:(BOOL)selected {
    [_btnBackground setSelected:selected];
    
    float radians = (selected ? M_PI_2 : 0);
    [UIView animateWithDuration:0.35 animations:^{
        _imgArrow.transform = CGAffineTransformMakeRotation(radians);
    }];
}

@end
