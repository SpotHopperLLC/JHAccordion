//
//  SHCollectionViewTableManager.m
//  SpotHopper
//
//  Created by Brennan Stehling on 9/17/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHCollectionViewTableManager.h"

#import "SHAppContext.h"
#import "SHNotifications.h"

#import "AppDelegate.h"
#import "SpotModel.h"
#import "DrinkModel.h"
#import "AverageReviewModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"
#import "SpecialModel.h"
#import "RatingSwooshView.h"

#import "SHButton.h"
#import "SHStyleKit+Additions.h"
#import "NetworkHelper.h"
#import "Tracker.h"
#import "TellMeMyLocation.h"

#import "UIAlertView+Block.h"

#define kRowNameSpotSummary @"Spot Summary"
#define kRowNameSummarySliders @"Summary Sliders"
#define kRowNameDescription @"Description"
#define kRowNameHoursAndPhone @"Hours and Phone"
#define kRowNamePhotosAndReview @"Photos and Review"
#define kRowNameTodaysSpecial @"Today's Special"
#define kRowNameDrinkSummary @"Drink Summary"
#define kRowNameHighestRated @"Highest Rated"

#define kMeterToMile 0.000621371f

typedef enum {
    TableManagerModeNone,
    Special,
    Spot,
    Drink,
} TableManagerMode;

#pragma mark - Class Extension
#pragma mark -

@interface SHCollectionViewTableManager () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, assign) TableManagerMode mode;
@property (nonatomic, strong) SpotModel *spot;
@property (nonatomic, strong) DrinkModel *drink;

@property (nonatomic, strong) NSArray *summarySliders;
@property (nonatomic, strong) NSMutableArray *rows;

@end

@implementation SHCollectionViewTableManager

- (void)manageTableView:(UITableView *)tableView forTodaysSpecialAtSpot:(SpotModel *)spot {
    NSAssert(tableView, @"Table View is required");
    NSAssert(self.delegate, @"Delegate is required");
    self.mode = Special;
    tableView.dataSource = self;
    tableView.delegate = self;
    self.rows = @[].mutableCopy;
    
    self.tableView = tableView;
    [tableView reloadData];
    
    [spot fetchSpot:^(SpotModel *spotModel) {
        self.spot = spotModel;
        
        [self prepareSummarySliders];
        
        [self.rows addObject:kRowNameSpotSummary];
        
        if (self.summarySliders.count) {
            [self.rows addObject:kRowNameSummarySliders];
        }
        
        if (self.spot.descriptionOfSpot.length) {
            [self.rows addObject:kRowNameDescription];
        }
        
        if (self.spot.hoursForToday.length || self.spot.phoneNumber.length) {
            [self.rows addObject:kRowNameHoursAndPhone];
        }
        
        [self.rows addObject:kRowNamePhotosAndReview];
        
        [self.tableView reloadData];
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 180, 0);
        self.tableView.scrollIndicatorInsets = tableView.contentInset;
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)manageTableView:(UITableView *)tableView forSpot:(SpotModel *)spot {
    NSAssert(tableView, @"Table View is required");
    NSAssert(self.delegate, @"Delegate is required");
    self.mode = Spot;
    tableView.dataSource = self;
    tableView.delegate = self;
    self.rows = @[].mutableCopy;
    
    self.tableView = tableView;
    [tableView reloadData];
    
    [spot fetchSpot:^(SpotModel *spotModel) {
        self.spot = spotModel;
        
#ifdef NDEBUG
        // set phone number during development
        self.spot.phoneNumber = @"4148031004";
#endif
        
        [self prepareSummarySliders];
        
        if (self.summarySliders.count) {
            [self.rows addObject:kRowNameSummarySliders];
        }
        
        if (self.spot.descriptionOfSpot.length) {
            [self.rows addObject:kRowNameDescription];
        }
        
        if (self.spot.hoursForToday.length || self.spot.phoneNumber.length) {
            [self.rows addObject:kRowNameHoursAndPhone];
        }
        
        NSString *specialForToday = [self specialForToday];
        if (specialForToday.length) {
            [self.rows addObject:kRowNameTodaysSpecial];
        }
        
        [self.rows addObject:kRowNamePhotosAndReview];
        
        [self.tableView reloadData];
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 180, 0);
        self.tableView.scrollIndicatorInsets = tableView.contentInset;
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)manageTableView:(UITableView *)tableView forDrink:(DrinkModel *)drink {
    NSAssert(tableView, @"Table View is required");
    NSAssert(self.delegate, @"Delegate is required");
    self.mode = Drink;
    tableView.dataSource = self;
    tableView.delegate = self;
    self.rows = @[].mutableCopy;
    
    self.tableView = tableView;
    [tableView reloadData];
    
    [drink fetchDrink:^(DrinkModel *drinkModel) {
        self.drink = drinkModel;
        NSAssert(self.drink.averageReview.sliders.count, @"Sliders are required");
        
        [self prepareSummarySliders];
        
        if (self.summarySliders.count) {
            [self.rows addObject:kRowNameSummarySliders];
        }
        
        if (self.drink.descriptionOfDrink.length) {
            [self.rows addObject:kRowNameDescription];
        }
        
        if (self.drink.isBeer && self.drink.abv.floatValue > 0.0f) {
            [self.rows addObject:kRowNameDrinkSummary];
        }
        else if (self.drink.isWine) {
            [self.rows addObject:kRowNameDrinkSummary];
        }
        
        [self.rows addObject:kRowNamePhotosAndReview];
        
        [self.tableView reloadData];
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 180, 0);
        self.tableView.scrollIndicatorInsets = tableView.contentInset;
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)prepareForReuse {
    self.mode = TableManagerModeNone;
    self.tableView = nil;
    self.spot = nil;
    self.drink = nil;
    self.summarySliders = nil;
    self.rows = nil;
}

#pragma mark - Private
#pragma mark -

- (void)prepareSummarySliders {
    if (self.spot) {
        NSArray *spotSliders = self.spot.averageReview.sliders;
        NSArray *spotlistSliders = [SHAppContext defaultInstance].spotlistRequest.sliders;
        
        if (spotlistSliders) {
            for (SliderModel *spotSlider in spotSliders) {
                for (SliderModel *spotlistSlider in spotlistSliders) {
                    if (spotlistSlider.starred) {
                        if ([spotSlider isEqual:spotlistSlider]) {
                            spotSlider.starred = spotlistSlider.starred;
                        }
                    }
                }
            }
        }
    
        self.summarySliders = [self extractSummarySliders:spotSliders];
    }
    else if (self.drink) {
        NSArray *drinkSliders = self.drink.averageReview.sliders;
        NSArray *drinklistSliders = [SHAppContext defaultInstance].drinkListRequest.sliders;
        
        for (SliderModel *drinkSlider in drinkSliders) {
            for (SliderModel *drinklistSlider in drinklistSliders) {
                if ([drinkSlider isEqual:drinklistSlider]) {
                    drinkSlider.starred = drinklistSlider.starred;
                }
            }
        }
        
        self.summarySliders = [self extractSummarySliders:drinkSliders];
    }
}

- (NSArray *)extractSummarySliders:(NSArray *)allSliders {
    NSArray *sorted = [allSliders sortedArrayUsingComparator:^NSComparisonResult(SliderModel *slider1, SliderModel *slider2) {
        return [slider1 compare:slider2];
    }];
    
    // limit to 3
    if (sorted.count > 3) {
        sorted = [sorted subarrayWithRange:NSMakeRange(0, 3)];
    }
    
    return sorted;
}

- (NSString *)nameForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.rows.count) {
        return self.rows[indexPath.row];
    }
    
    return nil;
}

- (CGFloat)heightForString:(NSString *)text font:(UIFont *)font maxWidth:(CGFloat)maxWidth {
    if (![text isKindOfClass:[NSString class]] || !text.length) {
        // no text means no height
        return 0;
    }
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary *attributes = @{ NSFontAttributeName : font };
    CGSize size = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:options attributes:attributes context:nil].size;
    CGFloat height = ceilf(size.height) + 1; // add 1 point as padding
    
    return height;
}

- (NSString *)specialForToday {
    SpecialModel *special = self.spot.specialForToday;
    return special.text;
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)moreButtonTapped:(id)sender {
    if (self.spot) {
        if ([self.delegate respondsToSelector:@selector(collectionViewTableManager:displaySpot:)]) {
            [self.delegate collectionViewTableManager:self displaySpot:self.spot];
        }
    }
    else if (self.drink) {
        if ([self.delegate respondsToSelector:@selector(collectionViewTableManager:displayDrink:)]) {
            [self.delegate collectionViewTableManager:self displayDrink:self.drink];
        }
    }
}

- (IBAction)phoneButtonTapped:(id)sender {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *formattedPhoneNumber = self.spot.formattedPhoneNumber;
    
    if ([appDelegate canPhone] || [appDelegate canSkype]) {
        if (self.spot.phoneNumber.length) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Do you want to call?" message:formattedPhoneNumber delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    DebugLog(@"calling");
                    
                    if ([appDelegate canPhone]) {
                        [appDelegate callPhoneNumber:formattedPhoneNumber];
                    }
                    else if ([appDelegate canSkype]) {
                        [appDelegate skypePhoneNumber:formattedPhoneNumber];
                    }
                }
            }];
        }
    }
    else {
        [UIPasteboard generalPasteboard].string = self.spot.phoneNumber;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Phone" message:@"Your iOS device cannot make phone calls. Please install Skype if you'd like to call this number. The number has also been copied so you can paste it into any app you choose." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)photosButtonTapped:(id)sender {
    if (self.spot) {
        [SHNotifications showPhotosForSpot:self.spot];
    }
    else if (self.drink) {
        [SHNotifications showPhotosForDrink:self.drink];
    }
}

- (IBAction)reviewButtonTapped:(id)sender {
    if (self.spot) {
        [SHNotifications reviewSpot:self.spot];
    }
    else if (self.drink) {
        [SHNotifications reviewDrink:self.drink];
    }
}

#pragma mark - Rendering Cells
#pragma mark -

- (UITableViewCell *)renderCellForAboutSpotAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AboutSpotCell" forIndexPath:indexPath];

    CLLocation *spotLocation = [[CLLocation alloc] initWithLatitude:[self.spot.latitude floatValue] longitude:[self.spot.longitude floatValue]];
    CLLocation *currentLocation = [TellMeMyLocation currentLocation];
    CLLocationDistance meters = [currentLocation distanceFromLocation:spotLocation];
    
    CGFloat miles = meters * kMeterToMile;

    UILabel *distanceLabel = (UILabel *)[cell viewWithTag:2];
    
    distanceLabel.text =  [NSString stringWithFormat:@"%0.1f miles away", miles];
    
    return cell;
}

- (UITableViewCell *)renderCellForSummarySlidersAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SummarySlidersCell" forIndexPath:indexPath];

    UILabel *leftLabel1 = (UILabel *)[cell viewWithTag:101];
    UILabel *leftLabel2 = (UILabel *)[cell viewWithTag:201];
    UILabel *leftLabel3 = (UILabel *)[cell viewWithTag:301];

    UILabel *rightLabel1 = (UILabel *)[cell viewWithTag:102];
    UILabel *rightLabel2 = (UILabel *)[cell viewWithTag:202];
    UILabel *rightLabel3 = (UILabel *)[cell viewWithTag:302];
    
    RatingSwooshView *ratingSwooshView1 = (RatingSwooshView *)[cell viewWithTag:103];
    RatingSwooshView *ratingSwooshView2 = (RatingSwooshView *)[cell viewWithTag:203];
    RatingSwooshView *ratingSwooshView3 = (RatingSwooshView *)[cell viewWithTag:303];

    SHButton *moreButton = (SHButton *)[cell viewWithTag:4];
    
    moreButton.drawing = SHStyleKitDrawingMoreIcon;
    moreButton.normalColor = SHStyleKitColorMyTintColor;
    moreButton.highlightedColor = SHStyleKitColorMyTextColor;
    
    [moreButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [moreButton addTarget:self action:@selector(moreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.summarySliders.count > 0) {
        SliderModel *slider = self.summarySliders[0];
        //DebugLog(@"value: %@", slider.value);
        CGFloat percentage = slider.value.floatValue*10;
        leftLabel1.text = slider.sliderTemplate.minLabelShortDisplayed;
        rightLabel1.text = slider.sliderTemplate.maxLabelShortDisplayed;
        ratingSwooshView1.percentage = percentage;
    }
    else {
        leftLabel1.text = nil;
        rightLabel1.text = nil;
        ratingSwooshView1.image = nil;
    }
    
    if (self.summarySliders.count > 1) {
        SliderModel *slider = self.summarySliders[1];
        CGFloat percentage = slider.value.floatValue*10;
        leftLabel2.text = slider.sliderTemplate.minLabelShortDisplayed;
        rightLabel2.text = slider.sliderTemplate.maxLabelShortDisplayed;
        ratingSwooshView2.percentage = percentage;
    }
    else {
        leftLabel2.text = nil;
        rightLabel2.text = nil;
        ratingSwooshView2.image = nil;
    }

    if (self.summarySliders.count > 2) {
        SliderModel *slider = self. summarySliders[2];
        CGFloat percentage = slider.value.floatValue*10;
        leftLabel3.text = slider.sliderTemplate.minLabelShortDisplayed;
        rightLabel3.text = slider.sliderTemplate.maxLabelShortDisplayed;
        ratingSwooshView3.percentage = percentage;
    }
    else {
        leftLabel3.text = nil;
        rightLabel3.text = nil;
        ratingSwooshView3.image = nil;
    }

    return cell;
}

- (UITableViewCell *)renderCellForDescriptionAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DescriptionCell" forIndexPath:indexPath];
    
    NSString *description = nil;
    
    if (self.mode == Special || self.mode == Spot) {
        description = self.spot.descriptionOfSpot;
    }
    else if (self.mode == Drink) {
        description = self.drink.descriptionOfDrink;
    }
    
    UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:1];
    descriptionLabel.text = description;
    
    return cell;
}

- (UITableViewCell *)renderCellForHoursAndPhoneAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HoursAndPhoneCell" forIndexPath:indexPath];
    
    UIImageView *clockImageView = (UIImageView *)[cell viewWithTag:1];
    UIImageView *phoneImageView = (UIImageView *)[cell viewWithTag:3];
    
    UILabel *hoursLabel = (UILabel *)[cell viewWithTag:2];
    UIButton *phoneButton = (UIButton *)[cell viewWithTag:4];
    
    [phoneButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [phoneButton addTarget:self action:@selector(phoneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    
    [SHStyleKit setButton:phoneButton normalTextColor:SHStyleKitColorMyTintColor highlightedTextColor:SHStyleKitColorMyTextColor];
    
    NSString *hoursForToday = self.spot.hoursForToday;
    
    CGSize size = CGSizeMake(30.0f, 30.0f);
    
    if (hoursForToday.length) {
        hoursLabel.text = hoursForToday;
        clockImageView.image = [SHStyleKit drawImage:SHStyleKitDrawingClockIcon color:SHStyleKitColorMyTextColor size:size];
    }
    else {
        hoursLabel.text = nil;
        clockImageView.image = nil;
    }
    
    if (self.spot.phoneNumber.length) {
        [phoneButton setTitle:self.spot.formattedPhoneNumber forState:UIControlStateNormal];
        phoneImageView.image = [SHStyleKit drawImage:SHStyleKitDrawingPhoneIcon color:SHStyleKitColorMyTintColor size:size];
    }
    else {
        [phoneButton setTitle:@"" forState:UIControlStateNormal];
        phoneImageView.image = nil;
    }
    
    return cell;
}

- (UITableViewCell *)renderCellForPhotosAndReviewAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PhotosAndReviewCell" forIndexPath:indexPath];
    
    UIButton *photoImageButton = (UIButton *)[cell viewWithTag:1];
    SHButton *reviewImageButton = (SHButton *)[cell viewWithTag:4];
    
    UIButton *photoButton = (UIButton *)[cell viewWithTag:2];
    UIButton *reviewButton = (UIButton *)[cell viewWithTag:3];
    
    [SHStyleKit setButton:photoButton normalTextColor:SHStyleKitColorMyTintColor highlightedTextColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setButton:reviewButton normalTextColor:SHStyleKitColorMyTintColor highlightedTextColor:SHStyleKitColorMyTextColor];
    
    photoButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    if (self.spot) {
        [reviewButton setTitle:@"Review Spot" forState:UIControlStateNormal];
    }
    else if (self.drink) {
        if (self.drink.isBeer) {
            [reviewButton setTitle:@"Review Beer" forState:UIControlStateNormal];
        }
        else if (self.drink.isCocktail) {
            [reviewButton setTitle:@"Review Cocktail" forState:UIControlStateNormal];
        }
        else if (self.drink.isWine) {
            [reviewButton setTitle:@"Review Wine" forState:UIControlStateNormal];
        }
    }
    
    ImageModel *imageModel = nil;

    if (self.mode == Special || self.mode == Spot) {
        imageModel = self.spot.highlightImage;
    }
    else if (self.mode == Drink) {
        imageModel = self.drink.highlightImage;
    }
    
    if (imageModel) {
        [NetworkHelper loadImage:imageModel placeholderImage:nil withThumbImageBlock:^(UIImage *thumbImage) {
            [photoImageButton setImage:thumbImage forState:UIControlStateNormal];
        } withFullImageBlock:^(UIImage *fullImage) {
            [photoImageButton setImage:fullImage forState:UIControlStateNormal];
        } withErrorBlock:^(NSError *error) {
            [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
        }];
    }
    
    reviewImageButton.drawing = SHStyleKitDrawingReviewsIcon;
    reviewImageButton.normalColor = SHStyleKitColorMyTintColor;
    reviewImageButton.highlightedColor = SHStyleKitColorMyTextColor;
    
    [photoImageButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [photoImageButton addTarget:self action:@selector(photosButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [reviewImageButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [reviewImageButton addTarget:self action:@selector(reviewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [photoButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [photoButton addTarget:self action:@selector(photosButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [reviewButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [reviewButton addTarget:self action:@selector(reviewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (UITableViewCell *)renderCellForTodaysSpecialAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TodaysSpecialCell" forIndexPath:indexPath];
    
    UILabel *specialLabel = (UILabel *)[cell viewWithTag:2];
    specialLabel.text = [self specialForToday];
    
    return cell;
}

- (UITableViewCell *)renderCellForBeerSummaryAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BeerSummaryCell" forIndexPath:indexPath];
    
    UILabel *abvLabel = (UILabel *)[cell viewWithTag:1];
    abvLabel.text = [NSString stringWithFormat:@"%@ ABV", self.drink.abvPercentString];
    
    return cell;
}

- (UITableViewCell *)renderCellForWineSummaryAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WineSummaryCell" forIndexPath:indexPath];
    
    UILabel *abvLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *vintageLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *varietalLabel = (UILabel *)[cell viewWithTag:3];
    
    if (self.drink.abv.floatValue > 0) {
        abvLabel.text = self.drink.abvPercentString;
    }
    else {
        abvLabel.text = nil;
    }
    if (self.drink.vintage) {
        vintageLabel.text = [NSString stringWithFormat:@"%@", self.drink.vintage];
    }
    else {
        vintageLabel.text = nil;
    }
    if (self.drink.varietal.length) {
        varietalLabel.text = self.drink.varietal;
    }
    else {
        varietalLabel.text = nil;
    }
    
    return cell;
}

- (UITableViewCell *)renderCellForCocktailSummaryAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CocktailSummaryCell" forIndexPath:indexPath];
    
    // Note: There is nothing to display here currently.
    
    return cell;
}

- (UITableViewCell *)renderCellForErrorAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ErrorCell" forIndexPath:indexPath];
    
    NSString *rowName = [self nameForRowAtIndexPath:indexPath];
    
    UILabel *errorLabel = (UILabel *)[cell viewWithTag:1];
    errorLabel.text = [NSString stringWithFormat:@"Error at %lu, %lu (%@)", (unsigned long)indexPath.section, (unsigned long)indexPath.row, rowName];
    
    return cell;
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    NSString *rowName = [self nameForRowAtIndexPath:indexPath];
    
    if (self.mode == Special) {
        if ([rowName isEqualToString:kRowNameSpotSummary]) {
            cell = [self renderCellForAboutSpotAtIndexPath:indexPath];
        }
        else if ([rowName isEqualToString:kRowNameSummarySliders]) {
            cell = [self renderCellForSummarySlidersAtIndexPath:indexPath];
        }
        else if ([rowName isEqualToString:kRowNameDescription]) {
            cell = [self renderCellForDescriptionAtIndexPath:indexPath];
        }
        else if ([rowName isEqualToString:kRowNameHoursAndPhone]) {
            cell = [self renderCellForHoursAndPhoneAtIndexPath:indexPath];
        }
        else if ([rowName isEqualToString:kRowNamePhotosAndReview]) {
            cell = [self renderCellForPhotosAndReviewAtIndexPath:indexPath];
        }
        else {
            cell = [self renderCellForErrorAtIndexPath:indexPath];
        }
    }
    else if (self.mode == Spot) {
        if ([rowName isEqualToString:kRowNameSummarySliders]) {
            cell = [self renderCellForSummarySlidersAtIndexPath:indexPath];
        }
        else if ([rowName isEqualToString:kRowNameDescription]) {
            cell = [self renderCellForDescriptionAtIndexPath:indexPath];
        }
        else if ([rowName isEqualToString:kRowNameTodaysSpecial]) {
            cell = [self renderCellForTodaysSpecialAtIndexPath:indexPath];
        }
        else if ([rowName isEqualToString:kRowNameHoursAndPhone]) {
            cell = [self renderCellForHoursAndPhoneAtIndexPath:indexPath];
        }
        else if ([rowName isEqualToString:kRowNamePhotosAndReview]) {
            cell = [self renderCellForPhotosAndReviewAtIndexPath:indexPath];
        }
        else {
            cell = [self renderCellForErrorAtIndexPath:indexPath];
        }
    }
    else if (self.mode == Drink) {
        if ([rowName isEqualToString:kRowNameSummarySliders]) {
            cell = [self renderCellForSummarySlidersAtIndexPath:indexPath];
        }
        else if ([rowName isEqualToString:kRowNameDescription]) {
            cell = [self renderCellForDescriptionAtIndexPath:indexPath];
        }
        else if ([rowName isEqualToString:kRowNameDrinkSummary]) {
            if (self.drink.isBeer) {
                cell = [self renderCellForBeerSummaryAtIndexPath:indexPath];
            }
            else if (self.drink.isWine) {
                cell = [self renderCellForWineSummaryAtIndexPath:indexPath];
            }
        }
        else if ([rowName isEqualToString:kRowNamePhotosAndReview]) {
            cell = [self renderCellForPhotosAndReviewAtIndexPath:indexPath];
        }
        else {
            cell = [self renderCellForErrorAtIndexPath:indexPath];
        }
    }

    if (!cell) {
        DebugLog(@"Index Path: %lu, %lu", (unsigned long)indexPath.section, (unsigned long)indexPath.row);
        NSAssert(FALSE, @"Cell must be defined");
    }
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    selectedBackgroundView.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = selectedBackgroundView;
    
    return cell;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *rowName = [self nameForRowAtIndexPath:indexPath];
    
    if ([rowName isEqualToString:kRowNameSummarySliders]) {
        return 60.0f;
    }
    else if ([rowName isEqualToString:kRowNameDescription]) {
        NSString *text = nil;
        if (self.mode == Special || self.mode == Spot) {
            text = self.spot.descriptionOfSpot;
        }
        else if (self.mode == Drink) {
            text = self.drink.descriptionOfDrink;
        }
        
        UIFont *font = [UIFont fontWithName:@"Lato-Light" size:14.0f];
        CGFloat height = [self heightForString:text font:font maxWidth:300.0f] + 20.0f;
        
        return height;
    }
    else if ([rowName isEqualToString:kRowNameHoursAndPhone]) {
        return 44.0f;
    }
    else if ([rowName isEqualToString:kRowNameTodaysSpecial]) {
        NSString *text = [self specialForToday];
        UIFont *font = [UIFont fontWithName:@"Lato-Light" size:14.0f];
        CGFloat height = [self heightForString:text font:font maxWidth:300.0f] + 53.0f;
        
        return height;
    }
    else if ([rowName isEqualToString:kRowNameDrinkSummary]) {
        return 30.0f;
    }
    else if ([rowName isEqualToString:kRowNamePhotosAndReview]) {
        return 50.0f;
    }
    else if ([rowName isEqualToString:kRowNameHighestRated]) {
        return 44.0f;
    }
    else {
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    });
}

#pragma mark - UIScrollViewDelegate
#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        // if value is < -50 then trigger view to collapse view
        if (scrollView.contentOffset.y < -50.0f) {
            if ([self.delegate respondsToSelector:@selector(collectionViewTableManagerShouldCollapse:)]) {
                [self.delegate collectionViewTableManagerShouldCollapse:self];
            }
        }
    }
}

@end
