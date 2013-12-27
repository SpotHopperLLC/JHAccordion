//
//  UIAlertView+Block.h
//  BlueTipz
//
//  Created by Josh Holtz on 10/1/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Block)

- (void)showWithCompletion:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))completion;


@end
