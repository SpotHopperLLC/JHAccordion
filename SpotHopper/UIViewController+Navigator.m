//
//  UIViewController+Navigator.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/3/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "UIViewController+Navigator.h"

//#import "FindSimilarViewController.h"
//#import "FindSimilarDrinksViewController.h"
//#import "AgeVerificationViewController.h"
//#import "TutorialViewController.h"
#import "LaunchViewController.h"
#import "AccountSettingsViewController.h"

//#import "DrinksViewController.h"
//#import "DrinksNearbyViewController.h"
//#import "DrinkListMenuViewController.h"
//#import "DrinkListViewController.h"
//#import "FindDrinksAtViewController.h"

#import "MyReviewsViewController.h"
#import "NewReviewViewController.h"
#import "NewReviewTypeViewController.h"
#import "ReviewViewController.h"
#import "ReviewsMenuViewController.h"
#import "SearchNewReviewViewController.h"
//#import "SpotListsMenuViewController.h"
//#import "SpotListViewController.h"

#import "DrinkMenuViewController.h"
#import "DrinkMenuOfferingsViewController.h"

//#import "TonightsSpecialsViewController.h"

#import "CheckinViewController.h"
#import "PhotoAlbumViewController.h"
#import "PhotoViewerViewController.h"

#import "SHDrinkProfileViewController.h"
#import "SHSpotProfileViewController.h"

#import "Tracker.h"
#import "TellMeMyLocation.h"

#import "CheckInModel.h"

@implementation UIViewController (Navigator)

#pragma mark - Main

//- (void)goToAgeVerification:(BOOL)animated {
//    AgeVerificationViewController *viewController = [[self mainStoryboard] instantiateViewControllerWithIdentifier:@"AgeVerificationViewController"];
//    [self presentViewController:viewController animated:animated completion:nil];
//}

//- (void)goToTutorial:(BOOL)animated {
//    TutorialViewController *viewController = [[self mainStoryboard] instantiateViewControllerWithIdentifier:@"TutorialViewController"];
//    [self presentViewController:viewController animated:animated completion:nil];
//}

- (void)goToLaunch:(BOOL)animated {
    LaunchViewController *viewController = [[self mainStoryboard] instantiateViewControllerWithIdentifier:@"LaunchViewController"];
    [self presentViewController:viewController animated:animated completion:nil];
}

- (void)goToAccountSettings:(BOOL)animated {
    AccountSettingsViewController *viewController = [[self userStoryboard] instantiateViewControllerWithIdentifier:@"AccountSettingsViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Drinks

//- (void)goToDrinks {
//    [Tracker track:@"View Drinks" properties:@{@"Location" : [TellMeMyLocation lastLocationNameShort]}];
//    DrinksViewController *viewController = [[self drinksStoryboard] instantiateViewControllerWithIdentifier:@"DrinksViewController"];
//    [self.navigationController pushViewController:viewController animated:YES];
//}

//- (void)goToDrinksNearBy {
//    [Tracker track:@"View Drinks Nearby" properties:@{@"Location" : [TellMeMyLocation lastLocationNameShort]}];
//    DrinksNearbyViewController *viewController = [[self drinksStoryboard] instantiateViewControllerWithIdentifier:@"DrinksNearbyViewController"];
//    [self.navigationController pushViewController:viewController animated:YES];
//}

//- (void)goToDrinkListMenu {
//    [Tracker track:@"View Drink List Menu" properties:@{@"Location" : [TellMeMyLocation lastLocationNameShort]}];
//    [self goToDrinkListMenuAtSpot:nil];
//}

//- (void)goToDrinkListMenuAtSpot:(SpotModel*)spot {
//    [Tracker track:@"View Drinklist Menu at Spot" properties:@{@"Location" : [TellMeMyLocation lastLocationNameShort]}];
//    DrinkListMenuViewController *viewController = [[self drinksStoryboard] instantiateViewControllerWithIdentifier:@"DrinkListMenuViewController"];
//    [viewController setSpot:spot];
//    [self.navigationController pushViewController:viewController animated:YES];
//}

//- (void)goToDrinkList:(DrinkListModel*)drinkList createdWithAdjustSliders:(BOOL)createdWithAdjustSliders atSpot:(SpotModel*)spot {
//    [Tracker track:@"View Drinklist" properties:@{@"Name" : drinkList.name,@"Created with Sliders" : createdWithAdjustSliders ? @YES : @NO, @"Location" : [TellMeMyLocation lastLocationNameShort]}];
//    DrinkListViewController *viewController = [[self drinksStoryboard] instantiateViewControllerWithIdentifier:@"DrinkListViewController"];
//    [viewController setDrinkList:drinkList];
//    [viewController setCreatedWithAdjustSliders:createdWithAdjustSliders];
//    [viewController setSpotAt:spot];
//    [self.navigationController pushViewController:viewController animated:YES];
//}

//- (void)goToFindDrinksAt:(DrinkModel*)drink {
//    [Tracker track:@"View Find Drinks At" properties:@{@"Location" : [TellMeMyLocation lastLocationNameShort]}];
//    FindDrinksAtViewController *viewController = [[self drinksStoryboard] instantiateViewControllerWithIdentifier:@"FindDrinksAtViewController"];
//    [viewController setDrink:drink];
//    [self.navigationController pushViewController:viewController animated:YES];
//}

- (void)goToDrinkProfile:(DrinkModel*)drink {
    [Tracker track:@"View Drink Profile" properties:@{@"Name" : drink.name, @"Location" : [TellMeMyLocation lastLocationNameShort]}];
    
    SHDrinkProfileViewController *viewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHDrinkProfileVC"];
    [viewController setDrink:drink];
    
    if (self.navigationController.viewControllers.count && [self isEqual:self.navigationController.viewControllers[0]]) {
        [self.navigationController pushViewController:viewController animated:TRUE];
    }
    else {
        NSMutableArray *viewControllers = self.navigationController.viewControllers.mutableCopy;
        [viewControllers removeLastObject];
        [viewControllers addObject:viewController];
        [self.navigationController setViewControllers:viewControllers animated:YES];
    }
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

//- (void)goToSpotListMenu {
//    [Tracker track:@"View Spotlist Menu" properties:@{@"Location" : [TellMeMyLocation lastLocationNameShort]}];
//    SpotListsMenuViewController *viewController = [[self spotsStoryboard] instantiateViewControllerWithIdentifier:@"SpotListsMenuViewController"];
//    [self.navigationController pushViewController:viewController animated:YES];
//}

//- (void)goToSpotList:(SpotListModel*)spotList createdWithAdjustSliders:(BOOL)createdWithAdjustSliders {
//    [Tracker track:@"View Spotlist" properties:@{@"Name" : spotList.name, @"Created with Sliders" : createdWithAdjustSliders ? @YES : @NO, @"Location" : [TellMeMyLocation lastLocationNameShort]}];
//    SpotListViewController *viewController = [[self spotsStoryboard] instantiateViewControllerWithIdentifier:@"SpotListViewController"];
//    [viewController setSpotList:spotList];
//    [viewController setCreatedWithAdjustSliders:createdWithAdjustSliders];
//    [self.navigationController pushViewController:viewController animated:YES];
//}

- (void)goToSpotProfile:(SpotModel *)spot {
    [Tracker track:@"View Spot Profile" properties:@{@"Name" : spot.name, @"Location" : [TellMeMyLocation lastLocationNameShort]}];
    
    SHSpotProfileViewController *vc = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHSpotProfileVC"];
    [vc setSpot:spot];
    
    if (self.navigationController.viewControllers.count && [self isEqual:self.navigationController.viewControllers[0]]) {
        [self.navigationController pushViewController:vc animated:TRUE];
    }
    else {
        NSMutableArray *viewControllers = self.navigationController.viewControllers.mutableCopy;
        [viewControllers removeLastObject];
        [viewControllers addObject:vc];
        [self.navigationController setViewControllers:viewControllers animated:YES];
    }
}

#pragma mark - Menu

- (void)goToMenu:(SpotModel *)spot {
    DrinkMenuViewController *viewController = [[self menuStoryboard] instantiateViewControllerWithIdentifier:@"DrinkMenuViewController"];
    [viewController setSpot:spot];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToMenuOfferings:(SpotModel *)spot drinkType:(DrinkTypeModel*)drinkType menuType:(MenuTypeModel*)menuType menuItems:(NSArray*)menuItems {
    [Tracker track:@"View Menu Offerings" properties:@{@"Location" : [TellMeMyLocation lastLocationNameShort]}];
    DrinkMenuOfferingsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DrinkMenuOfferingsViewController"];
    [viewController setSpot:spot];
    [viewController setDrinkType:drinkType];
    [viewController setMenuType:menuType];
    [viewController setMenuItems:menuItems];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Specials

//- (void)goToTonightsSpecials {
//    [Tracker track:@"View Tonight Specials" properties:@{@"Location" : [TellMeMyLocation lastLocationNameShort]}];
//    TonightsSpecialsViewController *viewController = [[self specialsStoryboard] instantiateViewControllerWithIdentifier:@"TonightsSpecialsViewController"];
//    [self.navigationController pushViewController:viewController animated:YES];
//}

#pragma mark - Checkin

- (void)goToCheckin:(id<CheckinViewControllerDelegate>)delegate {
    CheckinViewController *viewController = [[self checkinStoryboard] instantiateViewControllerWithIdentifier:@"CheckinViewController"];
    [viewController setDelegate:delegate];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToCheckIn:(CheckInModel*)checkIn {
    [Tracker track:@"View Check In" properties:@{@"Location" : [TellMeMyLocation lastLocationNameShort]}];
    
    [self goToSpotProfile:checkIn.spot];
}

#pragma mark - Commons

- (void)goToPhotoAlbum:(NSArray *)images atIndex:(NSUInteger)index {
    [Tracker track:@"View Photo Album" properties:@{@"Location" : [TellMeMyLocation lastLocationNameShort]}];
    UIStoryboard *commonStoryboard = [UIStoryboard storyboardWithName:@"Common" bundle:nil];
    PhotoAlbumViewController *viewController = [commonStoryboard instantiateViewControllerWithIdentifier:@"PhotoAlbumViewController"];
    viewController.images = images;
    viewController.selectedIndex = index;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)goToPhotoViewer:(NSArray *)images atIndex:(NSUInteger)index fromPhotoAlbum:(PhotoAlbumViewController *)photoAlbum {
    [Tracker track:@"View Photo Viewer" properties:@{@"Location" : [TellMeMyLocation lastLocationNameShort]}];
    UIStoryboard *commonStoryboard = [UIStoryboard storyboardWithName:@"Common" bundle:nil];
    PhotoViewerViewController *viewController = [commonStoryboard instantiateViewControllerWithIdentifier:@"PhotoViewerViewController"];
    viewController.images = images;
    viewController.selectedIndex = index;
    if (photoAlbum) {
        viewController.delegate = photoAlbum;
    }
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

- (UIStoryboard*)spotHopperStoryboard {
    NSString *name = [self.storyboard valueForKey:@"name"];
    if ([name isEqualToString:@"SpotHopper"] == NO) {
        return [UIStoryboard storyboardWithName:@"SpotHopper" bundle:[NSBundle mainBundle]];
    }
    
    return self.storyboard;
}

@end
