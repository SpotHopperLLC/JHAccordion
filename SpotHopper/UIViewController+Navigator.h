//
//  UIViewController+Navigator.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ReviewModel.h"

@interface UIViewController (Navigator)

// Main
- (void)goToLaunch:(BOOL)animated;

// Reviews
- (void)goToReviewMenu;
- (void)goToMyReviews;
- (void)goToReview:(ReviewModel*)review;
- (void)goToSearchForNewReview;
- (void)goToNewReview;

@end
