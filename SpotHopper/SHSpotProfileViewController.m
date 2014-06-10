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

#import "SHSlider.h"

#import "PhotoAlbumViewController.h"
#import "PhotoViewerViewController.h"
#import "SHSpotDetailFooterNavigationViewController.h"

#import "SHStyleKit+Additions.h"
#import "NSArray+DailySpecials.h"
#import "UIView+AutoLayout.h"
#import "UIViewController+Navigator.h"

#import "SHImageModelCollectionViewManager.h"

#import "Tracker.h"

#define kCellImageCollection 0
#define kCellSpotDetails 1
#define kCellSpotSpecials 2

#define kLabelTagSpotName 1
#define kLabelTagSpotType 2
#define kLabelTagSpotRelevancy 3
#define kLabelTagSpotCloseTime 4
#define kLabelTagSpotAddress 5

#define kLabelTagSpotSpecial 1
#define kLabelTagSpotSpecialDetails 2

#define kLeftLabelVibeTag 1
#define kRightLabelVibeTag 2
#define kSliderVibeTag 3

#define kCollectionViewTag 1

#define kFooterNavigationViewHeight 50.0f
#define kCutOffPoint 116.0f

#define kDefineAnimationDuration 0.25f

#define kNumberOfCells 3

NSString* const DrinkProfileToPhotoViewer = @"DrinkProfileToPhotoViewer";
NSString* const DrinkProfileToPhotoAlbum = @"DrinkProfileToPhotoAlbum";
NSString* const UnwindFromSpotProfileToHomeMapFindSimilar = @"unwindFromSpotProfileToHomeMapFindSimilar";

NSString* const SpotSpecialLabelText = @"Specials/Happy Hour";

@interface SHSpotProfileViewController () <UITableViewDataSource, UITableViewDelegate, SHImageModelCollectionDelegate, SHSpotDetailFooterNavigationDelegate>

@property (strong, nonatomic) IBOutlet SHImageModelCollectionViewManager *imageModelCollectionViewManager;

@property (assign, nonatomic) NSInteger currentIndex;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (weak, nonatomic) IBOutlet UIImageView *topShadowImageView;
@property (weak, nonatomic) UIView *footerContainerView;

@property (strong, nonatomic)  NSString *matchPercentage;
@property (strong, nonatomic)  NSString *closeTime;

@property (strong, nonatomic) SHSpotDetailFooterNavigationViewController *spotfooterNavigationViewController;

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
    
    self.spotfooterNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SHSpotDetailFooterNavigationViewController"];
    self.spotfooterNavigationViewController.delegate = self;
    
    //set bottom offset to account for the height of the footer navigation control
    UIEdgeInsets contentInset = self.tableview.contentInset;
    UIEdgeInsets scrollIndicatorInsets = self.tableview.scrollIndicatorInsets;
    contentInset.bottom = kFooterNavigationViewHeight;
    scrollIndicatorInsets.bottom = kFooterNavigationViewHeight;
    self.tableview.contentInset = contentInset;
    self.tableview.scrollIndicatorInsets = scrollIndicatorInsets;
    
    
    self.matchPercentage = [self.spot matchPercent];
    //here
    if ([self findCloseTimeForToday]) {
        self.closeTime = [self findCloseTimeForToday];
    }
    
    //fetch spot slider and review info
    [self.spot getSpot:nil success:^(SpotModel *spotModel, JSONAPI *jsonApi) {
        
        if (spotModel) {
            self.spot = spotModel;
            self.spot.sliderTemplates = spotModel.sliderTemplates;
            self.spot.averageReview = spotModel.averageReview;
            [self.tableview reloadData];
        }
        
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self hideTopBars:TRUE withCompletionBlock:^{
        DebugLog(@"Done hiding top bars");
    }];
    
    if (!self.footerContainerView && !self.spotfooterNavigationViewController.view.superview) {
        UIView *footerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kFooterNavigationViewHeight)];
        footerContainer.translatesAutoresizingMaskIntoConstraints = NO;
        footerContainer.backgroundColor = [UIColor clearColor];
        [self.view addSubview:footerContainer];
        [footerContainer pinToSuperviewEdges:JRTViewPinBottomEdge inset:0.0f usingLayoutGuidesFrom:self];
        [footerContainer pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
        [footerContainer constrainToHeight:kFooterNavigationViewHeight];
        self.footerContainerView = footerContainer;
        
        [self embedViewController:self.spotfooterNavigationViewController intoView:self.footerContainerView placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinBottomEdge inset:0.0f];
            [view pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
            [view constrainToHeight:kFooterNavigationViewHeight];
        }];
    }
}

#pragma mark -
#pragma mark -

- (void)backButtonTapped:(id)sender {
    NSLog(@"back btn tapped");
    [self performSegueWithIdentifier:@"unwindFromSpotProfileToHomeMap" sender:self];
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
            NSLog(@"# of templates:  %lu", self.spot.sliderTemplates.count);
            numberOfRows = self.spot.sliderTemplates.count;
            break;
        default:
            break;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CollectionViewCellIdentifier = @"CollectionViewCell";
    static NSString *SpotDetailsCellIdentifier = @"SpotDetailsCell";
    static NSString *SpotSpecialsCellIdentifier = @"SpotSpecialsCell";
    static NSString *SpotVibeIdentifier = @"SpotVibeCell";
    
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case kCellImageCollection: {
                    
                    cell = [tableView dequeueReusableCellWithIdentifier:CollectionViewCellIdentifier];
                    //todo: place collection view here
                    
                    UICollectionView *collectionView = (UICollectionView *)[cell viewWithTag:kCollectionViewTag];
                    
                    self.imageModelCollectionViewManager.collectionView = collectionView;
                    collectionView.delegate = self.imageModelCollectionViewManager;
                    collectionView.dataSource = self.imageModelCollectionViewManager;
                    self.imageModelCollectionViewManager.imageModels = self.spot.images;
                    
                    
                    break;
                }
                    
                case kCellSpotDetails:{
                    
                    //todo: add defensive programming for checking whether labels exist?
                    cell = [tableView dequeueReusableCellWithIdentifier:SpotDetailsCellIdentifier];
                    
                    UILabel *spotName = (UILabel*)[cell viewWithTag:kLabelTagSpotName];
                    spotName.font = [UIFont fontWithName:@"Lato-Bold" size:20.0f];
                    [SHStyleKit setLabel:spotName textColor:SHStyleKitColorMyTintColor];
                    spotName.text = self.spot.name;
                    
                    //todo:update to display the spot type as well as the expense
                    UILabel *spotType = (UILabel*)[cell viewWithTag:kLabelTagSpotType];
                    spotType.font = [UIFont fontWithName:@"Lato-LightItalic" size:18.0f];
                    spotType.text = self.spot.spotType.name;
                    
                    UILabel *spotMatch = (UILabel*)[cell viewWithTag:kLabelTagSpotRelevancy];
                    if (self.matchPercentage) {
                        spotMatch.font = [UIFont fontWithName:@"Lato-LightItalic" size:18.0f];
                        spotMatch.text = [NSString stringWithFormat:@"%@ Match",self.matchPercentage];
                    }else{
                        spotMatch.text = @"";
                    }
                    
                    UILabel *spotCloseTime = (UILabel*)[cell viewWithTag:kLabelTagSpotCloseTime];
                    spotCloseTime.font = [UIFont fontWithName:@"Lato-Light" size:12.0f];
                    spotCloseTime.text = self.closeTime;
                    
                    UILabel *spotAddress = (UILabel*)[cell viewWithTag:kLabelTagSpotAddress];
                    spotAddress.font = [UIFont fontWithName:@"Lato-Light" size:12.0f];
                    spotAddress.text = self.spot.addressCityState;
                    break;
                }
                    
                case kCellSpotSpecials:{
                    
                    cell = [tableView dequeueReusableCellWithIdentifier:SpotSpecialsCellIdentifier];
                    
                    NSArray *specials = self.spot.dailySpecials;
                    
                    if (specials.count) {
                        //todo: ask if this is needed
                        UILabel *spotSpecial = (UILabel*)[cell viewWithTag:kLabelTagSpotSpecial];
                        spotSpecial.font = [UIFont fontWithName:@"Lato-Bold" size:20.0f];
                        
                        UILabel *specialDetails = (UILabel*)[cell viewWithTag:kLabelTagSpotSpecialDetails];
                        specialDetails.font = [UIFont fontWithName:@"Lato-Light" size:16.0f];
                        
                        NSString *todaysSpecial = [specials specialsForToday];
                        
                        if (todaysSpecial) {
                            specialDetails.text = todaysSpecial;
                        }
                        
                    }
                    break;
                }
            }
            
            break;
        }
        case 1:{
            cell = [tableView dequeueReusableCellWithIdentifier:SpotVibeIdentifier];
            
            SHSlider *slider = (SHSlider*)[cell viewWithTag:kSliderVibeTag];
            UILabel *minValue = (UILabel*)[cell viewWithTag:kLeftLabelVibeTag];
            UILabel *maxValue = (UILabel*)[cell viewWithTag:kRightLabelVibeTag];
            slider.vibeFeel = TRUE;
            
            SliderModel *sliderModel = self.spot.averageReview.sliders[indexPath.row];
            SliderTemplateModel *sliderTemplate = sliderModel.sliderTemplate;
            
            minValue.text = sliderTemplate.minLabel.length ? sliderTemplate.minLabel : @"";
            maxValue.text = sliderTemplate.maxLabel.length ? sliderTemplate.maxLabel : @"";
            //todo: vv check to see if this logic is right vv
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
            NSString *todaysSpecial = [self.spot.dailySpecials specialsForToday];
            
            CGFloat heightForSpotSpecialHeaderText = [self heightForString:SpotSpecialLabelText font:[UIFont fontWithName:@"Lato-Bold" size:20.0f] maxWidth:self.tableview.frame.size.width];
            CGFloat heightForSpotSpecialDetailText = [self heightForString:todaysSpecial font:[UIFont fontWithName:@"Lato-Light" size:16.0f] maxWidth:self.tableview.frame.size.width];
            
            
            switch (indexPath.row) {
                case kCellImageCollection:
                    height = 180.0f;
                    //todo: check with Brennan
                    break;
                case kCellSpotDetails:
                    height = 110.0f;
                    //todo: check with Brennan
                    break;
                case kCellSpotSpecials:
                    // 8 + headerHeight + 5 + specialText + 8 for padding above, between and below
                    height = todaysSpecial.length ? (heightForSpotSpecialHeaderText + heightForSpotSpecialDetailText + 21.0f ) : 0.0f;
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
    [manager.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathWithIndex:index] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:TRUE];
    //todo: verify that the currentIndex being set here is not needed
}

- (void)imageCollectionViewManager:(SHImageModelCollectionViewManager *)manager didSelectImageAtIndex:(NSUInteger)index {
    //trigger segue on image selection
    self.currentIndex = index;
    
    if (manager.imageModels.count > 1) {
        [self performSegueWithIdentifier:DrinkProfileToPhotoAlbum sender:self];
    }
    else {
        [self performSegueWithIdentifier:DrinkProfileToPhotoViewer sender:self];
    }
    
}

#pragma mark - SHSpotDetailFooterNavigationDelegate
#pragma mark -
- (void)footerNavigationViewController:(SHSpotDetailFooterNavigationViewController *)vc findSimilarButtonTapped:(id)sender {
    
    [self performSegueWithIdentifier:UnwindFromSpotProfileToHomeMapFindSimilar sender:self];
}

- (void)footerNavigationViewController:(SHSpotDetailFooterNavigationViewController *)vc spotReviewButtonTapped:(id)sender {
    NSLog(@"spot review transition");
    [self goToNewReviewForSpot:self.spot];
}

- (void)footerNavigationViewController:(SHSpotDetailFooterNavigationViewController *)vc drinkMenuButtonTapped:(id)sender {
    NSLog(@"spot menu transition");
    [self goToMenu:_spot];
}

#pragma mark - UIScrollViewDelegate
#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //NSLog(@"offset: %f", scrollView.contentOffset.y);
    
    if (_topBarsClear) {
        if (scrollView.contentOffset.y > kCutOffPoint) {
            [self showTopBars:TRUE withCompletionBlock:^{
                NSLog(@"Show!");
            }];
        }
    }
    else {
        if (scrollView.contentOffset.y <= kCutOffPoint) {
            [self hideTopBars:TRUE withCompletionBlock:^{
                NSLog(@"Hide!");
            }];
        }
    }
}

#pragma mark - Private Methods
#pragma mark -

- (void)prepareAnimationForNavigationBarWithDuration:(CGFloat)duration {
    // prepare animation for navigation bar
    CATransition *animation = [CATransition animation];
    [animation setDuration:duration];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setType:kCATransitionFade];
    [self.navigationController.navigationBar.layer addAnimation:animation forKey:nil];
}

- (void)hideTopBars:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
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
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
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

- (NSString*)findCloseTimeForToday {
    // Sets "Opens at <some time>" or "Open until <some time>"
    NSString *closeTime = @"";
    NSArray *hoursForToday = [self.spot.hoursOfOperation datesForToday];
    
    
    if (hoursForToday) {
        // Creates formatter
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        
        // Gets open and close dates
        NSDate *dateOpen = hoursForToday.firstObject;
        NSDate *dateClose = hoursForToday.lastObject;
        
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

#pragma mark - Navigation
#pragma mark -

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //todo: refactor to make semantic style of Brennan
    //   if ([segue.destinationViewController isKindOfClass:[SHSpotProfileViewController class]]) {}
    
    if ([segue.destinationViewController isKindOfClass:[PhotoViewerViewController class]]) {
        PhotoViewerViewController *viewController = segue.destinationViewController;
        viewController.images = self.imageModelCollectionViewManager.imageModels;
        
        if (self.currentIndex) {
            viewController.index = self.currentIndex;
        }
        
    }else if ([segue.destinationViewController isKindOfClass:[PhotoAlbumViewController class]]){
        PhotoAlbumViewController *viewController = segue.destinationViewController;
        viewController.images = self.imageModelCollectionViewManager.imageModels;
        
        if (self.currentIndex) {
            viewController.index = self.currentIndex;
        }
    }
}

@end
