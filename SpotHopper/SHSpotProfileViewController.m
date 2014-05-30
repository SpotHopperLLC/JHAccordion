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
#import "SpotModel.h"
#import "SpotTypeModel.h"

@interface SHSpotProfileViewController () <UITableViewDataSource, UITableViewDelegate>

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
    // Do any additional setup after loading the view.
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
//    static NSString *spotDetailsCellIdentifier = @"SpotDetailsCell";
//    static NSString *spotSpecialCellIdentifier = @"SpotSpecialCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    switch (indexPath.row) {
        case kCellImageCollection:
            //todo: place collection view here
            break;
        case kCellSpotDetails:
        {
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
            //todo put logic checking if the the spot has a special to show
            UILabel *spotSpecial = (UILabel*)[cell viewWithTag:kLabelTagSpotSpecial];
            
            UILabel *specialDetails = (UILabel*)[cell viewWithTag:kLabelTagSpotSpecialDetails];
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
    //todo put logic checking if the the spot has a special to show increase height otherwise height = 0
    return 0.0f;
}

#pragma mark - Helper Methods
#pragma mark - 

- (NSString*)findCloseTimeForToday
{
    NSArray *hoursOfOperation = self.spot.hoursOfOperation;
    NSString *closeTime;
    
    if ([hoursOfOperation count]) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger day = [[calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]] weekday];
    
        switch (day) {
            case SUNDAY:
            {
                //todo: need to check what format the close time is in
                closeTime = [[hoursOfOperation firstObject] objectAtIndex:1];
                break;
                
            }
            case MONDAY:
            {
                //MONDAY = 2, so to get proper index subtract by 1
                closeTime = [[hoursOfOperation objectAtIndex: MONDAY - 1] objectAtIndex:1];
                break;
            }
            case TUESDAY:
            {
                closeTime = [[hoursOfOperation objectAtIndex: TUESDAY - 1] objectAtIndex:1];
                break;
            }
            case WEDNESDAY:
            {
                closeTime = [[hoursOfOperation objectAtIndex: WEDNESDAY - 1] objectAtIndex:1];
                break;
            }
            case THURSDAY:
            {
                closeTime = [[hoursOfOperation objectAtIndex: THURSDAY - 1] objectAtIndex:1];
                break;
            }
            case FRIDAY:
            {
                closeTime = [[hoursOfOperation objectAtIndex: FRIDAY - 1] objectAtIndex:1];
                break;
            }
            case SATURDAY:
            {
                closeTime = [[hoursOfOperation objectAtIndex: SATURDAY - 1] objectAtIndex:1];
                break;
            }
                
            default:
                break;
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
