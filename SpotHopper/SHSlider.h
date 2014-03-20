//
//  SHSlider.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SHSliderDelegate;

@interface SHSlider : UIControl

@property (weak, nonatomic) IBOutlet id<SHSliderDelegate>delegate;

@property (nonatomic, assign) CGFloat selectedValue;
@property (nonatomic, assign) BOOL vibeFeel;
@property (nonatomic, assign) BOOL userMoved;

- (void)setSelectedValue:(CGFloat)selectedValue animated:(BOOL)animated;

@end

@protocol SHSliderDelegate <NSObject>

@optional

// as the user moves the slider this callback will fire each time the value is changed
- (void)slider:(SHSlider *)slider valueDidChange:(CGFloat)value;

// one the user completes the gesture this callback is fired
- (void)slider:(SHSlider *)slider valueDidFinishChanging:(CGFloat)value;

@end

