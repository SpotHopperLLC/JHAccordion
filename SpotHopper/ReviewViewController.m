//
//  ReviewViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 1/7/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "ReviewViewController.h"

#import "UIView+ViewFromNib.h"
#import "UIView+AddBorder.h"

#import "SHButtonLatoLight.h"
#import "SectionHeaderView.h"

#import "ReviewSliderCell.h"
#import "SHLabelLatoLight.h"

#import "AdjustSliderSectionHeaderView.h"

#import "ClientSessionManager.h"
#import "DrinkModel.h"
#import "ErrorModel.h"
#import "ImageModel.h"
#import "ReviewModel.h"
#import "SpotModel.h"
#import "SpotTypeModel.h"
#import "UserModel.h"

#import "Tracker.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "JHAccordion.h"

@interface ReviewViewController ()<UITableViewDataSource, UITableViewDelegate, ReviewSliderCellDelegate, JHAccordionDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgImage;
@property (weak, nonatomic) IBOutlet SHLabelLatoLight *lblTitle;
@property (weak, nonatomic) IBOutlet SHLabelLatoLight *lblSubTitle;
@property (weak, nonatomic) IBOutlet SHLabelLatoLight *lblSubSubTitle;

@property (weak, nonatomic) IBOutlet UITableView *tblReviews;
@property (weak, nonatomic) IBOutlet SHButtonLatoLight *btnSubmit;

@property (nonatomic, strong) UIView *headerContent;

@property (nonatomic, strong) JHAccordion *accordion;
@property (nonatomic, strong) AdjustSliderSectionHeaderView *sectionHeaderAdvanced;

@property (nonatomic, strong) SliderModel *reviewRatingSlider;
@property (nonatomic, strong) NSArray *sliderTemplates;
@property (nonatomic, strong) NSMutableArray *sliders;
@property (nonatomic, strong) NSMutableArray *advancedSliders;

@property (nonatomic, strong) UIStoryboard *commonStoryboard;

@end

@implementation ReviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Sets title
    [self setTitle:@"Review It!"];
    
    // Shows sidebar button in nav
//    [self showSidebarButton:YES animated:YES];
    
    // Configures accordion
    _accordion = [[JHAccordion alloc] initWithTableView:_tblReviews];
    [_accordion setDelegate:self];
    [_accordion openSection:0];
    
    // Configures table
    [_tblReviews setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [_tblReviews registerNib:[UINib nibWithNibName:@"ReviewSliderCellView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ReviewSliderCell"];
//    [_tblReviews setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 65.0f, 0.0f)];
    
    // Configure table header
    // Header content view
    _headerContent = [UIView viewFromNibNamed:@"ReviewHeaderDrinkView" withOwner:self];
    [_tblReviews setTableHeaderView:_headerContent];
    
    if (_review != nil) {
        _drink = _review.drink;
        _spot = _review.spot;
    }
    
    // Gets review if already completed
    [self updateView];
    [self fetchReview];
}

- (NSArray *)viewOptions {
    return @[kDidLoadOptionsBlurredBackground,kDidLoadOptionsDontAdjustForIOS6];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [_btnSubmit setHidden:TRUE];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Review";
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return ( _reviewRatingSlider == nil ? 0 : 1 );
    } else if (section == 1) {
        return _sliders.count;
    } else if (section == 2) {
        return _advancedSliders.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
        [cell setDelegate:self];
        [cell setSliderTemplate:_reviewRatingSlider.sliderTemplate withSlider:_reviewRatingSlider showSliderValue:YES];
        
        return cell;
    } else if (indexPath.section == 1) {
        SliderModel *slider = [_sliders objectAtIndex:indexPath.row];
        
        ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
        [cell setDelegate:self];
        [cell setSliderTemplate:slider.sliderTemplate withSlider:slider showSliderValue:NO];
        
        return cell;
    } else if (indexPath.section == 2) {
        SliderModel *slider = [_advancedSliders objectAtIndex:indexPath.row];
        
        ReviewSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReviewSliderCell" forIndexPath:indexPath];
        [cell setDelegate:self];
        [cell setSliderTemplate:slider.sliderTemplate withSlider:slider showSliderValue:NO];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        return ( [_accordion isSectionOpened:indexPath.section] ? 77.0f : 0.0f);
    }
    
    return 77.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.frame), 40.0f)];
        [view setBackgroundColor:[UIColor clearColor]];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 1.0f, CGRectGetWidth(tableView.frame)-30.0f, 30.f)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont fontWithName:@"Lato-Light" size:16.0f]];
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
    } else if (section == 2) {
        if (_sectionHeaderAdvanced == nil) {
            
            _sectionHeaderAdvanced = [[AdjustSliderSectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tblReviews.frame), 48.0f)];
            
            [_sectionHeaderAdvanced setText:@"Advanced"];
            
            [_sectionHeaderAdvanced.btnBackground setTag:section];
            [_sectionHeaderAdvanced.btnBackground addTarget:_accordion action:@selector(onClickSection:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add borders
            [_sectionHeaderAdvanced addBottomBorder:[UIColor colorWithWhite:1.0f alpha:0.8f]];
        }
        return _sectionHeaderAdvanced;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 40.0f;
    } else if (section == 2) {
        if (_advancedSliders.count > 0) {
            return 48.0f;
        }
    }
    return 0.0f;
}

#pragma mark - JHAccordionDelegate

- (void)accordion:(JHAccordion *)accordion openingSection:(NSInteger)section {
    if (section == 2) [_sectionHeaderAdvanced setSelected:YES];
}

- (void)accordion:(JHAccordion *)accordion closingSection:(NSInteger)section {
    if (section == 2) [_sectionHeaderAdvanced setSelected:NO];
}

- (void)accordion:(JHAccordion *)accordion openedSection:(NSInteger)section {
}

- (void)accordion:(JHAccordion *)accordion closedSection:(NSInteger)section {
    
}

- (void)accordion:(JHAccordion*)accordion contentSizeChanged:(CGSize)contentSize {
    [accordion slideUpLastOpenedSection];
}

#pragma mark - ReviewSliderCellDelegate

- (void)reviewSliderCell:(ReviewSliderCell *)cell changedValue:(CGFloat)value {
    
    // Sets slider to darker/selected color for good
    [cell.slider setUserMoved:YES];
    
    NSIndexPath *indexPath = [_tblReviews indexPathForCell:cell];
    
    if (indexPath.section == 0) {
        [_reviewRatingSlider setValue:[NSNumber numberWithFloat:(value * 10)]];
    } else if (indexPath.section == 1) {
        SliderModel *slider = [_sliders objectAtIndex:indexPath.row];
        [slider setValue:[NSNumber numberWithFloat:(value * 10.0f)]];
    } else if (indexPath.section == 2) {
        SliderModel *slider = [_advancedSliders objectAtIndex:indexPath.row];
        [slider setValue:[NSNumber numberWithFloat:(value * 10.0f)]];
    }
}

- (void)reviewSliderCell:(ReviewSliderCell*)cell finishedChangingValue:(CGFloat)value {
    // move table view of sliders up a little to make the next slider visible
    [self slideCell:cell aboveTableViewMidwayPoint:_tblReviews];
    
    if (_btnSubmit.hidden) {
        [_btnSubmit setHidden:FALSE];
        [_btnSubmit setTitle:@"Submit Review" forState:UIControlStateNormal];
        
        // 1) position it below the superview (out of view)
        // 2) set to hidden = false
        // 3) animate it up into position
        // 4) update the table with insets so it will not cover sliders
        
        CGFloat buttonHeight = CGRectGetHeight(_btnSubmit.frame);
        CGFloat viewHeight = CGRectGetHeight(self.view.frame);
        
        CGRect hiddenFrame = _btnSubmit.frame;
        hiddenFrame.origin.y = viewHeight;
        _btnSubmit.frame = hiddenFrame;
        _btnSubmit.hidden = FALSE;
        [self.view bringSubviewToFront:_btnSubmit];
        
        [UIView animateWithDuration:0.5 animations:^{
            CGRect visibleFrame = _btnSubmit.frame;
            visibleFrame.origin.y = viewHeight - buttonHeight;
            _btnSubmit.frame = visibleFrame;
            _tblReviews.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, buttonHeight, 0.0f);
            _tblReviews.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, buttonHeight, 0.0f);
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - Actions

- (IBAction)onClickSubmit:(id)sender {
    
    /*
     * Make sure all required spotlist shave been modified
     */
    /*
     * Make sure all required spotlist shave been modified
     */
    if (_reviewRatingSlider != nil && _reviewRatingSlider.value == nil) {
        [self showAlert:@"Oops" message:@"Please adjust the rating slider before submitting"];
        return;
    }
    
    // Checks to make sure one value has been slid
    BOOL oneSliderSlid = NO;
    for (SliderModel *slider in _sliders) {
        if (slider.value != nil) {
            oneSliderSlid = YES;
            break;
        }
    }
    
    // Alerts if no sliders slid
    if (oneSliderSlid == NO) {
        [self showAlert:@"Oops" message:@"Please adjust at least one slider before submitting"];
        return;
    }
    
    if (_review != nil) {
        
        if (_reviewRatingSlider == nil) {
            [_review setRating:@0];
        } else {
            [_review setRating:_reviewRatingSlider.value];
        }
        
        NSMutableArray *sliders = [NSMutableArray array];
        [sliders addObjectsFromArray:_sliders];
        [sliders addObjectsFromArray:_advancedSliders];
        
        // Submits changes for review
        [self showHUD:@"Updating"];
        [_review putReviews:sliders successBlock:^(ReviewModel *reviewModel, JSONAPI *jsonApi) {
            
            [self hideHUD];
            [self showHUDCompleted:@"Saved!" block:^{
                
                if ([_delegate respondsToSelector:@selector(reviewViewController:submittedReview:)]) {
                    [_delegate reviewViewController:self submittedReview:reviewModel];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
            }];
            
        } failure:^(ErrorModel *errorModel) {
            [self hideHUD];
            [self showAlert:@"Oops" message:errorModel.human];
            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
        
    } else if (_drink != nil || _spot != nil) {
        
        _review = [[ReviewModel alloc] init];
        [_review setDrink:_drink];
        [_review setSpot:_spot];
        if (_reviewRatingSlider == nil) {
            [_review setRating:@0];
        } else {
            [_review setRating:_reviewRatingSlider.value];
        }
        
        NSMutableArray *sliders = [NSMutableArray array];
        [sliders addObjectsFromArray:_sliders];
        [sliders addObjectsFromArray:_advancedSliders];
        [_review setSliders:sliders];
        
        [Tracker track:@"Submitting Review" properties:@{@"Type" : _drink ? @"Drink" : @"Spot"}];
        [self showHUD:@"Submitting"];
        [_review postReviews:^(ReviewModel *reviewModel, JSONAPI *jsonApi) {
            
            [self hideHUD];
            [self showHUDCompleted:@"Saved!" block:^{
                [Tracker track:@"Submitted Review" properties:@{@"Success" : @TRUE}];
                
                if ([_delegate respondsToSelector:@selector(reviewViewController:submittedReview:)]) {
                    [_delegate reviewViewController:self submittedReview:reviewModel];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
            }];
            
        } failure:^(ErrorModel *errorModel) {
            [Tracker track:@"Submitted Review" properties:@{@"Success" : @FALSE}];
            
            _review = nil;
            [self hideHUD];
            [self showAlert:@"Oops" message:errorModel.human];
            [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
}

#pragma mark - Private

- (SectionHeaderView *)instantiateSectionHeaderView {
    // load the VC and get the view (to allow for easily laying out the custom section header)
    if (!_commonStoryboard) {
        _commonStoryboard = [UIStoryboard storyboardWithName:@"Common" bundle:nil];
    }
    UIViewController *vc = [_commonStoryboard instantiateViewControllerWithIdentifier:@"SectionHeaderScene"];
    SectionHeaderView *sectionHeaderView = (SectionHeaderView *)[vc.view viewWithTag:100];
    [sectionHeaderView removeFromSuperview];
    [sectionHeaderView prepareView];
    
    return sectionHeaderView;
}

- (void)initSliders {
    // Initilizes states
    if (_review != nil) {
        _drink = _review.drink;
        _spot = _review.spot;
        
        if (_review.drink != nil) {
            _reviewRatingSlider = [_review ratingSliderModel];
        }
        
        _sliders = _review.sliders.mutableCopy;
        _sliderTemplates = [_sliders valueForKey:@"sliderTemplate"];
    } else if (_drink != nil) {
        _reviewRatingSlider = [ReviewModel ratingSliderModel];
        
        _sliderTemplates = _drink.sliderTemplates;
    } else if (_spot != nil) {
        _sliderTemplates = _spot.sliderTemplates;
    }
    
    
    // Filling sliders if nil
    if (_sliders == nil) {
        _sliders = [NSMutableArray array];
        for (SliderTemplateModel *sliderTemplate in _sliderTemplates) {
            SliderModel *slider = [[SliderModel alloc] init];
            [slider setSliderTemplate:sliderTemplate];
            [_sliders addObject:slider];
        }
    }
    
    // Filling advanced sliders if nil
    if (_advancedSliders == nil) {
        _advancedSliders = [NSMutableArray array];
        
        // Moving advanced sliders into their own array
        for (SliderModel *slider in _sliders) {
            if (slider.sliderTemplate.required == NO) {
                [_advancedSliders addObject:slider];
            }
        }
        
        // Removing advances sliders from basic array
        for (SliderModel *slider in _advancedSliders) {
            [_sliders removeObject:slider];
        }
    }
    
    // Update view
    [_tblReviews reloadData];
}

- (void)updateView {
    if (_drink != nil) {

        // Sets image
        ImageModel *image = _drink.images.firstObject;
        if (image != nil) {
            [_imgImage setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:_drink.placeholderImage];
        } else {
            [_imgImage setImage:_drink.placeholderImage];
        }
        
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
        // Sets image
        ImageModel *image = _spot.images.firstObject;
        if (image != nil) {
            [_imgImage setImageWithURL:[NSURL URLWithString:image.url] placeholderImage:_spot.placeholderImage];
        } else {
            [_imgImage setImage:_spot.placeholderImage];
        }
        
        [_lblTitle setText:_spot.name];
        [_lblSubTitle setText:_spot.spotType.name];
        [_lblSubSubTitle setText:_spot.cityState];
    } else {
        [_imgImage setImage:[UIImage imageNamed:@"bar_drink_placeholder"]];
        [_lblTitle setText:@""];
        [_lblSubTitle setText:@""];
        [_lblSubSubTitle setText:@""];
    }
    
}

- (void)fetchReview {
    
    // Gets da images
    [self fetchDrink];
    [self fetchSpot];
    
    UserModel *user = [ClientSessionManager sharedClient].currentUser;
    if (user == nil) {
        return;
    }
    
    [self showHUD:@"Getting review"];
    
    NSDictionary *params = nil;
    if (_spot != nil) {
        params = @{ kReviewModelParamsSpotId : _spot.ID };
    } else if (_drink != nil) {
        params = @{ kReviewModelParamsDrinkId : _drink.ID };
    }
    
    [user getReview:params success:^(ReviewModel *reviewModel, JSONAPI *jsonApi) {
        [self hideHUD];
        
        _review = reviewModel;
        [self initSliders];

        
    } failure:^(ErrorModel *errorModel) {
        [self hideHUD];
        [self initSliders];
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)fetchDrink {
    if (_review.drink == nil) return;
    
    [_drink getDrink:nil success:^(DrinkModel *drinkModel, JSONAPI *jsonAPI) {
        _drink = drinkModel;
        [self updateView];
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)fetchSpot {
    if (_review.spot == nil) return;
    
    [_spot getSpot:nil success:^(SpotModel *spotModel, JSONAPI *jsonApi) {
        _spot = spotModel;
        [self updateView];
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

@end
