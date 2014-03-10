//
//  SectionHeaderView.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/6/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIButton+Block.h"

#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface SectionHeaderView : UIView

@property (nonatomic, strong) UIView *viewContent;
@property (nonatomic, strong) UIButton *btnBackground;
@property (nonatomic, strong) UIImageView *imgIcon;
@property (nonatomic, strong) TTTAttributedLabel *lblText;
@property (nonatomic, strong) UIImageView *imgArrow;

@property (nonatomic, assign) BOOL selected;

- (id)initWithWidth:(CGFloat)width;

- (void)setIconImage:(UIImage*)image;
- (void)setText:(NSString*)text;

@end
