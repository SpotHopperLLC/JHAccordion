//
//  SHDrinkDetailsViewController.m
//  DrinkHopper
//
//  Created by Tracee Pettigrew on 5/29/14.
//  Copyright (c) 2014 DrinkHopper. All rights reserved.
//

#import "SHDrinkProfileViewController.h"

#import "DrinkModel.h"
#import "LiveSpecialModel.h"
#import "DrinkTypeModel.h"
#import "SliderTemplateModel.h"
#import "AverageReviewModel.h"
#import "SliderModel.h"

#import "SHSlider.h"

#import "PhotoAlbumViewController.h"
#import "PhotoViewerViewController.h"

#import "SHStyleKit+Additions.h"
#import "NSArray+DailySpecials.h"
#import "UIView+AutoLayout.h"
#import "UIViewController+Navigator.h"

#import "SHImageModelCollectionViewManager.h"
#import "SHNotifications.h"

#import <QuartzCore/QuartzCore.h>

#import "Tracker.h"
#import "Tracker+Events.h"

#define kSectionImages 0
#define kSectionDrinkDetails 1
#define kSectionSliders 2

#define kCellImageCollection 0
#define kCellDrinkDetails 1

#define kTagDrinkNameLabel 1
#define kTagDrinkVintageLabel 2
#define kTagDrinkRegionLabel 3
#define kTagDrinkBreweryLabel 4
#define kTagDrinkMatchLabel 5
#define kTagDrinkTypeSpecificInfoLabel 6
#define kTagDrinkBeerWineInfoLabel 7
#define kTagDrinkRatingView 8
#define kTagDrinkRatingLabel 9
#define kTagDrinkScoreLabel 10

#define kTagDrinkSpecialLabel 1
#define kTagDrinkSpecialLabelDetails 2

#define kLeftLabelVibeTag 1
#define kRightLabelVibeTag 2
#define kSliderVibeTag 3

#define kFooterNavigationViewHeight 50.0f
#define kCutOffPoint 116.0f

#define kDefineAnimationDuration 0.25f

#define kTopImageHeight 220.0f

#define kTagCollectionView 1
#define kTagImageView 1

#define kTagPreviousImageButton 2
#define kTagNextImageButton 3
#define kTagDescriptionLabel 4
#define kTagBottomShadowImageView 5

NSString* const DrinkProfileToPhotoViewer = @"DrinkProfileToPhotoViewer";
NSString* const DrinkProfileToPhotoAlbum = @"DrinkProfileToPhotoAlbum";

@interface SHDrinkProfileViewController () <UITableViewDataSource, UITableViewDelegate, SHImageModelCollectionDelegate>

@property (strong, nonatomic) IBOutlet SHImageModelCollectionViewManager *imageModelCollectionViewManager;

@property (weak, nonatomic) UIButton *previousImageButton;
@property (weak, nonatomic) UIButton *nextImageButton;

@property (assign, nonatomic) NSInteger currentIndex;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *similarDrinksButton;
@property (weak, nonatomic) IBOutlet UIButton *reviewItButton;

@property (weak, nonatomic) IBOutlet UIImageView *topShadowImageView;
@property (weak, nonatomic) UIView *footerContainerView;

@property (strong, nonatomic)  NSString *matchPercentage;

@end

@implementation SHDrinkProfileViewController{
    BOOL _topBarsClear;
}

#pragma mark - Lifecycle Methods
#pragma mark -

- (void)viewDidLoad {
    [self viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    NSDictionary *titleTextAttributes = @{ NSForegroundColorAttributeName : [SHStyleKit color:SHStyleKitColorMyTextColor], NSFontAttributeName : [UIFont fontWithName:@"Lato-Bold" size:20.0f]};
    self.navigationController.navigationBar.titleTextAttributes = titleTextAttributes;
    
    self.topShadowImageView.image = [SHStyleKit drawImage:SHStyleKitDrawingTopBarWhiteShadowBackground size:CGSizeMake(320, 64)];
    
    //set bottom offset to account for the height of the footer navigation control
    UIEdgeInsets contentInset = self.tableView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    contentInset.bottom = kFooterNavigationViewHeight;
    scrollIndicatorInsets.bottom = kFooterNavigationViewHeight;
    self.tableView.contentInset = contentInset;
    self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
    
    CGSize buttonImageSize = CGSizeMake(30, 30);
    [SHStyleKit setButton:self.similarDrinksButton withDrawing:SHStyleKitDrawingSearchIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor size:buttonImageSize];
    [SHStyleKit setButton:self.reviewItButton withDrawing:SHStyleKitDrawingReviewsIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor size:buttonImageSize];
    
    self.similarDrinksButton.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:12.0f];
    [self.similarDrinksButton setTitleColor:SHStyleKit.myTextColor forState:UIControlStateNormal];
    
    self.reviewItButton.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:12.0f];
    [self.reviewItButton setTitleColor:SHStyleKit.myTextColor forState:UIControlStateNormal];
    
    self.matchPercentage = [self.drink matchPercent];
    
    //fetch drink sliders and review info
    [self.drink getDrink:nil success:^(DrinkModel *drinkModel, JSONAPI *jsonApi) {
        if (drinkModel) {
            self.drink = drinkModel;
            self.drink.averageReview = drinkModel.averageReview;
            [self.tableView reloadData];
        }
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [Tracker trackDrinkProfileScreenViewed:self.drink];
    
    [self hideTopBars:TRUE withCompletionBlock:^{
        DebugLog(@"Done hiding top bars");
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[PhotoViewerViewController class]]) {
        PhotoViewerViewController *vc = segue.destinationViewController;
        vc.images = self.imageModelCollectionViewManager.imageModels;
        
        if (self.currentIndex) {
            vc.selectedIndex = self.currentIndex;
        }
    }
    else if ([segue.destinationViewController isKindOfClass:[PhotoAlbumViewController class]]) {
        PhotoAlbumViewController *vc = segue.destinationViewController;
        vc.images = self.imageModelCollectionViewManager.imageModels;
        vc.placeholderImage = self.drink.placeholderImage;
        
        if (self.currentIndex) {
            vc.selectedIndex = self.currentIndex;
        }
    }
}

#pragma mark - User Actions
#pragma mark -

- (void)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (void)previousButtonTapped:(id)sender {
    [self.imageModelCollectionViewManager goPrevious];
}

- (void)nextButtonTapped:(id)sender {
    [self.imageModelCollectionViewManager goNext];
}

- (IBAction)similarDrinksButtonTapped:(id)sender {
    [SHNotifications findSimilarToDrink:self.drink];
}

- (IBAction)reviewItButtonTapped:(id)sender {
    [self goToNewReviewForDrink:self.drink];
}

#pragma mark - Private
#pragma mark -

- (void)pushToImageAtIndex:(NSUInteger)index {
    //trigger segue on image selection
    self.currentIndex = index;
    
    if (self.imageModelCollectionViewManager.imageModels.count > 1) {
        [self performSegueWithIdentifier:DrinkProfileToPhotoAlbum sender:self];
    }
    else {
        [self performSegueWithIdentifier:DrinkProfileToPhotoViewer sender:self];
    }
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

- (void)embedViewController:(UIViewController *)vc intoView:(UIView *)superview placementBlock:(void (^)(UIView *view))placementBlock {
    NSAssert(vc, @"VC must be define");
    NSAssert(superview, @"Superview must be defined");
    
    vc.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:vc];
    [superview addSubview:vc.view];
    
    if (placementBlock) {
        placementBlock(vc.view);
    }
    else {
        [self fillSubview:vc.view inSuperView:superview];
    }
    
    [vc didMoveToParentViewController:self];
}

- (void)updateImageArrows {
    NSUInteger index = self.imageModelCollectionViewManager.currentIndex;
    
    BOOL hasNext = _drink.images.count ? (index < _drink.images.count - 1) : FALSE;
    BOOL hasPrev = _drink.images.count ? (index > 0) : FALSE;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.nextImageButton.alpha = hasNext ? 1.0 : 0.1;
        self.previousImageButton.alpha = hasPrev ? 1.0 : 0.1;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    
    switch (section) {
        case kSectionImages:
            numberOfRows = 1;
            break;
        case kSectionDrinkDetails:
            numberOfRows = 1;
            break;
        case kSectionSliders:
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
    
    UITableViewCell *cell = nil;
    
    if (kSectionImages == indexPath.section) {
        cell = [tableView dequeueReusableCellWithIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
        
        UICollectionView *collectionView = (UICollectionView *)[cell viewWithTag:kTagCollectionView];
        
        self.imageModelCollectionViewManager.collectionView = collectionView;
        collectionView.delegate = self.imageModelCollectionViewManager;
        collectionView.dataSource = self.imageModelCollectionViewManager;
        self.imageModelCollectionViewManager.imageModels = self.drink.images;
        self.imageModelCollectionViewManager.placeholderImage = self.drink.placeholderImage;
        
        self.previousImageButton = (UIButton *)[cell viewWithTag:kTagPreviousImageButton];
        self.nextImageButton = (UIButton *)[cell viewWithTag:kTagNextImageButton];
        
        [self.previousImageButton addTarget:self action:@selector(previousButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.nextImageButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self updateImageArrows];
        
        UIImageView *bottomShadowImageView = (UIImageView *)[cell viewWithTag:kTagBottomShadowImageView];
        NSAssert(bottomShadowImageView, @"Image View is required");
        bottomShadowImageView.image = [SHStyleKit drawImage:SHStyleKitDrawingBottomBarBlackShadowBackground size:CGSizeMake(320, 64)];
        
        UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:kTagDescriptionLabel];
        NSAssert(descriptionLabel, @"Label is required");
        
        if (self.drink.descriptionOfDrink.length) {
            descriptionLabel.text = self.drink.descriptionOfDrink;
            descriptionLabel.font = [UIFont fontWithName:@"Lato-Regular" size:14.0f];
            descriptionLabel.hidden = FALSE;
            bottomShadowImageView.hidden = FALSE;
        }
        else {
            descriptionLabel.hidden = TRUE;
            bottomShadowImageView.hidden = TRUE;
        }
    }
    else if (kSectionDrinkDetails == indexPath.section) {
        cell = [tableView dequeueReusableCellWithIdentifier:DrinkDetailsCellIdentifier forIndexPath:indexPath];
        
        UILabel *name = (UILabel *)[cell viewWithTag:kTagDrinkNameLabel];
        name.font = [UIFont fontWithName:@"Lato-Bold" size:20.0f];
        [SHStyleKit setLabel:name textColor:SHStyleKitColorMyTintColor];
        name.text = self.drink.name;
        
        UILabel *vintage = (UILabel*)[cell viewWithTag:kTagDrinkVintageLabel];
        UILabel *region = (UILabel*)[cell viewWithTag:kTagDrinkRegionLabel];
        
        BOOL isBeer = [self.drink isBeer];
        BOOL isWine = [self.drink isWine];
        
        if (isWine) {
            vintage.font = [UIFont fontWithName:@"Lato-Light" size:14.0f];
            
            if (self.drink.vintage > 0) {
                vintage.text = [NSString stringWithFormat:@"%ld",(long)[self.drink.vintage integerValue] ];
            }
            else {
                vintage.text = nil;
            }
            
            region.font = [UIFont fontWithName:@"Lato-Light" size:14.0f];
            region.text = self.drink.region;
        }
        else {
            vintage.text = nil;
            region.text = nil;
        }
        
        UILabel *match = (UILabel*)[cell viewWithTag:kTagDrinkMatchLabel];
        if (self.matchPercentage) {
            match.font = [UIFont fontWithName:@"Lato-LightItalic" size:18.0f];
            match.text = [NSString stringWithFormat:@"%@ Match",self.matchPercentage];
        }
        else {
            match.text = nil;
        }
        
        UILabel *brewery = (UILabel*)[cell viewWithTag:kTagDrinkBreweryLabel];
        brewery.font = [UIFont fontWithName:@"Lato-LightItalic" size:18.0f];
        brewery.text = self.drink.spot.name;
        
        UILabel *drinkSpecific = (UILabel*)[cell viewWithTag:kTagDrinkTypeSpecificInfoLabel];
        drinkSpecific.font = [UIFont fontWithName:@"Lato-Light" size:14.0f];
        
        drinkSpecific.text = self.drink.drinkStyle;
        
        UILabel *beerAndWineInfo = (UILabel*)[cell viewWithTag:kTagDrinkBeerWineInfoLabel];
        
        if (isWine || isBeer) {
            beerAndWineInfo.font = [UIFont fontWithName:@"Lato-Light" size:14.0f];
            beerAndWineInfo.text = [NSString stringWithFormat:@"%@ ABV", self.drink.abvPercentString];
        }
        else {
            beerAndWineInfo.text = nil;
        }
        
        UIView *ratingView = [cell viewWithTag:kTagDrinkRatingView];
        ratingView.layer.cornerRadius = CGRectGetHeight(ratingView.frame)/2;
        ratingView.clipsToBounds = YES;
        ratingView.backgroundColor = [SHStyleKit color:SHStyleKitColorMyTintColor];
        
        UILabel *rating = (UILabel*)[cell viewWithTag:kTagDrinkRatingLabel];
        rating.font = [UIFont fontWithName:@"Lato-Light" size:16.0f];
        rating.textColor = [SHStyleKit color:SHStyleKitColorMyWhiteColor];
        rating.text = self.drink.ratingShort;
        
        UILabel *score = (UILabel*)[cell viewWithTag:kTagDrinkScoreLabel];
        score.font = [UIFont fontWithName:@"Lato-Light" size:14.0f];
        score.textColor = [SHStyleKit color:SHStyleKitColorMyWhiteColor];
    }
    else if (kSectionSliders == indexPath.section) {
        cell = [tableView dequeueReusableCellWithIdentifier:DrinkVibeIdentifier forIndexPath:indexPath];
        
        SHSlider *slider = (SHSlider*)[cell viewWithTag:kSliderVibeTag];
        UILabel *minValue = (UILabel*)[cell viewWithTag:kLeftLabelVibeTag];
        UILabel *maxValue = (UILabel*)[cell viewWithTag:kRightLabelVibeTag];
        slider.vibeFeel = TRUE;
        
        SliderModel *sliderModel = self.drink.averageReview.sliders[indexPath.row];
        SliderTemplateModel *sliderTemplate = sliderModel.sliderTemplate;
        
        minValue.text = sliderTemplate.minLabel.length ? sliderTemplate.minLabel : nil;
        maxValue.text = sliderTemplate.maxLabel.length ? sliderTemplate.maxLabel : nil;
        [slider setSelectedValue:(sliderModel.value.floatValue / 10.0f)];
    }
    
    NSAssert(cell, @"Cell must be defined");
    
    return cell;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //no action on the table view being selected
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0f;
    
    if (kSectionImages == indexPath.section) {
        height = kTopImageHeight;
    }
    else if (kSectionDrinkDetails == indexPath.section) {
        height = 130.0f;
    }
    else if (kSectionSliders == indexPath.section) {
        height = 80.0f;
    }
    
    return height;
}

#pragma mark - SHImageModelCollectionDelegate
#pragma mark -

- (void)imageCollectionViewManager:(SHImageModelCollectionViewManager *)manager didChangeToImageAtIndex:(NSUInteger)index {
    //change the collection view to show to the current cell at the index path
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [manager.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:TRUE];
    
    [self updateImageArrows];
}

- (void)imageCollectionViewManager:(SHImageModelCollectionViewManager *)manager didSelectImageAtIndex:(NSUInteger)index {
    if (self.drink.images.count) {
        [self pushToImageAtIndex:index];
    }
}

#pragma mark - UIScrollViewDelegate
#pragma mark -

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

@end
