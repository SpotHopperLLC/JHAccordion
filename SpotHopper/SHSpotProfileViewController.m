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

#import "SHStyleKit+Additions.h"
#import "NSArray+DailySpecials.h"

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

#define kCollectionViewTag 1
#define kPreviousBtnTag 2
#define kNextBtnTag 3

#define kNumberOfCells 3

@interface SHSpotProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet SHImageModelCollectionViewManager *imageModelCollectionViewManager;

@end

@implementation SHSpotProfileViewController

- (void)viewDidLoad {
    [self viewDidLoad:@[kDidLoadOptionsNoBackground]];
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
        case kCellImageCollection: {
            
                cell = [tableView dequeueReusableCellWithIdentifier:CollectionViewCellIdentifier];
                //todo: place collection view here
                
                UICollectionView *collectionView = (UICollectionView *)[cell viewWithTag:kCollectionViewTag];
            
                self.imageModelCollectionViewManager.collectionView = collectionView;
                collectionView.delegate = self.imageModelCollectionViewManager;
                collectionView.dataSource = self.imageModelCollectionViewManager;
            
                //attach previous and next buttons to goPrevious and goNext to trigger image transitions
                UIButton *previousButton = (UIButton *)[cell viewWithTag:kPreviousBtnTag];
                [previousButton addTarget:self.imageModelCollectionViewManager action:@selector(goPrevious) forControlEvents:UIControlEventTouchUpInside];
            
                UIButton *nextButton = (UIButton *)[cell viewWithTag:kNextBtnTag];
                [nextButton addTarget:self.imageModelCollectionViewManager action:@selector(goNext) forControlEvents:UIControlEventTouchUpInside];
            
                // hide and show buttons based on the number of images and current position
                previousButton.hidden = TRUE;
                nextButton.hidden = TRUE;
                break;
            }

        case kCellSpotDetails:{
            
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

            if (!(dailySpecials = self.spot.dailySpecials)) {
                UILabel *spotSpecial = (UILabel*)[cell viewWithTag:kLabelTagSpotSpecial];
                UILabel *specialDetails = (UILabel*)[cell viewWithTag:kLabelTagSpotSpecialDetails];
                
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
        default:
            //todo: place switches here (add logic for creating as many switches as vibe dictates)
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
