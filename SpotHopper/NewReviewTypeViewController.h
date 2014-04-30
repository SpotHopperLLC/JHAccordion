//
//  NewReviewTypeViewController.h
//  SpotHopper
//
//  Created by Josh Holtz on 2/26/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "BaseViewController.h"

@protocol NewReviewViewControllerDelegate;

@interface NewReviewTypeViewController : BaseViewController

@property (nonatomic, weak) id<NewReviewViewControllerDelegate> delegate;

@end
