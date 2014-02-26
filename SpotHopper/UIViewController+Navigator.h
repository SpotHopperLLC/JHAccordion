//
//  UIViewController+Navigator.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrinkModel.h"
#import "ReviewModel.h"
#import "SpotModel.h"

@interface UIViewController (Navigator)

// Main
- (void)goToLaunch:(BOOL)animated;

// Reviews
- (void)goToReviewMenu;
- (void)goToMyReviews;
- (void)goToReview:(ReviewModel*)review;
- (void)goToNewReviewForDrink:(DrinkModel*)drink;
- (void)goToNewReviewForSpot:(SpotModel*)spot;
- (void)goToSearchForNewReview:(BOOL)showSimilarLists notWhatLookingFor:(BOOL)showNotWhatLookingFor createReview:(BOOL)createReview;
- (void)goToNewReview;
- (void)goToNewReviewWithType:(NSString*)reviewType;
- (void)goToNewReview:(SpotModel*)spot;

// Spots
- (void)goToSpotProfile:(SpotModel *)spot;

@end
