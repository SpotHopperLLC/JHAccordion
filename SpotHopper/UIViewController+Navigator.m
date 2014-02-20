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
#import "SpotProfileViewController.h"

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
    [viewController setReview:review];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToNewReviewForDrink:(DrinkModel *)drink {
    ReviewViewController *viewController = [[self reviewsStoryboard] instantiateViewControllerWithIdentifier:@"ReviewViewController"];
    [viewController setDrink:drink];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToNewReviewForSpot:(SpotModel *)spot {
    ReviewViewController *viewController = [[self reviewsStoryboard] instantiateViewControllerWithIdentifier:@"ReviewViewController"];
    [viewController setSpot:spot];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToSearchForNewReview:(BOOL)showSimilarLists notWhatLookingFor:(BOOL)showNotWhatLookingFor createReview:(BOOL)createReview {
    SearchNewReviewViewController *viewController = [[self reviewsStoryboard] instantiateViewControllerWithIdentifier:@"SearchNewReviewViewController"];
    [viewController setShowSimilarList:showSimilarLists];
    [viewController setShowNotWhatLookingFor:showNotWhatLookingFor];
    [viewController setCreateReview:createReview];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToNewReview {
    NewReviewViewController *viewController = [[self reviewsStoryboard] instantiateViewControllerWithIdentifier:@"NewReviewViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Spots

- (void)goToSpotProfile:(SpotModel *)spot {
    SpotProfileViewController *viewController = [[self spotsStoryboard] instantiateViewControllerWithIdentifier:@"SpotProfileViewController"];
    [viewController setSpot:spot];
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

- (UIStoryboard*)spotsStoryboard {
    NSString *name = [self.storyboard valueForKey:@"name"];
    if ([name isEqualToString:@"Spots"] == NO) {
        return [UIStoryboard storyboardWithName:@"Spots" bundle:[NSBundle mainBundle]];
    }
    
    return self.storyboard;
}

@end
