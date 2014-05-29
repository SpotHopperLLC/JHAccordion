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

#define kNumberOfCells 4

#import "SHSpotProfileViewController.h"
#import "SHStyleKit+Additions.h"
#import "SpotModel.h"

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    return kNumberOfCells; //todo change? is 4 hardcoded max?
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
            
            UILabel *spotType = (UILabel*)[cell viewWithTag:kLabelTagSpotType];
            
            UILabel *spotRelevancy = (UILabel*)[cell viewWithTag:kLabelTagSpotRelevancy];
            
            UILabel *spotCloseTime = (UILabel*)[cell viewWithTag:kLabelTagSpotCloseTime];
            
            UILabel *spotAddress = (UILabel*)[cell viewWithTag:kLabelTagSpotAddress];
            

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //todo put logic checking if the the spot has a special to show increase height otherwise height = 0
    return 0.0f;
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
