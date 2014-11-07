//
//  UIButton+UIButton_FilterStyling.h
//  
//
//  Created by Tracee Pettigrew on 8/11/14.
//
//

#import <UIKit/UIKit.h>

@interface UIButton (FilterStyling)

- (void)styleAsFilterButtonWithTopImage:(UIImage *)image text:(NSString *)text;
- (void)styleAsFilterButtonWithSideImage:(UIImage *)image text:(NSString *)text;
- (void)styleAsEditButton:(UIImage *)image text:(NSString *)text;

- (void)addBottomBorder;
- (void)addTopBorder;
- (void)addLeftBorder;
- (void)addRightBorder;

@end
