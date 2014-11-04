//
//  SHDrinkDetailsViewController.m
//  DrinkHopper
//
//  Created by Tracee Pettigrew on 5/29/14.
//  Copyright (c) 2014 DrinkHopper. All rights reserved.
//

#import "SHMenuAdminDrinkProfileViewController.h"

#import "DrinkModel.h"
#import "LiveSpecialModel.h"
#import "DrinkTypeModel.h"
#import "SliderTemplateModel.h"
#import "AverageReviewModel.h"
#import "SliderModel.h"
#import "SpotModel.h"
#import "BaseAlcoholModel.h"

#import "ClientSessionManager.h"

#import "SHSlider.h"

//#import "PhotoAlbumViewController.h"
//#import "PhotoViewerViewController.h"
//#import "SHDrinkDetailFooterNavigationViewController.h"

#import "SHStyleKit+Additions.h"
//#import "NSArray+DailySpecials.h"
#import "UIView+AutoLayout.h"
//#import "UIViewController+Navigator.h"

#import "SHImageModelCollectionViewManager.h"

#import <QuartzCore/QuartzCore.h>

#import "Tracker.h"

#define kCellImageCollection 0
#define kCellDrinkDetails 1

#define kLabelTagDrinkName 1
#define kLabelTagDrinkVintage 2
#define kLabelTagDrinkRegion 3
#define kLabelTagDrinkBrewery 4
#define kLabelTagDrinkMatch 5
#define kLabelTagDrinkTypeSpecificInfo 6
#define kLabelTagDrinkBeerWineInfo 7
#define kViewTagDrinkRating 8
#define kLabelTagDrinkRating 9

#define kLabelTagDrinkSpecial 1
#define kLabelTagDrinkSpecialDetails 2

#define kLeftLabelVibeTag 1
#define kRightLabelVibeTag 2
#define kSliderVibeTag 3

#define kLabelTagDrinkDescription 10
#define kImageViewTagBottomShadow 11

#define kCollectionViewTag 1

#define kFooterNavigationViewHeight 50.0f
#define kCutOffPoint 116.0f

#define kDefineAnimationDuration 0.25f

#define kNumberOfCells 2

@interface SHMenuAdminDrinkProfileViewController () <UITableViewDataSource, UITableViewDelegate, SHImageModelCollectionDelegate /*, SHDrinkDetailFooterNavigationDelegate */>

@property (strong, nonatomic) IBOutlet SHImageModelCollectionViewManager *imageModelCollectionViewManager;

@property (assign, nonatomic) NSInteger currentIndex;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIImageView *topShadowImageView;
@property (weak, nonatomic) UIView *footerContainerView;

@property (strong, nonatomic)  NSString *matchPercentage;
@property (strong, nonatomic) NSArray *orderedSliders;


//@property (strong, nonatomic) SHDrinkDetailFooterNavigationViewController *drinkfooterNavigationViewController;

@end

@implementation SHMenuAdminDrinkProfileViewController{
    BOOL _topBarsClear;
    
    BOOL _isBeer;
    BOOL _isWine;
    BOOL _isCocktail;
    BOOL _isLiquor;
    
}

#pragma mark - Lifecycle Methods
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSDictionary *titleTextAttributes = @{ NSForegroundColorAttributeName : [SHStyleKit color:SHStyleKitColorMyTextColor], NSFontAttributeName : [UIFont fontWithName:@"Lato-Bold" size:20.0f]};
//    self.navigationController.navigationBar.titleTextAttributes = titleTextAttributes;
    
    self.topShadowImageView.image = [SHStyleKit drawImage:SHStyleKitDrawingTopBarWhiteShadowBackground size:CGSizeMake(320, 64)];

    
    //set bottom offset to account for the height of the footer navigation control
    UIEdgeInsets contentInset = self.tableView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    contentInset.bottom = kFooterNavigationViewHeight;
    scrollIndicatorInsets.bottom = kFooterNavigationViewHeight;
    self.tableView.contentInset = contentInset;
    self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
    
    self.matchPercentage = [self.drink matchPercent];
    
    [self fetchDrinkDetails];
    
}

- (NSArray *)viewOptions {
    return @[kDidLoadOptionsNoBackground];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self hideTopBars:TRUE withCompletionBlock:^{
//        DebugLog(@"Done hiding top bars");
    }];

}



#pragma mark -
#pragma mark -


- (void)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    switch (section) {
        case 0:
            numberOfRows =  kNumberOfCells;
            break;
        case 1:
            numberOfRows = self.drink.averageReview.sliders.count;
            break;
        default:
            break;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CollectionViewCellIdentifier = @"CollectionViewCell";
    static NSString *DrinkDetailsCellIdentifier = @"DrinkDetailsCell";
    static NSString *DrinkVibeIdentifier = @"DrinkVibeCell";
    
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case kCellImageCollection: {
                    
                    cell = [tableView dequeueReusableCellWithIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
                    
                    UICollectionView *collectionView = (UICollectionView *)[cell viewWithTag:kCollectionViewTag];
                    
                    self.imageModelCollectionViewManager.collectionView = collectionView;
                    collectionView.delegate = self.imageModelCollectionViewManager;
                    collectionView.dataSource = self.imageModelCollectionViewManager;
                    self.imageModelCollectionViewManager.imageModels = self.drink.images;
                    
                    
                    UILabel *drinkDescription = (UILabel*)[cell viewWithTag:kLabelTagDrinkDescription];
                    //todo: remove test description
                   // NSString *descriptionOfDrink = @"Beer Advocate's #3 ranked beer in the world";
                    if (self.drink.descriptionOfDrink) {
                    //if (descriptionOfDrink) {
                        //todo: change text color to white
                        drinkDescription.textColor = [SHStyleKit color:SHStyleKitColorMyWhiteColor];
                        drinkDescription.font = [UIFont fontWithName:@"Lato-Light" size:18.0f];
                        
                        //todo: need to expand the height of the cell to grow with the drink description
                        
                        //                        drinkDescription.text = self.drink.descriptionOfDrink;
                        drinkDescription.text = @"";

                       // drinkDescription.text = descriptionOfDrink;
                        
                    }
                    else {
                        drinkDescription.text = @"";
                    }
                    
                    UIImageView *bottomShadow = (UIImageView*)[cell viewWithTag:kImageViewTagBottomShadow];
                    //todo: add black image here!
                    bottomShadow.image = [SHStyleKit drawImage:SHStyleKitDrawingBottomBarBlackShadowBackground size:CGSizeMake(320, 64)];
                    
                    break;
                }
                    
                case kCellDrinkDetails:{
                    
                    cell = [tableView dequeueReusableCellWithIdentifier:DrinkDetailsCellIdentifier forIndexPath:indexPath];
                    
                    UILabel *name = (UILabel*)[cell viewWithTag:kLabelTagDrinkName];
                    name.font = [UIFont fontWithName:@"Lato-Bold" size:20.0f];
                    [SHStyleKit setLabel:name textColor:SHStyleKitColorMyTintColor];
                    name.text = self.drink.name;
                    
                    //todo: change all of the details shown in the view
                    UILabel *vintage = (UILabel*)[cell viewWithTag:kLabelTagDrinkVintage];
                    UILabel *region = (UILabel*)[cell viewWithTag:kLabelTagDrinkRegion];
                    
                    if (_isWine) {
                        vintage.font = [UIFont fontWithName:@"Lato-Light" size:14.0f];
                        
                        if (self.drink.vintage > 0) {
                            vintage.text = [NSString stringWithFormat:@"%ld",(long)[self.drink.vintage integerValue] ];
                        }
                        else {
                            vintage.text = @"";
                        }
                        
                        
                        region.font = [UIFont fontWithName:@"Lato-Light" size:14.0f];
                        region.text = self.drink.region;
                    }
                    else{
                        vintage.text = @"";
                        region.text = @"";
                    }
                    
                    UILabel *match = (UILabel*)[cell viewWithTag:kLabelTagDrinkMatch];
                    if (self.matchPercentage) {
                        match.font = [UIFont fontWithName:@"Lato-LightItalic" size:18.0f];
                        match.text = [NSString stringWithFormat:@"%@ Match",self.matchPercentage];
                    }
                    else{
                        match.text = @"";
                    }
                    
                    UILabel *brewery = (UILabel*)[cell viewWithTag:kLabelTagDrinkBrewery];
                    brewery.font = [UIFont fontWithName:@"Lato-LightItalic" size:18.0f];
                    brewery.text = self.drink.spot.name;
                    
                    UILabel *drinkSpecific = (UILabel*)[cell viewWithTag:kLabelTagDrinkTypeSpecificInfo];
                    drinkSpecific.font = [UIFont fontWithName:@"Lato-Light" size:14.0f];
                    
                    NSString *message;
                    if (_isWine) {
                        message = self.drink.varietal;
                    }
                    else if (_isBeer) {
                        message = self.drink.style;
                    }
                    else {
                        BaseAlcoholModel *baseAlcohol = [self.drink.baseAlochols firstObject];
                        message = baseAlcohol.name;
                    }
                    
                    drinkSpecific.text = message;
                    
                    UILabel *beerAndWineInfo = (UILabel*)[cell viewWithTag:kLabelTagDrinkBeerWineInfo];
                    
                    if (_isWine || _isBeer) {
                        beerAndWineInfo.font = [UIFont fontWithName:@"Lato-Light" size:14.0f];
                        beerAndWineInfo.text = [NSString stringWithFormat:@"%.3f ABV", [self.drink.abv floatValue]];
                    }
                    else {
                        beerAndWineInfo.text = @"";
                    }
                    
                    UIView *ratingView = [cell viewWithTag:kViewTagDrinkRating];
                    ratingView.layer.cornerRadius = CGRectGetHeight(ratingView.frame)/2;
                    ratingView.clipsToBounds = YES;
                    ratingView.backgroundColor = [SHStyleKit color:SHStyleKitColorMyTintColor];
                    
                    UILabel *rating = (UILabel*)[cell viewWithTag:kLabelTagDrinkRating];
                    rating.font = [UIFont fontWithName:@"Lato-Light" size:16.0f];
                    rating.textColor = [SHStyleKit color:SHStyleKitColorMyWhiteColor];
                    rating.text = [NSString stringWithFormat:@"%.1f/10", [self.drink.averageReview.rating floatValue]];
                    
                    
                    break;
                }
                    
            }
            
            break;
        }
        case 1:{
            cell = [tableView dequeueReusableCellWithIdentifier:DrinkVibeIdentifier forIndexPath:indexPath];
            
            SHSlider *slider = (SHSlider*)[cell viewWithTag:kSliderVibeTag];
            UILabel *minValue = (UILabel*)[cell viewWithTag:kLeftLabelVibeTag];
            UILabel *maxValue = (UILabel*)[cell viewWithTag:kRightLabelVibeTag];
            slider.vibeFeel = TRUE;
            
            SliderModel *sliderModel = self.orderedSliders[indexPath.row];
            SliderTemplateModel *sliderTemplate = sliderModel.sliderTemplate;
            
            minValue.text = sliderTemplate.minLabel.length ? sliderTemplate.minLabel : @"";
            maxValue.text = sliderTemplate.maxLabel.length ? sliderTemplate.maxLabel : @"";
            
            [slider setSelectedValue:(sliderModel.value.floatValue / 10.0f)];
            
            break;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //no action on the table view being selected
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0f;
    
    
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case kCellImageCollection:
                    height = 180.0f;
                    break;
                case kCellDrinkDetails:
                    height = 154.0f;
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
            height = 80.0f;
        default:
            break;
    }
    
    return height;
}

#pragma mark - SHImageModelCollectionDelegate
#pragma mark -

- (void)imageCollectionViewManager:(SHImageModelCollectionViewManager *)manager didChangeToImageAtIndex:(NSUInteger)index {
    //change the collection view to show to the current cell at the index path
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [manager.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:TRUE];
}

- (void)imageCollectionViewManager:(SHImageModelCollectionViewManager *)manager didSelectImageAtIndex:(NSUInteger)index {
    //trigger segue on image selection
    
    //do nothing v1.0.0
//    self.currentIndex = index;
//    
//    if (manager.imageModels.count > 1) {
//        [self performSegueWithIdentifier:DrinkProfileToPhotoAlbum sender:self];
//    }
//    else {
//        [self performSegueWithIdentifier:DrinkProfileToPhotoViewer sender:self];
//    }
    
}

#pragma mark - UIScrollViewDelegate
#pragma mark -

#define kTopImageHeight 180.0f

#define kTagCollectionView 1
#define kTagImageView 1

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // adjust the top image view
    CGFloat topImageHeight = kTopImageHeight;
    CGFloat yPos = 0.0f;
    
    if (scrollView.contentOffset.y < 0) {
        topImageHeight += MIN(kTopImageHeight, ABS(scrollView.contentOffset.y));
        yPos += MIN(0, scrollView.contentOffset.y);
    }
    
    UITableViewCell *tableCell = (UITableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (tableCell) {
        UICollectionView *collectionView = (UICollectionView *)[tableCell viewWithTag:kTagCollectionView];
        NSAssert(collectionView, @"Collection View is required");
        if (collectionView) {
            NSArray *indexPaths = [collectionView indexPathsForVisibleItems];
            if (indexPaths.count) {
                UICollectionViewCell *collectionCell = [collectionView cellForItemAtIndexPath:indexPaths[0]];
                if (collectionCell) {
                    UIImageView *imageView = (UIImageView *)[collectionCell viewWithTag:kTagImageView];
                    NSAssert(imageView, @"Image View is required");
                    CGRect frame = imageView.frame;
                    frame.size.height = topImageHeight;
                    frame.origin.y = yPos;
                    imageView.frame = frame;
                    //LOG_FRAME(@"frame", frame);
                }
            }
        }
    }
    
    if (_topBarsClear && scrollView.contentOffset.y > kCutOffPoint) {
        [self showTopBars:TRUE withCompletionBlock:nil];
    }
    else if (!_topBarsClear && scrollView.contentOffset.y <= kCutOffPoint) {
        [self hideTopBars:TRUE withCompletionBlock:nil];
    }
}

#pragma mark - Private Methods
#pragma mark -

- (void)fetchDrinkDetails {
    //fetch drink sliders and review info

    [self.drink getDrink:nil success:^(DrinkModel *drinkModel, JSONAPI *jsonApi) {
        if (drinkModel) {
            self.drink = drinkModel;
            self.drink.averageReview = drinkModel.averageReview;
            
            self.orderedSliders = [self.drink.averageReview.sliders sortedArrayUsingComparator:^NSComparisonResult(SliderModel *obj1, SliderModel *obj2) {
                return [obj1.sliderTemplate.order compare:obj2.sliderTemplate.order];
            }];
            
            [self findDrinkType];
            
            
            [self.tableView reloadData];
        }
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)prepareAnimationForNavigationBarWithDuration:(CGFloat)duration {
    // prepare animation for navigation bar
    CATransition *animation = [CATransition animation];
    [animation setDuration:duration];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setType:kCATransitionFade];
    [self.navigationController.navigationBar.layer addAnimation:animation forKey:nil];
}

- (void)hideTopBars:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    //DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    // sets a clear background for the top bars
    
    _topBarsClear = TRUE;
    
    CGFloat duration = animated ? kDefineAnimationDuration : 0.0f;
    
    [self prepareAnimationForNavigationBarWithDuration:duration];
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        [self.navigationController.navigationItem setTitle:nil];
    } completion:^(BOOL finished) {
        [self.navigationItem setTitle:nil];
        
        UIImage *backArrowImage = [[SHStyleKit drawImage:SHStyleKitDrawingArrowLeftIcon color:SHStyleKitColorMyWhiteColor size:CGSizeMake(30, 30)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithImage:backArrowImage style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
        self.navigationItem.leftBarButtonItem = backBarItem;
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)showTopBars:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    // DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    // sets the top bars to show an opaque background
    
    _topBarsClear = FALSE;
    
    CGFloat duration = animated ? kDefineAnimationDuration : 0.0f;
    
    [self prepareAnimationForNavigationBarWithDuration:duration];
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        
        UIImage *backgroundImage = [SHStyleKit drawImage:SHStyleKitDrawingTopBarBackground color:SHStyleKitColorMyWhiteColor size:CGSizeMake(320, 64)];
        [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationItem setTitle:self.drink.name];
        
    } completion:^(BOOL finished) {
        [self.navigationItem setTitle:self.drink.name];
        
        UIImage *backArrowImage = [[SHStyleKit drawImage:SHStyleKitDrawingArrowLeftIcon color:SHStyleKitColorMyTintColor size:CGSizeMake(30, 30)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithImage:backArrowImage style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
        self.navigationItem.leftBarButtonItem = backBarItem;
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)findDrinkType {
    if ([self.drink isBeer]) {
        _isBeer = TRUE;
    }
    else if ([self.drink isWine]) {
        _isWine = TRUE;
    }
    else if ([self.drink isCocktail]) {
        _isCocktail = TRUE;
    }
    else {
        NSAssert(self.drink, @"drink must have a defined type");
    }
    
}

#pragma mark - Navigation
#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//    if ([segue.destinationViewController isKindOfClass:[PhotoViewerViewController class]]) {
//        PhotoViewerViewController *viewController = segue.destinationViewController;
//        viewController.images = self.imageModelCollectionViewManager.imageModels;
//        
//        if (self.currentIndex) {
//            viewController.selectedIndex = self.currentIndex;
//        }
//        
//    }
//    else if ([segue.destinationViewController isKindOfClass:[PhotoAlbumViewController class]]){
//        PhotoAlbumViewController *viewController = segue.destinationViewController;
//        viewController.images = self.imageModelCollectionViewManager.imageModels;
//        
//        if (self.currentIndex) {
//            viewController.selectedIndex = self.currentIndex;
//        }
//    }
}

@end
