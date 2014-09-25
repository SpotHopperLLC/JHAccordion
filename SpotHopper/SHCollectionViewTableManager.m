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
#import "SpotTypeModel.h"
#import "AverageReviewModel.h"
#import "SliderModel.h"
#import "SliderTemplateModel.h"
#import "SpecialModel.h"
#import "DrinkTypeModel.h"
#import "DrinkListModel.h"

#import "SHRatingSwooshView.h"
#import "SHRatingStarsView.h"
#import "SHDrawnButton.h"
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

@property (nonatomic, strong) DrinkListModel *highestRatedDrinklist;

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
        
        NSString *specialForToday = [self specialForToday];
        if (specialForToday.length) {
            [self.rows addObject:kRowNameTodaysSpecial];
        }
        
        if (self.spot.descriptionOfSpot.length) {
            [self.rows addObject:kRowNameDescription];
        }
        
        if (self.spot.hoursForToday.length || self.spot.phoneNumber.length) {
            [self.rows addObject:kRowNameHoursAndPhone];
        }
        
        [self.rows addObject:kRowNamePhotosAndReview];
        
        [self.tableView reloadData];
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, [self bottomContentInset], 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, [self bottomScrollIndicatorInset], 0);
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
        
        [self.rows addObject:kRowNameHighestRated];
        
        [self.rows addObject:kRowNamePhotosAndReview];
        
        [self.tableView reloadData];
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, [self bottomContentInset], 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, [self bottomScrollIndicatorInset], 0);
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
        else if (self.drink.isWine && (self.drink.abv.floatValue > 0 || self.drink.vintage || self.drink.region.length)) {
            [self.rows addObject:kRowNameDrinkSummary];
        }
        
        [self.rows addObject:kRowNamePhotosAndReview];
        
        [self.tableView reloadData];
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, [self bottomContentInset], 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, [self bottomScrollIndicatorInset], 0);
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

- (CGFloat)bottomContentInset {
    if ([self hasFourInchDisplay]) {
        return 100.0;
    }
    else {
        return 180.0;
    }
}

- (CGFloat)bottomScrollIndicatorInset {
    if ([self hasFourInchDisplay]) {
        return 50.0;
    }
    else {
        return 130.0;
    }
}

- (BOOL)hasFourInchDisplay {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0);
}

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
    if (self.spot) {
        SpecialModel *special = self.spot.specialForToday;
        return special.text;
    }
    
    return nil;
}

- (void)updateButton:(UIButton *)button withDrink:(DrinkModel *)drink {
    button.layer.borderColor = [[[UIColor lightGrayColor] colorWithAlphaComponent:0.8] CGColor];
    button.layer.borderWidth = 1.0;
    
    button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    button.clipsToBounds = TRUE;
    [button setImage:drink.placeholderImage forState:UIControlStateNormal];
    
    [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [button addTarget:self action:@selector(drinkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateButton:button withImage:drink.highlightImage placeholderImage:drink.placeholderImage];
}

- (void)updateButton:(UIButton *)button withImage:(ImageModel *)image placeholderImage:(UIImage *)placeholderImage {
    
    button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    button.clipsToBounds = TRUE;
    
    [NetworkHelper loadImage:image placeholderImage:placeholderImage withThumbImageBlock:^(UIImage *thumbImage) {
        [button setImage:thumbImage forState:UIControlStateNormal];
    } withFullImageBlock:^(UIImage *fullImage) {
        [button setImage:fullImage forState:UIControlStateNormal];
    } withErrorBlock:^(NSError *error) {
        [Tracker logError:error class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)moreButtonTapped:(UIButton *)button {
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

- (IBAction)phoneButtonTapped:(UIButton *)button {
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

- (IBAction)photosButtonTapped:(UIButton *)button {
    if (self.spot) {
        [SHNotifications showPhotosForSpot:self.spot];
    }
    else if (self.drink) {
        [SHNotifications showPhotosForDrink:self.drink];
    }
}

- (IBAction)photoButtonTapped:(UIButton *)button {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
    NSArray *images = self.spot ? self.spot.images : self.drink.images;
    
    if (button.tag == 201 && self.spot.images.count) {
        ImageModel *image = images[0];
        [SHNotifications showPhoto:image];
    }
    else if (button.tag == 301 && self.spot.images.count > 1) {
        ImageModel *image = images[1];
        [SHNotifications showPhoto:image];
    }
    else if (button.tag == 401 && self.spot.images.count > 2) {
        ImageModel *image = images[2];
        [SHNotifications showPhoto:image];
    }
}

- (IBAction)menuButtonTapped:(UIButton *)button {
    if (self.spot) {
        [SHNotifications openMenuForSpot:self.spot];
    }
}

- (IBAction)reviewButtonTapped:(UIButton *)button {
    if (self.spot) {
        [SHNotifications reviewSpot:self.spot];
    }
    else if (self.drink) {
        [SHNotifications reviewDrink:self.drink];
    }
}

- (IBAction)drinkButtonTapped:(UIButton *)button {
    // use the tag to determine which drink for the highest rated list to use
    // 201 == 0
    // 301 == 1
    // 401 == 2
    
    if (button.tag == 201 && self.highestRatedDrinklist.drinks.count) {
        DrinkModel *drink = self.highestRatedDrinklist.drinks[0];
        [SHNotifications pushToDrink:drink];
    }
    else if (button.tag == 301 && self.highestRatedDrinklist.drinks.count > 1) {
        DrinkModel *drink = self.highestRatedDrinklist.drinks[1];
        [SHNotifications pushToDrink:drink];
    }
    else if (button.tag == 401 && self.highestRatedDrinklist.drinks.count > 2) {
        DrinkModel *drink = self.highestRatedDrinklist.drinks[2];
        [SHNotifications pushToDrink:drink];
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

    UILabel *aboutThisLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *distanceLabel = (UILabel *)[cell viewWithTag:2];
    
    if (self.spot.spotType.name.length) {
        aboutThisLabel.text = [NSString stringWithFormat:@"About this %@", self.spot.spotType.name];
    }
    
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
    
    SHRatingSwooshView *ratingSwooshView1 = (SHRatingSwooshView *)[cell viewWithTag:103];
    SHRatingSwooshView *ratingSwooshView2 = (SHRatingSwooshView *)[cell viewWithTag:203];
    SHRatingSwooshView *ratingSwooshView3 = (SHRatingSwooshView *)[cell viewWithTag:303];

    SHDrawnButton *moreButton = (SHDrawnButton *)[cell viewWithTag:4];
    
    [moreButton setButtonDrawing:SHStyleKitDrawingMoreIcon normalColor:SHStyleKitColorMyTintColor highlightedColor:SHStyleKitColorMyTextColor drawingSize:moreButton.frame.size];
    
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

- (UITableViewCell *)renderCellForHighestRatedAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"HighestRatedCell" forIndexPath:indexPath];
    
    SHDrawnButton *menuImageButton = (SHDrawnButton *)[cell viewWithTag:501];
    UIButton *menuTextButton = (UIButton *)[cell viewWithTag:502];
    
    [menuImageButton setButtonDrawing:SHStyleKitDrawingDrinkMenuIcon normalColor:SHStyleKitColorMyTintColor highlightedColor:SHStyleKitColorMyTextColor];
    [SHStyleKit setButton:menuTextButton normalTextColor:SHStyleKitColorMyTintColor highlightedTextColor:SHStyleKitColorMyTextColor];
    
    [menuImageButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [menuImageButton addTarget:self action:@selector(menuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [menuTextButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [menuTextButton addTarget:self action:@selector(menuButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    menuTextButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    menuTextButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [menuTextButton setTitle:@"full\nmenu" forState:UIControlStateNormal];
    
    UIView *container1View = [cell viewWithTag:2];
    UIView *container2View = [cell viewWithTag:3];
    UIView *container3View = [cell viewWithTag:4];
    
    // hide the container views while the highest rated is fetched
    container1View.hidden = TRUE;
    container2View.hidden = TRUE;
    container3View.hidden = TRUE;
    
    UIButton *drink1Button = (UIButton *)[cell viewWithTag:201];
    UILabel *drink1Label = (UILabel *)[cell viewWithTag:202];
    SHRatingStarsView *rating1View = (SHRatingStarsView *)[cell viewWithTag:203];
    
    UIButton *drink2Button = (UIButton *)[cell viewWithTag:301];
    UILabel *drink2Label = (UILabel *)[cell viewWithTag:302];
    SHRatingStarsView *rating2View = (SHRatingStarsView *)[cell viewWithTag:303];
    
    UIButton *drink3Button = (UIButton *)[cell viewWithTag:401];
    UILabel *drink3Label = (UILabel *)[cell viewWithTag:402];
    SHRatingStarsView *rating3View = (SHRatingStarsView *)[cell viewWithTag:403];
    
    DrinkListRequest *request = [[DrinkListRequest alloc] init];
    request.name = @"Highest Rated";
    request.coordinate = [[SHAppContext defaultInstance] coordinate];
    request.radius = [[SHAppContext defaultInstance] radius];
    request.drinkTypeId = self.spot.preferredDrinkType.ID;
    request.transient = TRUE;
    request.spotId = self.spot.ID;
    
    [DrinkListModel fetchHighestRatedDrinkListWithRequest:request success:^(DrinkListModel *drinklist) {
        self.highestRatedDrinklist = drinklist;
        
        if (!drinklist.drinks.count) {
            container1View.hidden = FALSE;
            container2View.hidden = FALSE;
            container3View.hidden = FALSE;
            
            UIImage *placeholderImage = self.spot.preferredDrinkType.placeholderImage;
            
            drink1Label.text = @"";
            drink2Label.text = @"";
            drink3Label.text = @"";
            
            rating1View.rating = 0;
            rating2View.rating = 0;
            rating3View.rating = 0;
            
            drink1Button.imageView.contentMode = UIViewContentModeScaleAspectFill;
            drink1Button.clipsToBounds = TRUE;
            drink2Button.imageView.contentMode = UIViewContentModeScaleAspectFill;
            drink2Button.clipsToBounds = TRUE;
            drink3Button.imageView.contentMode = UIViewContentModeScaleAspectFill;
            drink3Button.clipsToBounds = TRUE;
            
            [drink1Button setImage:placeholderImage forState:UIControlStateNormal];
            [drink2Button setImage:placeholderImage forState:UIControlStateNormal];
            [drink3Button setImage:placeholderImage forState:UIControlStateNormal];
        }
        else {
            if (drinklist.drinks.count) {
                DrinkModel *drink = drinklist.drinks[0];
                container1View.hidden = FALSE;
                
                drink1Label.text = drink.name;
                rating1View.rating = drink.averageReview.rating.floatValue;
                [self updateButton:drink1Button withDrink:drink];
            }
            
            if (drinklist.drinks.count > 1) {
                DrinkModel *drink = drinklist.drinks[1];
                container2View.hidden = FALSE;
                
                drink2Label.text = drink.name;
                rating2View.rating = drink.averageReview.rating.floatValue;
                [self updateButton:drink2Button withDrink:drink];
            }
            
            if (drinklist.drinks.count > 2) {
                DrinkModel *drink = drinklist.drinks[2];
                container3View.hidden = FALSE;
                
                drink3Label.text = drink.name;
                rating3View.rating = drink.averageReview.rating.floatValue;
                [self updateButton:drink3Button withDrink:drink];
            }
        }
    } failure:^(ErrorModel *errorModel) {
        [Tracker logError:errorModel class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
    
    return cell;
}

- (UITableViewCell *)renderCellForPhotosAndReviewAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PhotosAndReviewCell" forIndexPath:indexPath];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    
    UIView *photo1View = [cell viewWithTag:2];
    UIView *photo2View = [cell viewWithTag:3];
    UIView *photo3View = [cell viewWithTag:4];
    
    UIButton *textButton = (UIButton *)[cell viewWithTag:5];
    UIButton *imageButton = (UIButton *)[cell viewWithTag:6];
    
    UIButton *photo1Button = (UIButton *)[cell viewWithTag:201];
    UILabel *photo1Label = (UILabel *)[cell viewWithTag:202];
    
    UIButton *photo2Button = (UIButton *)[cell viewWithTag:301];
    UILabel *photo2Label = (UILabel *)[cell viewWithTag:302];
    
    UIButton *photo3Button = (UIButton *)[cell viewWithTag:401];
    UILabel *photo3Label = (UILabel *)[cell viewWithTag:402];
    
    photo1Label.text = @"see\nall";
    photo1Label.lineBreakMode = NSLineBreakByWordWrapping;
    
    photo2Label.text = @"see\nall";
    photo2Label.lineBreakMode = NSLineBreakByWordWrapping;
    
    photo3Label.text = @"see\nall";
    photo3Label.lineBreakMode = NSLineBreakByWordWrapping;
    
    [photo1Button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [photo1Button addTarget:self action:@selector(photoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [photo2Button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [photo2Button addTarget:self action:@selector(photoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [photo3Button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [photo3Button addTarget:self action:@selector(photoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *placeholderImage = self.spot ? self.spot.placeholderImage : self.drink.placeholderImage;
    
    titleLabel.text = [NSString stringWithFormat:@"Photos of %@...", self.spot ? self.spot.name : self.drink.name];
    
    NSArray *images = self.spot ? self.spot.images : self.drink.images;
    
    if (images.count > 2) {
        titleLabel.hidden = FALSE;
        
        // hide labels over first 2 photo views
        photo1Label.hidden = TRUE;
        photo2Label.hidden = TRUE;
        photo3Label.hidden = FALSE;
        
        photo1View.hidden = FALSE;
        photo2View.hidden = FALSE;
        photo3View.hidden = FALSE;
        
        [self updateButton:photo1Button withImage:images[0] placeholderImage:placeholderImage];
        [self updateButton:photo2Button withImage:images[1] placeholderImage:placeholderImage];
        [self updateButton:photo3Button withImage:images[2] placeholderImage:placeholderImage];
        
        [photo1Button addTarget:self action:@selector(photoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [photo2Button addTarget:self action:@selector(photoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [photo3Button addTarget:self action:@selector(photosButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (images.count > 1) {
        titleLabel.hidden = FALSE;
        
        // hide labels over 2nd photo view
        photo1Label.hidden = TRUE;
        photo2Label.hidden = FALSE;
        
        photo1View.hidden = FALSE;
        photo2View.hidden = FALSE;
        photo3View.hidden = TRUE;
        
        [self updateButton:photo1Button withImage:images[0] placeholderImage:placeholderImage];
        [self updateButton:photo2Button withImage:images[1] placeholderImage:placeholderImage];
        
        [photo1Button addTarget:self action:@selector(photoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [photo2Button addTarget:self action:@selector(photosButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (images.count == 1) {
        titleLabel.text = [NSString stringWithFormat:@"Photo of %@...", self.spot ? self.spot.name : self.drink.name];
        titleLabel.hidden = FALSE;
        
        // leave just 1 photo view with the label visible
        photo1Label.hidden = TRUE;
        
        photo1View.hidden = FALSE;
        photo2View.hidden = TRUE;
        photo3View.hidden = TRUE;
        
        [self updateButton:photo1Button withImage:images[0] placeholderImage:placeholderImage];
        
        [photo1Button addTarget:self action:@selector(photosButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        titleLabel.hidden = TRUE;
        
        // hide all photo views
        photo1View.hidden = TRUE;
        photo2View.hidden = TRUE;
        photo3View.hidden = TRUE;
    }
    
    [SHStyleKit setButton:textButton normalTextColor:SHStyleKitColorMyTintColor highlightedTextColor:SHStyleKitColorMyTextColor];
    [textButton setTitle:@"Write a\nReview!" forState:UIControlStateNormal];
    textButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [SHStyleKit setButton:imageButton withDrawing:SHStyleKitDrawingReviewsIcon normalColor:SHStyleKitColorMyTintColor highlightedColor:SHStyleKitColorMyTextColor];
    
    [textButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [textButton addTarget:self action:@selector(reviewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    [imageButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [imageButton addTarget:self action:@selector(reviewButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (UITableViewCell *)renderCellForTodaysSpecialAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TodaysSpecialCell" forIndexPath:indexPath];
    
    UILabel *specialLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *hoursLabel = (UILabel *)[cell viewWithTag:3];

    specialLabel.text = [self specialForToday];
    hoursLabel.text = self.spot.specialForToday.timeString;
    
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
    if (self.drink.region.length) {
        varietalLabel.text = self.drink.region;
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
        else if ([rowName isEqualToString:kRowNameTodaysSpecial]) {
            cell = [self renderCellForTodaysSpecialAtIndexPath:indexPath];
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
        else if ([rowName isEqualToString:kRowNameHighestRated]) {
            cell = [self renderCellForHighestRatedAtIndexPath:indexPath];
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
    
    if ([rowName isEqualToString:kRowNameSpotSummary]) {
        return 50.0f;
    }
    else if ([rowName isEqualToString:kRowNameSummarySliders]) {
        return 90.0f;
    }
    else if ([rowName isEqualToString:kRowNameDescription]) {
        NSString *text = nil;
        if (self.mode == Special || self.mode == Spot) {
            text = self.spot.descriptionOfSpot;
        }
        else if (self.mode == Drink) {
            text = self.drink.descriptionOfDrink;
        }
        
        UIFont *font = [UIFont fontWithName:@"Lato-Light" size:15.0f];
        CGFloat height = [self heightForString:text font:font maxWidth:300.0f] + 10.0f;
        
        return height;
    }
    else if ([rowName isEqualToString:kRowNameHoursAndPhone]) {
        return 60.0f;
    }
    else if ([rowName isEqualToString:kRowNameTodaysSpecial]) {
        NSString *text = [self specialForToday];
        UIFont *font = [UIFont fontWithName:@"Lato-Light" size:15.0f];
        CGFloat height = [self heightForString:text font:font maxWidth:300.0f] + 62.0f;
        
        return height;
    }
    else if ([rowName isEqualToString:kRowNameDrinkSummary]) {
        return 54.0f;
    }
    else if ([rowName isEqualToString:kRowNamePhotosAndReview]) {
        return 114.0f;
    }
    else if ([rowName isEqualToString:kRowNameHighestRated]) {
        return 160.0f;
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
