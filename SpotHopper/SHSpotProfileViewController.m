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

#import "SHSlider.h"

#import "PhotoAlbumViewController.h"
#import "PhotoViewerViewController.h"
#import "SHSpotDetailFooterNavigationViewController.h"

#import "SHStyleKit+Additions.h"
#import "NSArray+DailySpecials.h"
#import "UIView+AutoLayout.h"

#import "SHImageModelCollectionViewManager.h"

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
#define kPreviousBtnTag 2
#define kNextBtnTag 3

#define kFooterNavigationViewHeight 50.0f

#define kNumberOfCells 3

NSString* const DrinkProfileToPhotoViewer = @"DrinkProfileToPhotoViewer";
NSString* const DrinkProfileToPhotoAlbum = @"DrinkProfileToPhotoAlbum";


@interface SHSpotProfileViewController () <UITableViewDataSource, UITableViewDelegate, SHImageModelCollectionDelegate, SHSpotDetailFooterNavigationDelegate>

@property (strong, nonatomic) IBOutlet SHImageModelCollectionViewManager *imageModelCollectionViewManager;
@property (assign, nonatomic) NSInteger currentIndex;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (weak, nonatomic) UIView *footerContainerView;

@property (strong, nonatomic) SHSpotDetailFooterNavigationViewController *spotfooterNavigationViewController;

@end

@implementation SHSpotProfileViewController

#pragma mark - Lifecycle Methods
#pragma mark -

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
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
        
        [self hideCollectionContainerView:FALSE withCompletionBlock:^{
            NSLog(@"Collection container view is hidden");
        }];
    }
}

- (void)viewDidLoad {
    [self viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    [self.spot getSpot:nil success:^(SpotModel *spotModel, JSONAPI *jsonApi) {
        
        if (spotModel) {
            //self.spot = spotModel;
            self.spot.sliderTemplates = spotModel.sliderTemplates;
            self.spot.averageReview = spotModel.averageReview;
            [self.tableview reloadData];
        }
        
    } failure:^(ErrorModel *errorModel) {
        //todo: error handling
    }];
    
    self.spotfooterNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SHSpotDetailFooterNavigationViewController"];
    
//    self.spotfooterNavigationViewController = [[self spotHopperStoryboard] instantiateViewControllerWithIdentifier:@"SHSpotDetailFooterNavigationViewController"];
    self.spotfooterNavigationViewController.delegate = self;
    
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
            NSLog(@"templates:  %lu", self.spot.sliderTemplates.count);
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
                    
                    //attach previous and next buttons to goPrevious and goNext to trigger image transitions
                    UIButton *previousButton = (UIButton *)[cell viewWithTag:kPreviousBtnTag];
                    [previousButton addTarget:self.imageModelCollectionViewManager action:@selector(goPrevious) forControlEvents:UIControlEventTouchUpInside];
                    
                    UIButton *nextButton = (UIButton *)[cell viewWithTag:kNextBtnTag];
                    [nextButton addTarget:self.imageModelCollectionViewManager action:@selector(goNext) forControlEvents:UIControlEventTouchUpInside];
                    
                    [self didReachEnd:[self.imageModelCollectionViewManager hasPrevious] button:previousButton];
                    [self didReachEnd:[self.imageModelCollectionViewManager hasNext] button:nextButton];
                    
                    break;
                }
                    
                case kCellSpotDetails:{
                    
                    //todo: add defensive programming for checking whether labels exist?
                    cell = [tableView dequeueReusableCellWithIdentifier:SpotDetailsCellIdentifier];
                    
                    UILabel *spotName = (UILabel*)[cell viewWithTag:kLabelTagSpotName];
                    [SHStyleKit setLabel:spotName textColor:SHStyleKitColorMyTintColor];
                    spotName.text = self.spot.name;
                    
                    //todo:update to display the spot type as well as the expense
                    UILabel *spotType = (UILabel*)[cell viewWithTag:kLabelTagSpotType];
                    spotType.text = self.spot.spotType.name;
                    
                    UILabel *spotRelevancy = (UILabel*)[cell viewWithTag:kLabelTagSpotRelevancy];
                    spotRelevancy.text = [NSString stringWithFormat:@"%@ Match",self.spot.matchPercent];
                    
                    UILabel *spotCloseTime = (UILabel*)[cell viewWithTag:kLabelTagSpotCloseTime];
                    NSString *closeTime;
                    
                    if (!(closeTime = [self findCloseTimeForToday])) {
                        spotCloseTime.text = closeTime;
                    }
                    
                    UILabel *spotAddress = (UILabel*)[cell viewWithTag:kLabelTagSpotAddress];
                    spotAddress.text = self.spot.addressCityState;
                    break;
                }
                    
                case kCellSpotSpecials:{
                    
                    cell = [tableView dequeueReusableCellWithIdentifier:SpotSpecialsCellIdentifier];

                    NSArray *dailySpecials;
                    
                    if ((dailySpecials = self.spot.dailySpecials)) {
                        //todo: ask if this is needed
                        //UILabel *spotSpecial = (UILabel*)[cell viewWithTag:kLabelTagSpotSpecial];
                        UILabel *specialDetails = (UILabel*)[cell viewWithTag:kLabelTagSpotSpecialDetails];
                        
                        NSString *todaysSpecial = [self.spot.dailySpecials specialsForToday];
                        
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
            
            //NSLog(@"fetched slider templates: %@", self.spot.sliderTemplates);
            
            SliderTemplateModel *sliderTemplate = self.spot.sliderTemplates[indexPath.row];
            minValue.text = sliderTemplate.minLabel.length ? sliderTemplate.minLabel : @"";
            maxValue.text = sliderTemplate.maxLabel.length ? sliderTemplate.maxLabel : @"";
            [slider setSelectedValue:(sliderTemplate.defaultValue.floatValue / 10.0f)];
            
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
                    height = todaysSpecial.length ? 91.0f : 0.0f;
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
        //        [self goToPhotoAlbum:self.imageModels atIndex:indexPath.item];
    }
    else {
        [self performSegueWithIdentifier:DrinkProfileToPhotoViewer sender:self];
        //        [self goToPhotoViewer:self.imageModels atIndex:indexPath.item fromPhotoAlbum:nil];
    }
    
}

#pragma mark - SHSpotDetailFooterNavigationDelegate
#pragma mark -

//todo: implement
- (void)footerNavigationViewController:(SHSpotDetailFooterNavigationViewController *)vc findSimilarButtonTapped:(id)sender {
    
}

#pragma mark - Private Methods
#pragma mark -

- (NSString*)findCloseTimeForToday
{
    // Sets "Opens at <some time>" or "Open until <some time>"
    NSString *closeTime = @"";
    NSArray *hoursForToday = [self.spot.hoursOfOperation datesForToday];
    
    
    if (hoursForToday) {
    
        // Creats formatter
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

- (void)didReachEnd:(BOOL)hasMore button:(UIButton*)button
{
    if (hasMore) {
        button.alpha = 0.1;
        button.enabled = TRUE;
    }else{
        button.alpha = 1.0;
        button.enabled = FALSE;
    }
}

- (void)hideCollectionContainerView:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    self.footerContainerView.hidden = TRUE;
    
    LOG_FRAME(@"collectionContainerView", self.footerContainerView.frame);
    
    if (completionBlock) {
        completionBlock();
    }
}

//temp override
- (UIStoryboard*)spotHopperStoryboard {
    
    NSLog(@"storyboard name %@",self.storyboard.class);
    NSString *name = [self.storyboard valueForKey:@"name"];
    if ([name isEqualToString:@"SpotHopper(petti)"] == NO) {
        return [UIStoryboard storyboardWithName:@"SpotHopper(petti)" bundle:[NSBundle mainBundle]];
    }
    
    return self.storyboard;
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    //todo: refactor to make semantic style of Brennan
    if ([segue.identifier isEqualToString:DrinkProfileToPhotoViewer]) {
        PhotoViewerViewController *viewController = segue.destinationViewController;
        viewController.images = self.imageModelCollectionViewManager.imageModels;
        
        if (self.currentIndex) {
            viewController.index = self.currentIndex;
        }
    
    }else if ([segue.identifier isEqualToString:DrinkProfileToPhotoAlbum]){
        PhotoAlbumViewController *viewController = segue.destinationViewController;
        viewController.images = self.imageModelCollectionViewManager.imageModels;
        
        if (self.currentIndex) {
            viewController.index = self.currentIndex;
        }
    }
}


@end
