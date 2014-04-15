//
//  UIButton+Block.h
//  BoothTag
//
//  Created by Josh Holtz on 4/22/12.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#define kUIButtonBlockTouchUpInside @"TouchInside"

#import <UIKit/UIKit.h>

@interface UIButton (Block)

@property (nonatomic, strong) NSMutableDictionary *actions;
@property (nonatomic, assign) BOOL returnButton;
@property (nonatomic, strong) id object;

- (void) setActionWithBlock:(void(^)())block;

@end
