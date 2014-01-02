//
//  FooterViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/2/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FooterViewButtonHome, FooterViewButtonLeft, FooterViewButtonMiddle, FooterViewButtonRight
} FooterViewButtonType;

@protocol FooterViewControllerDelegate;

@interface FooterViewController : UIViewController

@property (nonatomic, assign) id<FooterViewControllerDelegate> delegate;

- (void)showHome:(BOOL)show;
- (void)setLeftButton:(NSString*)label image:(UIImage*)image;
- (void)setMiddleButton:(NSString*)label image:(UIImage*)image;
- (void)setRightButton:(NSString*)label image:(UIImage*)image;

@end

@protocol FooterViewControllerDelegate <NSObject>

@optional
- (void)footerViewController:(FooterViewController*)footerViewController clickedButton:(FooterViewButtonType)footerViewButtonType;

@end