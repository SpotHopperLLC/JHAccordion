//
//  ReviewViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "ReviewViewController.h"

#import "UIView+ViewFromNib.h"

#import "ReviewSliderCell.h"

#import "DrinkModel.h"
#import "SpotModel.h"
#import "UserModel.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface ReviewViewController ()<UITableViewDataSource, UITableViewDelegate, ReviewSliderCellDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgImage;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubSubTitle;

@property (weak, nonatomic) IBOutlet UITableView *tblReviews;

@property (nonatomic, strong) UIView *headerContent;

@end

@implementation ReviewViewController

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
    [super viewDidLoad:@[kDidLoadOptionsBlurredBackground,kDidLoadOptionsDontAdjustForIOS6]];
    
    // Sets title
    [self setTitle:@"Review It!"];
    
    // Shows sidebar button in nav
    [self showSidebarButton:YES animated:YES];
    
    // Configures table
    [_tblReviews setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_tblReviews registerNib:[UINib nibWithNibName:@"ReviewSliderCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ReviewSliderCell"];
    
    // Configure table header
    // Header content view
    _headerContent = [UIView viewFromNibNamed:@"ReviewHeaderDrinkView" withOwner:self];
    [_tblReviews setTableHeaderView:_headerContent];
    
    // Update view
    [self updateView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    return _review.sliders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *slider = [_review.sliders objectAtIndex:indexPath.row];
    
    ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
    [cell setDelegate:self];
    [cell setSliderValues:slider];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.frame), 40.0f)];
    [view setBackgroundColor:kColorOrangeLight];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 1.0f, CGRectGetWidth(tableView.frame)-20.0f, 30.f)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont fontWithName:@"Lato-Light" size:20.0f]];
    [label setMinimumScaleFactor:0.5f];
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setNumberOfLines:1];
    
    if (_review.drink != nil) {
        [label setText:[NSString stringWithFormat:@"I thought %@ was...", _review.drink.name]];
    } else if (_review.spot != nil) {
        [label setText:[NSString stringWithFormat:@"I thought %@ was...", _review.spot.name]];
    }
    
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

#pragma mark - ReviewSliderCellDelegate

- (void)reviewSliderCell:(ReviewSliderCell *)cell changedValue:(float)value {
    NSIndexPath *indexPath = [_tblReviews indexPathForCell:cell];
    
    NSLog(@"Value changed for row %d to %f", indexPath.row, value);
}

#pragma mark - Private

- (void)updateView {
    if (_review.drink != nil) {
        [_imgImage setImageWithURL:[NSURL URLWithString:_review.drink.imageUrl]];
        
        [_lblTitle setText:_review.drink.name];
        [_lblSubTitle setText:_review.drink.spot.name];
        [_lblSubSubTitle setText:[NSString stringWithFormat:@"%@ - %.02f %% ABV", _review.drink.style, _review.drink.alcoholByVolume.floatValue]];
    } else if (_review.spot != nil) {
        [_imgImage setImageWithURL:[NSURL URLWithString:_review.spot.imageUrl]];
        
        [_lblTitle setText:_review.spot.name];
        [_lblSubTitle setText:_review.spot.type];
        [_lblSubSubTitle setText:@""];
    } else {
        [_lblTitle setText:@""];
        [_lblSubTitle setText:@""];
        [_lblSubSubTitle setText:@""];
    }
}

@end
