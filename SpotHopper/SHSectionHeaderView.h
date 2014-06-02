//
//  SHSectionHeaderView.h
//  SpotHopper
//
//  Created by Brennan Stehling on 6/1/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIButton+Block.h"

#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface SHSectionHeaderView : UITableViewHeaderFooterView

// TODO: refactor to put more details into the Storyboard and hide more from the header

@property (nonatomic, strong) IBOutlet UIView *viewContent;
@property (nonatomic, strong) IBOutlet UIButton *btnBackground;
@property (nonatomic, strong) IBOutlet UIImageView *imgIcon;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel *lblText;
@property (nonatomic, strong) IBOutlet UIImageView *imgArrow;

@property (nonatomic, assign) BOOL selected;

- (void)prepareView;

- (void)setIconImage:(UIImage*)image;
- (void)setText:(NSString*)text;

@end
