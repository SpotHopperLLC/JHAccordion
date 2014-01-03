//
//  UIViewController+Navigator.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "UIViewController+Navigator.h"

#import "ReviewsMenuViewController.h"

@implementation UIViewController (Navigator)

- (void)goToReviews {
    ReviewsMenuViewController *viewController = [[self reviewsStoryboard] instantiateInitialViewController];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Private

- (UIStoryboard*)reviewsStoryboard {
    return [UIStoryboard storyboardWithName:@"Reviews" bundle:[NSBundle mainBundle]];
}

@end
