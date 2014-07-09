//
//  ReviewViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseViewController.h"

#import "DrinkModel.h"
#import "ReviewModel.h"
#import "SpotModel.h"

@protocol ReviewViewControllerDelegate;

@interface ReviewViewController : BaseViewController

@property (nonatomic, strong) ReviewModel *review;

@property (nonatomic, strong) DrinkModel *drink;
@property (nonatomic, strong) SpotModel *spot;

@property (nonatomic, weak) id<ReviewViewControllerDelegate> delegate;

@end

@protocol ReviewViewControllerDelegate <NSObject>

- (void)reviewViewController:(ReviewViewController*)viewController submittedReview:(ReviewModel*)review;

@end