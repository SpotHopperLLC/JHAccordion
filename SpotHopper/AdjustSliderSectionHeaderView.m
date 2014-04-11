//
//  AdjustSliderSectionHeaderView.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/5/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "AdjustSliderSectionHeaderView.h"

@implementation AdjustSliderSectionHeaderView

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
    self = [self initWithFrame:CGRectMake(0.0f, 0.0f, width, 48.0f)];
    if (self) {
        
    }
    return self;
}

- (void)setup {
    
    // Content view
    _viewContent = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame) - 48.0f, CGRectGetWidth(self.frame), 48.0f)];
    [_viewContent setBackgroundColor:[UIColor clearColor]];
    [_viewContent setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self addSubview:_viewContent];
    
    // White bottom border
    
    // Background view
    _btnBackground = [[UIButton alloc] initWithFrame:_viewContent.frame];
    [_btnBackground setContentMode:UIViewContentModeScaleToFill];
    [self updateViewButtonBackground];
    
    [_viewContent addSubview:_btnBackground];
    
    // Label
    _lblText = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 235.0f, 48.0f)];
    [_lblText setBackgroundColor:[UIColor clearColor]];
    [_lblText setTextColor:[UIColor whiteColor]];
    [_lblText setFont:[UIFont fontWithName:@"Lato-Light" size:18.0f]];
    [_lblText setUserInteractionEnabled:FALSE];
    [_viewContent addSubview:_lblText];
    
    // Image arrow
    _imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_viewContent.frame) - 47.0f, 11.0f, 27.0f, 27.0f)];
    [_imgArrow setImage:[UIImage imageNamed:@"img_expand_north.png"]];
    [_viewContent addSubview:_imgArrow];
}

#pragma mark - Public

- (void)setText:(NSString *)text {
    [_lblText setText:text];
}

- (void)setSelected:(BOOL)selected {
    [_btnBackground setSelected:selected];
    [self updateViewButtonBackground];
    
    float radians = (selected ? M_PI_2 * -2 : 0);
    [UIView animateWithDuration:0.35 animations:^{
        _imgArrow.transform = CGAffineTransformMakeRotation(radians);
    }];
}

- (void)updateViewButtonBackground {
    [_btnBackground setBackgroundColor:( _btnBackground.selected ? kColorOrangeDark : [UIColor clearColor] )];
}

@end
