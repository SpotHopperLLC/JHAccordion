//
//  UIViewController+Navigator.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "UIViewController+Navigator.h"

#import "LaunchViewController.h"

#import "MyReviewsViewController.h"
#import "NewReviewViewController.h"
#import "ReviewViewController.h"
#import "ReviewsMenuViewController.h"
#import "SearchNewReviewViewController.h"

@implementation UIViewController (Navigator)

#pragma mark - Main

- (void)goToLaunch:(BOOL)animated {
    LaunchViewController *viewController = [[self mainStoryboard] instantiateViewControllerWithIdentifier:@"LaunchViewController"];
    [self presentViewController:viewController animated:animated completion:nil];
}

#pragma mark - Reviews

- (void)goToReviewMenu {
    ReviewsMenuViewController *viewController = [[self reviewsStoryboard] instantiateInitialViewController];
    [viewController setTitle:@"Reviews"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToMyReviews {
    MyReviewsViewController *viewController = [[self reviewsStoryboard] instantiateViewControllerWithIdentifier:@"MyReviewsViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToReview:(ReviewModel *)review {
    ReviewViewController *viewController = [[self reviewsStoryboard] instantiateViewControllerWithIdentifier:@"ReviewViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToSearchForNewReview {
    SearchNewReviewViewController *viewController = [[self reviewsStoryboard] instantiateViewControllerWithIdentifier:@"SearchNewReviewViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToNewReview {
    NewReviewViewController *viewController = [[self reviewsStoryboard] instantiateViewControllerWithIdentifier:@"NewReviewViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Private

- (UIStoryboard*)mainStoryboard {
    NSString *name = [self.storyboard valueForKey:@"name"];
    if ([name isEqualToString:@"Main"] == NO) {
        return [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    }
    
    return self.storyboard;
}

- (UIStoryboard*)reviewsStoryboard {
    NSString *name = [self.storyboard valueForKey:@"name"];
    if ([name isEqualToString:@"Reviews"] == NO) {
        return [UIStoryboard storyboardWithName:@"Reviews" bundle:[NSBundle mainBundle]];
    }
    
    return self.storyboard;
}

@end
