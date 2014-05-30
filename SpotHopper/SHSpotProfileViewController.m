//
//  SHSpotDetailsViewController.m
//  SpotHopper
//
//  Created by Tracee Pettigrew on 5/29/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#define kCellImageCollection 0
#define kCellSpotDetails 1
#define kCellSpotSpecials 2

#define kLabelTagSpotName 1
#define kLabelTagSpotType 2
#define kLabelTagSpotRelevancy 3
#define kLabelTagSpotCloseTime 4
#define kLabelTagSpotAddress 5
#define kLabelTagSpotSpecial 6
#define kLabelTagSpotSpecialDetails 7

#define kCollectionViewTag 10
#define kPreviousBtnTag 11
#define kNextBtnTag 12

#define kNumberOfCells 3

typedef enum{
    SUNDAY = 1,
    MONDAY,
    TUESDAY,
    WEDNESDAY,
    THURSDAY,
    FRIDAY,
    SATURDAY
} DaysOfTheWeek;

#import "SHSpotProfileViewController.h"
#import "SHStyleKit+Additions.h"
#import "NSArray+DailySpecials.h"
#import "SpotModel.h"
#import "LiveSpecialModel.h"
#import "SpotTypeModel.h"

@interface SHSpotProfileViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>


@end

@implementation SHSpotProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    return kNumberOfCells; // todo: + # of slider cells needed
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CollectionViewCellIdentifier = @"CollectionViewCell";
    static NSString *SpotDetailsCellIdentifier = @"SpotDetailsCell";
    static NSString *SpotSpecialsCellIdentifier = @"SpotSpecialsCell";
    
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case kCellImageCollection:
            cell = [tableView dequeueReusableCellWithIdentifier:CollectionViewCellIdentifier];
            //todo: place collection view here
            break;
        case kCellSpotDetails:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:SpotDetailsCellIdentifier];
            
            UILabel *spotName = (UILabel*)[cell viewWithTag:kLabelTagSpotName];
            [SHStyleKit setLabel:spotName textColor:SHStyleKitColorMyTintColor];
            spotName.text = self.spot.name;
            
            //todo:update to display the spot type as well as the expense
            UILabel *spotType = (UILabel*)[cell viewWithTag:kLabelTagSpotType];
            spotType.text = self.spot.spotType.name;
            
            UILabel *spotRelevancy = (UILabel*)[cell viewWithTag:kLabelTagSpotRelevancy];
            spotRelevancy.text = [NSString stringWithFormat:@"%@%% Match",self.spot.relevance];
            
            UILabel *spotCloseTime = (UILabel*)[cell viewWithTag:kLabelTagSpotCloseTime];
            NSString *closeTime;
            if (!(closeTime = [self findCloseTimeForToday])) {
                spotCloseTime.text = closeTime;
            }
            
            UILabel *spotAddress = (UILabel*)[cell viewWithTag:kLabelTagSpotAddress];
            spotAddress.text = self.spot.addressCityState;

            break;
        }
        case kCellSpotSpecials:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:SpotSpecialsCellIdentifier];
            
            NSArray *dailySpecials;
            UILabel *spotSpecial = (UILabel*)[cell viewWithTag:kLabelTagSpotSpecial];
            UILabel *specialDetails = (UILabel*)[cell viewWithTag:kLabelTagSpotSpecialDetails];

            if (!(dailySpecials = self.spot.dailySpecials)) {
                LiveSpecialModel *liveSpecial = [self.spot currentLiveSpecial];
                NSString *todaysSpecial = [dailySpecials specialsForToday];

                if (!liveSpecial) {
                    spotSpecial.text = @"Live Special!";
                    specialDetails.text = liveSpecial.text;
        
                } else if (!todaysSpecial) {
                    spotSpecial.text = @"Current Special!";
                    specialDetails.text = todaysSpecial;
                }
            }
    
            break;
        }
        case 3:
            //todo: place switches here (add logic for creating as many switches as vibe dictates)
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    
    switch (indexPath.row) {
        case kCellImageCollection:
            height = 178.0f;
            //todo: check with Brennan
            break;
        case kCellSpotDetails:
            height = 131.0f;
            //todo: check with Brennan
            break;
        case kCellSpotSpecials:
            height = (!self.spot.dailySpecials) ? 91.0f : 0.0f;
            break;
        default:
            //todo: figure out height of the slider cells
            height = 0.0f;
            break;
    }
    return height;
}

#pragma mark - Helper Methods
#pragma mark - 

- (NSString*)findCloseTimeForToday
{
    // Sets "Opens at <some time>" or "Open until <some time>"
    NSString *closeTime = @"";
    NSArray *hoursForToday = [self.spot.hoursOfOperation datesForToday];
    
    if (!hoursForToday) {
    
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

#pragma mark - CollectionView buttons
#pragma mark -
//
//- (IBAction)onClickImagePrevious:(id)sender {
//    NSArray *indexPaths = [_collectionView indexPathsForVisibleItems];
//    
//    // Makes sure we have an index path
//    if (indexPaths.count > 0) {
//        
//        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
//        // Makes sure we can go back
//        if (indexPath.row > 0) {
//            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:indexPath.section] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                [self updateImageArrows];
//            });
//        }
//    }
//}
//
//- (IBAction)onClickImageNext:(id)sender {
//    NSArray *indexPaths = [_collectionView indexPathsForVisibleItems];
//    
//    // Makes sure we have an index path
//    if (indexPaths.count > 0) {
//        
//        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
//        // Makes sure we can go forward
//        if (indexPath.row < ( [self collectionView:_collectionView numberOfItemsInSection:indexPath.section] - 1) ) {
//            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                [self updateImageArrows];
//            });
//        }
//    }
//}
//
//
//- (NSIndexPath *)indexPathForCurrentImage {
//    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
//    if (indexPaths.count) {
//        return indexPaths[0];
//    }
//    
//    return nil;
//}
//
//- (void)updateImageArrows {
//    NSIndexPath *indexPath = [self indexPathForCurrentImage];
//    
//    BOOL hasNext = self.spot.images.count ? (indexPath.item < self.spot.images.count - 1) : FALSE;
//    BOOL hasPrev = self.spot.images.count ? (indexPath.item > 0) : FALSE;
//    
//    [UIView animateWithDuration:0.25 animations:^{
//        self.btnImageNext.alpha = hasNext ? 1.0 : 0.1;
//        self.btnImagePrev.alpha = hasPrev ? 1.0 : 0.1;
//    } completion:^(BOOL finished) {
//    }];
//}
//
//

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
