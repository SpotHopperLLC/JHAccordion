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

@property (nonatomic, strong) IBOutlet UIView *viewContent;
@property (nonatomic, strong) IBOutlet UIButton *btnBackground;
@property (nonatomic, strong) IBOutlet UIImageView *imgIcon;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel *lblText;
@property (nonatomic, strong) IBOutlet UIImageView *imgArrow;

@property (nonatomic, assign) BOOL selected;

- (id)initWithWidth:(CGFloat)width __attribute__ ((deprecated));

- (void)prepareView;

- (void)setIconImage:(UIImage*)image;
- (void)setText:(NSString*)text;

@end
