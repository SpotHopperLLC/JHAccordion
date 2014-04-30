//
//  NewReviewViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 1/8/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseViewController.h"

@class ReviewModel;

@protocol NewReviewViewControllerDelegate;

@interface NewReviewViewController : BaseViewController

@property (nonatomic, strong) NSString *reviewType;
@property (nonatomic, strong) SpotModel *spotBasedOffOf;

@property (nonatomic, weak) id<NewReviewViewControllerDelegate> delegate;

@end

@protocol NewReviewViewControllerDelegate <NSObject>

- (void)newReviewViewController:(NewReviewViewController*)viewController submittedReview:(ReviewModel*)review;

@end