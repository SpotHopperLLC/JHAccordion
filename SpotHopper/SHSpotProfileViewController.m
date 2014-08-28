//
//  SHSpotDetailsViewController.m
//  SpotHopper
//
//  Created by Tracee Pettigrew on 5/29/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHSpotProfileViewController.h"

#import "SpotModel.h"
#import "LiveSpecialModel.h"
#import "SpotTypeModel.h"
#import "SliderTemplateModel.h"
#import "AverageReviewModel.h"
#import "SliderModel.h"
#import "SpecialModel.h"

#import "SHSlider.h"

#import "PhotoAlbumViewController.h"
#import "PhotoViewerViewController.h"

#import "SHStyleKit+Additions.h"
#import "NSArray+DailySpecials.h"
#import "UIView+AutoLayout.h"
#import "UIViewController+Navigator.h"

#import "SHImageModelCollectionViewManager.h"

#import "SHNotifications.h"

#import "Tracker.h"
#import "Tracker+Events.h"

#define kCellImageCollection 0
#define kCellSpotDetails 1
#define kCellSpotSpecials 2

#define kTagSpotNameLabel 1
#define kTagSpotTypeLabel 2
#define kTagSpotRelevancyLabel 3
#define kTagSpotCloseTimeLabel 4
#define kTagSpotAddressLabel 5

#define kTagSpotSpecialLabel 1
#define kTagSpotSpecialDetailsLabel 2
#define kTagSpotSpecialHoursLabel 3

#define kTagLeftVibeLabel 1
#define kTagRightVibeLabel 2
#define kTagVibeSlider 3

#define kFooterViewHeight 50.0f
#define kCutOffPoint 116.0f

#define kDefineAnimationDuration 0.25f

#define kNumberOfCells 3

#define kTopImageHeight 220.0f

#define kTagCollectionView 1
#define kTagImageView 1

#define kTagPreviousImageButton 2
#define kTagNextImageButton 3

#define kSectionImages 0
#define kSectionDetails 1
#define kSectionSpecials 2
#define kSectionSliders 3

NSString* const SpotProfileToPhotoViewer = @"SpotProfileToPhotoViewer";
NSString* const SpotProfileToPhotoAlbum = @"SpotProfileToPhotoAlbum";

NSString* const SpotSpecialLabelText = @"Specials/Happy Hour";

@interface SHSpotProfileViewController () <UITableViewDataSource, UITableViewDelegate, SHImageModelCollectionDelegate>

@property (strong, nonatomic) IBOutlet SHImageModelCollectionViewManager *imageModelCollectionViewManager;

@property (weak, nonatomic) UIButton *previousImageButton;
@property (weak, nonatomic) UIButton *nextImageButton;

@property (assign, nonatomic) NSInteger currentIndex;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *similarSpotsButton;
@property (weak, nonatomic) IBOutlet UIButton *reviewItButton;
@property (weak, nonatomic) IBOutlet UIButton *drinkMenuButton;

@property (weak, nonatomic) IBOutlet UIImageView *topShadowImageView;
@property (weak, nonatomic) UIView *footerContainerView;

@property (strong, nonatomic)  NSString *matchPercentage;
@property (strong, nonatomic)  NSString *closeTime;

@end

@implementation SHSpotProfileViewController{
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
    contentInset.bottom = kFooterViewHeight;
    scrollIndicatorInsets.bottom = kFooterViewHeight;
    self.tableView.contentInset = contentInset;
    self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
    
    CGSize buttonImageSize = CGSizeMake(30, 30);
    [SHStyleKit setButton:self.similarSpotsButton withDrawing:SHStyleKitDrawingSearchIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor size:buttonImageSize];
    [SHStyleKit setButton:self.reviewItButton withDrawing:SHStyleKitDrawingReviewsIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor size:buttonImageSize];
    [SHStyleKit setButton:self.drinkMenuButton withDrawing:SHStyleKitDrawingDrinkMenuIcon normalColor:SHStyleKitColorMyTextColor highlightedColor:SHStyleKitColorMyWhiteColor size:buttonImageSize];
    
    self.similarSpotsButton.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:12.0f];
    [self.similarSpotsButton setTitleColor:SHStyleKit.myTextColor forState:UIControlStateNormal];
    
    self.reviewItButton.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:12.0f];
    [self.reviewItButton setTitleColor:SHStyleKit.myTextColor forState:UIControlStateNormal];
    
    self.drinkMenuButton.titleLabel.font = [UIFont fontWithName:@"Lato-Light" size:12.0f];
    [self.drinkMenuButton setTitleColor:SHStyleKit.myTextColor forState:UIControlStateNormal];
    
    self.matchPercentage = [self.spot matchPercent];
    if ([self findCloseTimeForToday]) {
        self.closeTime = [self findCloseTimeForToday];
    }
    
    //fetch spot slider and review info
    [self.spot getSpot:nil success:^(SpotModel *spotModel, JSONAPI *jsonApi) {
        
        if (spotModel) {
            self.spot = spotModel;
            self.spot.sliderTemplates = spotModel.sliderTemplates;
            self.spot.averageReview = spotModel.averageReview;
            [self.tableView reloadData];
        }
        
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [Tracker trackSpotProfileScreenViewed:self.spot];
    
    [self hideTopBars:TRUE withCompletionBlock:^{
        DebugLog(@"Done hiding top bars");
    }];
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
    [SHNotifications findSimilarToSpot:self.spot];
}

- (IBAction)reviewItButtonTapped:(id)sender {
    [self goToNewReviewForSpot:self.spot];
}

- (IBAction)drinkMenuButtonTapped:(id)sender {
    [self goToMenu:self.spot];
}

#pragma mark - Private
#pragma mark -

- (NSString *)specialsForToday {
    SpecialModel *special = self.spot.specialForToday;
    
    return special.text;
}

- (UIFont *)specialTitleFont {
    return [UIFont fontWithName:@"Lato-Bold" size:20.0f];
}

- (UIFont *)specialDetailFont {
    return [UIFont fontWithName:@"Lato-Light" size:16.0f];
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
        [self.navigationController.navigationItem setTitle:self.spot.name];
        
    } completion:^(BOOL finished) {
        [self.navigationItem setTitle:self.spot.name];
        
        UIImage *backArrowImage = [[SHStyleKit drawImage:SHStyleKitDrawingArrowLeftIcon color:SHStyleKitColorMyTintColor size:CGSizeMake(30, 30)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithImage:backArrowImage style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
        self.navigationItem.leftBarButtonItem = backBarItem;
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (NSString *)findCloseTimeForToday {
    // Sets "Opens at <some time>" or "Open until <some time>"
    NSString *closeTime = nil;
    NSArray *hoursForToday = [self.spot.hoursOfOperation datesForToday];
    
    if (hoursForToday) {
        // Creates formatter
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        
        // Gets open and close dates
        NSDate *dateOpen = hoursForToday.firstObject;
        NSDate *dateClose = hoursForToday.lastObject;
        
        NSAssert(dateOpen, @"Date must be defined");
        NSAssert(dateClose, @"Date must be defined");
        
        // Sets the stuff
        NSDate *now = [NSDate date];
        if ([now timeIntervalSinceDate:dateOpen] > 0 && [now timeIntervalSinceDate:dateClose] < 0) {
            closeTime = [NSString stringWithFormat:@"Open until %@", [dateFormatter stringFromDate:dateClose]];
        } else {
            closeTime = [NSString stringWithFormat:@"Opens at %@", [dateFormatter stringFromDate:dateOpen]];
        }
    }
    
    return closeTime;
}

- (void)updateImageArrows {
    NSUInteger index = self.imageModelCollectionViewManager.currentIndex;
    
    BOOL hasNext = _spot.images.count ? (index < _spot.images.count - 1) : FALSE;
    BOOL hasPrev = _spot.images.count ? (index > 0) : FALSE;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.nextImageButton.alpha = hasNext ? 1.0 : 0.1;
        self.previousImageButton.alpha = hasPrev ? 1.0 : 0.1;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (kSectionImages == section) {
        return 1;
    }
    else if (kSectionDetails == section) {
        return 1;
    }
    else if (kSectionSpecials == section) {
        return 1;
    }
    else if (kSectionSliders == section) {
        return self.spot.averageReview.sliders.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (kSectionImages == indexPath.section) {
        static NSString *CollectionViewCellIdentifier = @"CollectionViewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
        
        UICollectionView *collectionView = (UICollectionView *)[cell viewWithTag:kTagCollectionView];
        
        self.imageModelCollectionViewManager.collectionView = collectionView;
        collectionView.delegate = self.imageModelCollectionViewManager;
        collectionView.dataSource = self.imageModelCollectionViewManager;
        self.imageModelCollectionViewManager.imageModels = self.spot.images;
        self.imageModelCollectionViewManager.placeholderImage = self.spot.placeholderImage;
        
        self.previousImageButton = (UIButton *)[cell viewWithTag:kTagPreviousImageButton];
        self.nextImageButton = (UIButton *)[cell viewWithTag:kTagNextImageButton];
        
        [self.previousImageButton addTarget:self action:@selector(previousButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.nextImageButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self updateImageArrows];
    }
    else if (kSectionDetails == indexPath.section) {
        static NSString *SpotDetailsCellIdentifier = @"SpotDetailsCell";
        cell = [tableView dequeueReusableCellWithIdentifier:SpotDetailsCellIdentifier forIndexPath:indexPath];
        
        UILabel *spotName = (UILabel*)[cell viewWithTag:kTagSpotNameLabel];
        spotName.font = [UIFont fontWithName:@"Lato-Bold" size:20.0f];
        [SHStyleKit setLabel:spotName textColor:SHStyleKitColorMyTintColor];
        spotName.text = self.spot.name;
        
        //todo:update to display the spot type as well as the expense
        UILabel *spotType = (UILabel*)[cell viewWithTag:kTagSpotTypeLabel];
        spotType.font = [UIFont fontWithName:@"Lato-LightItalic" size:18.0f];
        spotType.text = self.spot.spotType.name;
        
        UILabel *spotMatch = (UILabel*)[cell viewWithTag:kTagSpotRelevancyLabel];
        if (self.matchPercentage) {
            spotMatch.font = [UIFont fontWithName:@"Lato-LightItalic" size:18.0f];
            spotMatch.text = [NSString stringWithFormat:@"%@ Match",self.matchPercentage];
        }
        else{
            spotMatch.text = @"";
        }
        
        UILabel *spotCloseTime = (UILabel*)[cell viewWithTag:kTagSpotCloseTimeLabel];
        spotCloseTime.font = [UIFont fontWithName:@"Lato-Light" size:12.0f];
        spotCloseTime.text = self.closeTime;
        
        UILabel *spotAddress = (UILabel*)[cell viewWithTag:kTagSpotAddressLabel];
        spotAddress.font = [UIFont fontWithName:@"Lato-Light" size:12.0f];
        spotAddress.text = self.spot.addressCityState;
    }
    else if (kSectionSpecials == indexPath.section) {
        static NSString *SpotSpecialsCellIdentifier = @"SpotSpecialsCell";
        cell = [tableView dequeueReusableCellWithIdentifier:SpotSpecialsCellIdentifier forIndexPath:indexPath];
        
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:kTagSpotSpecialLabel];
        UILabel *detailsLabel = (UILabel *)[cell viewWithTag:kTagSpotSpecialDetailsLabel];
        UILabel *hoursLabel = (UILabel *)[cell viewWithTag:kTagSpotSpecialHoursLabel];

        titleLabel.font = [self specialTitleFont];
        detailsLabel.font = [self specialDetailFont];
        hoursLabel.font = [self specialDetailFont];
        
        SpecialModel *special = self.spot.specialForToday;
        detailsLabel.text = special.text.length ? special.text : @"No Special";
        hoursLabel.text = special.timeString;
    }
    else if (kSectionSliders == indexPath.section) {
        static NSString *SpotVibeIdentifier = @"SpotVibeCell";
        cell = [tableView dequeueReusableCellWithIdentifier:SpotVibeIdentifier forIndexPath:indexPath];
        
        if (indexPath.row < self.spot.averageReview.sliders.count) {
            SliderModel *sliderModel = self.spot.averageReview.sliders[indexPath.row];
            SliderTemplateModel *sliderTemplate = sliderModel.sliderTemplate;
            
            SHSlider *slider = (SHSlider *)[cell viewWithTag:kTagVibeSlider];
            UILabel *minValue = (UILabel *)[cell viewWithTag:kTagLeftVibeLabel];
            UILabel *maxValue = (UILabel *)[cell viewWithTag:kTagRightVibeLabel];
            slider.vibeFeel = TRUE;
            
            minValue.text = sliderTemplate.minLabel.length ? sliderTemplate.minLabel : nil;
            maxValue.text = sliderTemplate.maxLabel.length ? sliderTemplate.maxLabel : nil;
            [slider setSelectedValue:(sliderModel.value.floatValue / 10.0f)];
        }
        else {
            DebugLog(@"indexPath, %lu, %lu", (unsigned long)indexPath.section, (unsigned long)indexPath.row);
            NSAssert(FALSE, @"Index should never be out of range");
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // do nothing
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (kSectionImages == indexPath.section) {
        return kTopImageHeight;
    }
    else if (kSectionDetails == indexPath.section) {
        return 95.0f;
    }
    else if (kSectionSpecials == indexPath.section) {
        NSString *special = [self specialsForToday];
        
        CGFloat maxWidth = 280.f;
        CGFloat titleHeight = [self heightForString:SpotSpecialLabelText font:[self specialTitleFont] maxWidth:maxWidth];
        CGFloat detailHeight = [self heightForString:special font:[self specialDetailFont] maxWidth:maxWidth];
        
        CGFloat height = special.length ? titleHeight + detailHeight + 24.0f : 0.0f;
        
        return height;
    }
    else if (kSectionSliders == indexPath.section) {
        return 80.0f;
    }
    
    return 0.0f;
}

#pragma mark - SHImageModelCollectionDelegate
#pragma mark -

- (void)imageCollectionViewManager:(SHImageModelCollectionViewManager *)manager didChangeToImageAtIndex:(NSUInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [manager.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:TRUE];
    [self updateImageArrows];
}

- (void)imageCollectionViewManager:(SHImageModelCollectionViewManager *)manager didSelectImageAtIndex:(NSUInteger)index {
    self.currentIndex = index;
    
    if (manager.imageModels.count > 1) {
        [self performSegueWithIdentifier:SpotProfileToPhotoAlbum sender:self];
    }
    else if (manager.imageModels.count == 1) {
        [self performSegueWithIdentifier:SpotProfileToPhotoViewer sender:self];
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

#pragma mark - Navigation
#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[PhotoViewerViewController class]]) {
        PhotoViewerViewController *vc = segue.destinationViewController;
        vc.images = self.imageModelCollectionViewManager.imageModels;
        
        vc.selectedIndex = self.currentIndex;
    }
    else if ([segue.destinationViewController isKindOfClass:[PhotoAlbumViewController class]]) {
        PhotoAlbumViewController *vc = segue.destinationViewController;
        vc.images = self.imageModelCollectionViewManager.imageModels;
        
        vc.selectedIndex = self.currentIndex;
    }
}

@end
