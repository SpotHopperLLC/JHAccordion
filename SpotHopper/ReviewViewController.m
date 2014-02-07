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
#import "SHLabelLatoLight.h"

#import "DrinkModel.h"
#import "ErrorModel.h"
#import "SpotModel.h"
#import "UserModel.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface ReviewViewController ()<UITableViewDataSource, UITableViewDelegate, ReviewSliderCellDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgImage;
@property (weak, nonatomic) IBOutlet SHLabelLatoLight *lblTitle;
@property (weak, nonatomic) IBOutlet SHLabelLatoLight *lblSubTitle;
@property (weak, nonatomic) IBOutlet SHLabelLatoLight *lblSubSubTitle;

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
    [_tblReviews setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 65.0f, 0.0f)];
    
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return _sliderTemplates.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        SliderTemplateModel *sliderTemplate = [_sliderTemplates objectAtIndex:indexPath.row];
        SliderModel *slider = nil;
        if (indexPath.row < _sliders.count) {
            slider = [_sliders objectAtIndex:indexPath.row];
        }
        
        ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
        [cell setDelegate:self];
        [cell setSliderTemplate:sliderTemplate withSlider:slider];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
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
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 40.0f;
    }
    return 0.0f;
}

#pragma mark - ReviewSliderCellDelegate

- (void)reviewSliderCell:(ReviewSliderCell *)cell changedValue:(float)value {
    NSIndexPath *indexPath = [_tblReviews indexPathForCell:cell];
    
    SliderTemplateModel *sliderTemplate = [_sliderTemplates objectAtIndex:indexPath.row];
    SliderModel *slider = nil;
    if (indexPath.row < _sliders.count) {
        slider = [_sliders objectAtIndex:indexPath.row];
    } else {
        slider = [[SliderModel alloc] init];
        [slider setSliderTemplate:sliderTemplate];
        [_sliders addObject:slider];
    }
    [slider setValue:[NSNumber numberWithInt:ceil(value * 10)]];
    
}

#pragma mark - Actions

- (IBAction)onClickSubmit:(id)sender {
    if (_review != nil) {
        
        // Submits changes for review
        [self showHUD:@"Updating"];
        [_review putReviews:^(ReviewModel *reviewModel, JSONAPI *jsonApi) {
            
            [self hideHUD];
            [self showHUDCompleted:@"Saved!" block:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
        } failure:^(ErrorModel *errorModel) {
            [self hideHUD];
            [self showAlert:@"Oops" message:errorModel.human];
        }];
        
    } else if (_drink != nil || _spot != nil) {
        
        _review = [[ReviewModel alloc] init];
        [_review setDrink:_drink];
        [_review setSpot:_spot];
        [_review setRating:@5];
        [_review setSliders:_sliders];
        
        [self showHUD:@"Submitting"];
        [_review postReviews:^(ReviewModel *reviewModel, JSONAPI *jsonApi) {
            
            [self hideHUD];
            [self showHUDCompleted:@"Saved!" block:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
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
        
        // Removing an italics
        [_lblSubSubTitle italic:NO];
        
        // Sets title
        [_lblTitle setText:_drink.name];
        
        // Sets brewery/winery
        if (_drink.spot.name.length > 0) {
            [_lblSubTitle setText:_drink.spot.name];
        } else {
            
        }
        
        // Sets ABV and stuff
        if (_drink.style.length > 0 && _drink.abv.floatValue > 0) {
            [_lblSubSubTitle setText:[NSString stringWithFormat:@"%@ - %@ ABV", _drink.style, _drink.abvPercentString]];
        } else if (_drink.style.length > 0) {
            [_lblSubSubTitle setText:_drink.style];
        } else if (_drink.abv.floatValue > 0) {
            [_lblSubSubTitle setText:[NSString stringWithFormat:@"%@ ABV", _drink.abvPercentString]];
        } else {
            [_lblSubSubTitle italic:YES];
            [_lblSubSubTitle setText:@"No style or ABV"];
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
