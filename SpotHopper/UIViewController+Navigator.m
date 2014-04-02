//
//  UIViewController+Navigator.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "UIViewController+Navigator.h"

#import "FindSimilarViewController.h"
#import "AgeVerificationViewController.h"
#import "TutorialViewController.h"
#import "LaunchViewController.h"

#import "DrinksNearbyViewController.h"
#import "DrinkListMenuViewController.h"
#import "DrinkListViewController.h"
#import "DrinkProfileViewController.h"
#import "FindSimilarDrinksViewController.h"
#import "FindDrinksAtViewController.h"

#import "MyReviewsViewController.h"
#import "NewReviewViewController.h"
#import "NewReviewTypeViewController.h"
#import "ReviewViewController.h"
#import "ReviewsMenuViewController.h"
#import "SearchNewReviewViewController.h"
#import "SpotListsMenuViewController.h"
#import "SpotListViewController.h"
#import "SpotProfileViewController.h"

#import "DrinkMenuViewController.h"
#import "DrinkMenuOfferingsViewController.h"

#import "TonightsSpecialsViewController.h"

#import "CheckinViewController.h"

@implementation UIViewController (Navigator)

#pragma mark - Main

- (void)goToAgeVerification:(BOOL)animated {
    AgeVerificationViewController *viewController = [[self mainStoryboard] instantiateViewControllerWithIdentifier:@"AgeVerificationViewController"];
    [self presentViewController:viewController animated:animated completion:nil];
}

- (void)goToTutorial:(BOOL)animated {
    TutorialViewController *viewController = [[self mainStoryboard] instantiateViewControllerWithIdentifier:@"TutorialViewController"];
    [self presentViewController:viewController animated:animated completion:nil];
}

- (void)goToLaunch:(BOOL)animated {
    LaunchViewController *viewController = [[self mainStoryboard] instantiateViewControllerWithIdentifier:@"LaunchViewController"];
    [self presentViewController:viewController animated:animated completion:nil];
}

#pragma mark - Drinks

- (void)goToDrinksNearBy {
    DrinksNearbyViewController *viewController = [[self drinksStoryboard] instantiateViewControllerWithIdentifier:@"DrinksNearbyViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToDrinkListMenu {
    [self goToDrinkListMenuAtSpot:nil];
}

- (void)goToDrinkListMenuAtSpot:(SpotModel*)spot {
    DrinkListMenuViewController *viewController = [[self drinksStoryboard] instantiateViewControllerWithIdentifier:@"DrinkListMenuViewController"];
    [viewController setSpot:spot];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToDrinkList:(DrinkListModel*)drinkList createdWithAdjustSliders:(BOOL)createdWithAdjustSliders {
    DrinkListViewController *viewController = [[self drinksStoryboard] instantiateViewControllerWithIdentifier:@"DrinkListViewController"];
    [viewController setDrinkList:drinkList];
    [viewController setCreatedWithAdjustSliders:createdWithAdjustSliders];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToFindDrinksAt:(DrinkModel*)drink {
    FindDrinksAtViewController *viewController = [[self drinksStoryboard] instantiateViewControllerWithIdentifier:@"FindDrinksAtViewController"];
    [viewController setDrink:drink];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToDrinkProfile:(DrinkModel*)drink {
    DrinkProfileViewController *viewController = [[self drinksStoryboard] instantiateViewControllerWithIdentifier:@"DrinkProfileViewController"];
    [viewController setDrink:drink];
    [self.navigationController pushViewController:viewController animated:YES];
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
    [self goToNewReviewForDrink:drink delegate:nil];
}

- (void)goToNewReviewForDrink:(DrinkModel *)drink delegate:(id<ReviewViewControllerDelegate>)delegate {
    ReviewViewController *viewController = [[self reviewsStoryboard] instantiateViewControllerWithIdentifier:@"ReviewViewController"];
    [viewController setDrink:drink];
    [viewController setDelegate:delegate];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToNewReviewForSpot:(SpotModel *)spot {
    [self goToNewReviewForSpot:spot delegate:nil];
}

- (void)goToNewReviewForSpot:(SpotModel *)spot delegate:(id<ReviewViewControllerDelegate>)delegate {
    ReviewViewController *viewController = [[self reviewsStoryboard] instantiateViewControllerWithIdentifier:@"ReviewViewController"];
    [viewController setSpot:spot];
    [viewController setDelegate:delegate];
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
    NewReviewTypeViewController *viewController = [[self reviewsStoryboard] instantiateViewControllerWithIdentifier:@"NewReviewTypeViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToNewReviewWithType:(NSString*)reviewType {
    [self goToNewReviewWithType:reviewType delegate:nil];
}

- (void)goToNewReviewWithType:(NSString*)reviewType delegate:(id<NewReviewViewControllerDelegate>)delegate {
    NewReviewViewController *viewController = [[self reviewsStoryboard] instantiateViewControllerWithIdentifier:@"NewReviewViewController"];
    [viewController setReviewType:reviewType];
    [viewController setDelegate:delegate];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToNewReview:(SpotModel*)spot {
    [self goToNewReviewForSpot:spot delegate:nil];
}

- (void)goToNewReview:(SpotModel*)spot delegate:(id<NewReviewViewControllerDelegate>)delegate {
    NewReviewViewController *viewController = [[self reviewsStoryboard] instantiateViewControllerWithIdentifier:@"NewReviewViewController"];
    [viewController setSpotBasedOffOf:spot];
    [viewController setReviewType:kReviewTypesSpot];
    [viewController setDelegate:delegate];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Spots

- (void)goToSpotListMenu {
    SpotListsMenuViewController *viewController = [[self spotsStoryboard] instantiateViewControllerWithIdentifier:@"SpotListsMenuViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToSpotList:(SpotListModel*)spotList createdWithAdjustSliders:(BOOL)createdWithAdjustSliders {
    SpotListViewController *viewController = [[self spotsStoryboard] instantiateViewControllerWithIdentifier:@"SpotListViewController"];
    [viewController setSpotList:spotList];
    [viewController setCreatedWithAdjustSliders:createdWithAdjustSliders];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToSpotProfile:(SpotModel *)spot {
    SpotProfileViewController *viewController = [[self spotsStoryboard] instantiateViewControllerWithIdentifier:@"SpotProfileViewController"];
    [viewController setSpot:spot];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Menu


- (void)goToMenu:(SpotModel *)spot {
    DrinkMenuViewController *viewController = [[self menuStoryboard] instantiateViewControllerWithIdentifier:@"DrinkMenuViewController"];
    [viewController setSpot:spot];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToMenuOfferings:(SpotModel *)spot drinkType:(DrinkTypeModel*)drinkType menuType:(MenuTypeModel*)menuType menuItems:(NSArray*)menuItems {
    DrinkMenuOfferingsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DrinkMenuOfferingsViewController"];
    [viewController setSpot:spot];
    [viewController setDrinkType:drinkType];
    [viewController setMenuType:menuType];
    [viewController setMenuItems:menuItems];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Specials

- (void)goToTonightsSpecials {
    TonightsSpecialsViewController *viewController = [[self specialsStoryboard] instantiateViewControllerWithIdentifier:@"TonightsSpecialsViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Checkin

- (void)goToCheckin {
    CheckinViewController *viewController = [[self checkinStoryboard] instantiateViewControllerWithIdentifier:@"CheckinViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToCheckinAtSpot:(SpotModel*)spot {
    SpotProfileViewController *viewController = [[self spotsStoryboard] instantiateViewControllerWithIdentifier:@"SpotProfileViewController"];
    [viewController setSpot:spot];
    [viewController setIsCheckin:YES];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Commons

- (void)goToFindSimilarSpots:(id<FindSimilarViewControllerDelegate>)delegate {
    FindSimilarViewController *viewController = [[FindSimilarViewController alloc] initWithNibName:@"FindSimilarViewController" bundle:[NSBundle mainBundle]];
    [viewController setSearchDrinks:NO];
    [viewController setDelegate:delegate];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToFindSimilarDrinks:(id<FindSimilarDrinksViewControllerDelegate>)delegate {
    FindSimilarDrinksViewController *viewController = [[FindSimilarDrinksViewController alloc] initWithNibName:@"FindSimilarDrinksViewController" bundle:[NSBundle mainBundle]];
    [viewController setDelegate:delegate];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Storyboards

- (UIStoryboard*)mainStoryboard {
    NSString *name = [self.storyboard valueForKey:@"name"];
    if ([name isEqualToString:@"Main"] == NO) {
        return [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    }
    
    return self.storyboard;
}

- (UIStoryboard*)drinksStoryboard {
    NSString *name = [self.storyboard valueForKey:@"name"];
    if ([name isEqualToString:@"Drinks"] == NO) {
        return [UIStoryboard storyboardWithName:@"Drinks" bundle:[NSBundle mainBundle]];
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

- (UIStoryboard*)specialsStoryboard {
    NSString *name = [self.storyboard valueForKey:@"name"];
    if ([name isEqualToString:@"Specials"] == NO) {
        return [UIStoryboard storyboardWithName:@"Specials" bundle:[NSBundle mainBundle]];
    }
    
    return self.storyboard;
}

- (UIStoryboard*)menuStoryboard {
    NSString *name = [self.storyboard valueForKey:@"name"];
    if ([name isEqualToString:@"Menu"] == NO) {
        return [UIStoryboard storyboardWithName:@"Menu" bundle:[NSBundle mainBundle]];
    }
    
    return self.storyboard;
}

- (UIStoryboard*)checkinStoryboard {
    NSString *name = [self.storyboard valueForKey:@"name"];
    if ([name isEqualToString:@"Checkin"] == NO) {
        return [UIStoryboard storyboardWithName:@"Checkin" bundle:[NSBundle mainBundle]];
    }
    
    return self.storyboard;
}

- (UIStoryboard*)shareStoryboard {
    NSString *name = [self.storyboard valueForKey:@"name"];
    if ([name isEqualToString:@"Share"] == NO) {
        return [UIStoryboard storyboardWithName:@"Share" bundle:[NSBundle mainBundle]];
    }
    
    return self.storyboard;
}

- (UIStoryboard*)userStoryboard {
    NSString *name = [self.storyboard valueForKey:@"name"];
    if ([name isEqualToString:@"User"] == NO) {
        return [UIStoryboard storyboardWithName:@"User" bundle:[NSBundle mainBundle]];
    }
    
    return self.storyboard;
}

@end
