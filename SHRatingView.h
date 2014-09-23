//
//  SHRatingView.h
//  SpotHopper
//
//  Created by Brennan Stehling on 9/19/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface SHRatingView : UIImageView

// 10 point scale translated to percentage on 100 point scale
@property (assign, nonatomic) IBInspectable CGFloat rating;

@end
