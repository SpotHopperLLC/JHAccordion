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
#import "ErrorModel.h"
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

@property (nonatomic, strong) NSArray *sliderTemplates;
@property (nonatomic, strong) NSMutableArray *sliders;

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
    
    // Initilizes states
    if (_review != nil) {
        _drink = _review.drink;
        _spot = _review.spot;
        
        _sliders = _review.sliders.mutableCopy;
        _sliderTemplates = [_sliders valueForKey:@"sliderTemplate"];
    } else if (_drink != nil) {
        _sliderTemplates = _drink.sliderTemplates;
    } else if (_spot != nil) {
        _sliderTemplates = _spot.sliderTemplates;
    }
    
    if (_sliders == nil) {
        _sliders = [NSMutableArray array];
    }
    
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
    return _sliderTemplates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SliderTemplateModel *sliderTemplate = [_sliderTemplates objectAtIndex:indexPath.row];
    SliderModel *slider = [_sliders objectAtIndex:indexPath.row];
    
    ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
    [cell setDelegate:self];
    [cell setSliderTemplate:sliderTemplate withSlider:slider];
    
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
    
    if (_drink != nil) {
        [label setText:[NSString stringWithFormat:@"I thought %@ was...", _drink.name]];
    } else if (_spot != nil) {
        [label setText:[NSString stringWithFormat:@"I thought %@ was...", _spot.name]];
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
    
    SliderModel *slider = nil;
    if (indexPath.row > _sliders.count) {
        slider = [[SliderModel alloc] init];
        [_sliders addObject:slider];
    } else {
        slider = [_sliders objectAtIndex:indexPath.row];
    }
    [slider setValue:[NSNumber numberWithInt:ceil(value * 10)]];
    
}

#pragma mark - Actions

- (IBAction)onClickSubmit:(id)sender {
    if (_review != nil) {
        
        // Submits changes for review
        [self showHUD:@"Submitting"];
        [_review putReviews:^(ReviewModel *reviewModel, JSONAPI *jsonApi) {
            [self hideHUD];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(ErrorModel *errorModel) {
            [self hideHUD];
            [self showAlert:@"Oops" message:errorModel.human];
        }];
        
    }
}

#pragma mark - Private

- (void)updateView {
    if (_drink != nil) {
        [_imgImage setImageWithURL:[NSURL URLWithString:_drink.imageUrl]];
        
        [_lblTitle setText:_drink.name];
        [_lblSubTitle setText:_drink.spot.name];
        if (_drink.style.length > 0 && _drink.abv.floatValue > 0) {
            [_lblSubSubTitle setText:[NSString stringWithFormat:@"%@ - %@ ABV", _drink.style, _drink.abvPercentString]];
        } else if (_drink.style.length > 0) {
            [_lblSubSubTitle setText:_drink.style];
        } else if (_drink.abv.floatValue > 0) {
            [_lblSubSubTitle setText:[NSString stringWithFormat:@"%@ ABV", _drink.abvPercentString]];
        } else {
            [_lblSubSubTitle setText:@""];
        }
    } else if (_spot != nil) {
        [_imgImage setImageWithURL:[NSURL URLWithString:_spot.imageUrl]];
        
        [_lblTitle setText:_spot.name];
        [_lblSubTitle setText:_spot.type];
        [_lblSubSubTitle setText:@""];
    } else {
        [_lblTitle setText:@""];
        [_lblSubTitle setText:@""];
        [_lblSubSubTitle setText:@""];
    }
}

@end
