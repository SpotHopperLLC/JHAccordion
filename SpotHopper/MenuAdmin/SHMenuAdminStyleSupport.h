//
//  UIStyleSupport.h
//  ecn-ios
//
//  Created by Tracee Pettigrew on 2/20/14.
//  Copyright (c) 2014 Tracee Pettigrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHMenuAdminStyleSupport : NSObject

+ (SHMenuAdminStyleSupport*)sharedInstance;

@property (nonatomic, readonly) UIFont *ITALIC_LATO;
@property (nonatomic, readonly) UIFont *REG_LATO;
@property (nonatomic, readonly) UIFont *BOLD_LATO;
@property (nonatomic, readonly) UIFont *SMALL_LATO;

@property (nonatomic, readonly) UIColor *LIGHT_ORANGE;
@property (nonatomic, readonly) UIColor *ORANGE;
@property (nonatomic, readonly) UIColor *DARK_ORANGE;
@property (nonatomic, readonly) UIColor *GRAY;

@end
