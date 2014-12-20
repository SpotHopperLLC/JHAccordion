//
//  SHMenuViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 12/17/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHMenuViewController.h"

#import "SHAppUtil.h"
#import "ImageUtil.h"

#import "SHDrinkProfileViewController.h"
#import "SHRatingStarsView.h"
#import "SHStyleKit+Additions.h"

#import "ErrorModel.h"
#import "MenuModel.h"
#import "DrinkModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubTypeModel.h"
#import "AverageReviewModel.h"
#import "MenuItemModel.h"
#import "MenuTypeModel.h"
#import "PriceModel.h"
#import "BaseAlcoholModel.h"
#import "SpotModel.h"
#import "ImageModel.h"

#define kIndexBeer 0
#define kIndexWine 1
#define kIndexCocktails 2

#define kSortHighestRated @"Highest Rated"
#define kSortPriceLowToHigh @"Price (Low to High)"
#define kSortPriceHighToLow @"Price (High to Low)"
#define kSortAlcoholPercentage @"Alcohol Percentage"
#define kSortBaseAlcohol @"Base Alcohol"

@interface SHMenuViewController ()

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *sortButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *noDrinksLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) MenuModel *menu;

@property (strong, nonatomic) NSDictionary *menuItems;

@property (assign, nonatomic) NSUInteger currentIndex;

@property (assign, nonatomic) CGPoint offsetBeer;
@property (assign, nonatomic) CGPoint offsetWine;
@property (assign, nonatomic) CGPoint offsetCocktails;

@property (strong, nonatomic) NSArray *sorts;
@property (assign, nonatomic) NSUInteger sortIndexForBeer;
@property (assign, nonatomic) NSUInteger sortIndexForWine;
@property (assign, nonatomic) NSUInteger sortIndexForCocktail;

@property (strong, nonatomic) NSMutableDictionary *operations;

@end

@implementation SHMenuViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat topHeight = CGRectGetHeight(self.topView.frame);
    DebugLog(@"top height: %f", topHeight);
    UIEdgeInsets insets = UIEdgeInsetsMake(topHeight, 0, 0, 0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    CGPoint offset = CGPointMake(0, topHeight * -1);
    self.offsetBeer = offset;
    self.offsetWine = offset;
    self.offsetCocktails = offset;
    
    // sorts are aligned with the segmented control for Beer, Wine and Cocktails
    self.sorts = @[@[kSortHighestRated, kSortPriceLowToHigh, kSortPriceHighToLow, kSortAlcoholPercentage],
                   @[kSortHighestRated, kSortPriceLowToHigh, kSortPriceHighToLow],
                   @[kSortHighestRated, kSortPriceLowToHigh, kSortPriceHighToLow, kSortBaseAlcohol]];
    
    MAAssert([kSortHighestRated isEqualToString:self.sorts[kIndexBeer][0]], @"Invalid State");
    MAAssert([kSortPriceLowToHigh isEqualToString:self.sorts[kIndexBeer][1]], @"Invalid State");
    MAAssert([kSortPriceHighToLow isEqualToString:self.sorts[kIndexBeer][2]], @"Invalid State");
    MAAssert([kSortAlcoholPercentage isEqualToString:self.sorts[kIndexBeer][3]], @"Invalid State");
    
    MAAssert([kSortHighestRated isEqualToString:self.sorts[kIndexWine][0]], @"Invalid State");
    MAAssert([kSortPriceLowToHigh isEqualToString:self.sorts[kIndexWine][1]], @"Invalid State");
    MAAssert([kSortPriceHighToLow isEqualToString:self.sorts[kIndexWine][2]], @"Invalid State");
    
    MAAssert([kSortHighestRated isEqualToString:self.sorts[kIndexCocktails][0]], @"Invalid State");
    MAAssert([kSortPriceLowToHigh isEqualToString:self.sorts[kIndexCocktails][1]], @"Invalid State");
    MAAssert([kSortPriceHighToLow isEqualToString:self.sorts[kIndexCocktails][2]], @"Invalid State");
    MAAssert([kSortBaseAlcohol isEqualToString:self.sorts[kIndexCocktails][3]], @"Invalid State");
}

- (NSArray *)viewOptions {
    return @[kDidLoadOptionsNoBackground];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = self.spot.name;
    [self styleBars];
    
    if (!self.menu) {
        [self refreshData];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)sortButtonTapped:(id)sender {
    [self toggleSort];
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    if (self.currentIndex == kIndexBeer) {
        self.offsetBeer = self.tableView.contentOffset;
    }
    else if (self.currentIndex == kIndexWine) {
        self.offsetWine = self.tableView.contentOffset;
    }
    else if (self.currentIndex == kIndexCocktails) {
        self.offsetCocktails = self.tableView.contentOffset;
    }
    
    [self updateSortTitle];
    [self sortMenuItems:self.menu.items];
    [self.tableView reloadData];
    
    [self prepareDisplay];
}

#pragma mark - Styling
#pragma mark -

- (void)styleBars {
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    UIImage *backgroundImage = [SHStyleKit gradientBackgroundWithSize:self.view.frame.size];
    [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [SHStyleKit myWhiteColor]};
}

#pragma mark - Data
#pragma mark -

- (void)refreshData {
    DrinkTypeModel *drinkType = self.spot.preferredDrinkType;
    
    if (drinkType.isBeer) {
        self.segmentedControl.selectedSegmentIndex = kIndexBeer;
    }
    else if (drinkType.isWine) {
        self.segmentedControl.selectedSegmentIndex = kIndexWine;
    }
    else if (drinkType.isCocktail) {
        self.segmentedControl.selectedSegmentIndex = kIndexCocktails;
    }
    
    self.currentIndex = self.segmentedControl.selectedSegmentIndex;
    
    [self.activityIndicator startAnimating];
    self.tableView.hidden = TRUE;
    [self.spot fetchMenu:^(MenuModel *menu) {
        self.menu = menu;
        
        [self sortMenuItems:menu.items];
        
        self.operations = @{}.mutableCopy;
        [self.tableView reloadData];
        [self.activityIndicator stopAnimating];
        
        [self prepareDisplay];
    } failure:^(ErrorModel *errorModel) {
        [self showAlert:@"Oops" message:@"The menu was not loaded. Please try again."];
    }];
}

- (void)sortMenuItems:(NSArray *)items {
    NSMutableDictionary *menuItems = @{}.mutableCopy;
    
    // TODO: change sort based on current selection
    
    NSString *sort = nil;
    
    if (self.segmentedControl.selectedSegmentIndex == kIndexBeer) {
        NSArray *sorts = self.sorts[kIndexBeer];
        sort = sorts[self.sortIndexForBeer];
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexWine) {
        NSArray *sorts = self.sorts[kIndexWine];
        sort = sorts[self.sortIndexForWine];
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexCocktails) {
        NSArray *sorts = self.sorts[kIndexCocktails];
        sort = sorts[self.sortIndexForCocktail];
    }
    
    NSArray *sortedItems = nil;
    
//    NSOrderedAscending = -1L, NSOrderedSame, NSOrderedDescending
    
    if ([kSortHighestRated isEqualToString:sort]) {
        sortedItems = [items sortedArrayUsingComparator:^NSComparisonResult(MenuItemModel *item1, MenuItemModel *item2) {
            NSNumber *rating1 = item1.drink.averageReview.rating ? : @0;
            NSNumber *rating2 = item2.drink.averageReview.rating ? : @0;
            return [rating2 compare:rating1];
        }];
    }
    else if ([kSortPriceLowToHigh isEqualToString:sort]) {
        sortedItems = [items sortedArrayUsingComparator:^NSComparisonResult(MenuItemModel *item1, MenuItemModel *item2) {
            PriceModel *price1 = item1.prices.firstObject;
            PriceModel *price2 = item2.prices.firstObject;
            
            if (price1.cents && price2.cents) {
                return [price1.cents compare:price2.cents];
            }
            else {
                return NSOrderedSame;
            }
        }];
    }
    else if ([kSortPriceHighToLow isEqualToString:sort]) {
        sortedItems = [items sortedArrayUsingComparator:^NSComparisonResult(MenuItemModel *item1, MenuItemModel *item2) {
            PriceModel *price1 = item1.prices.firstObject;
            PriceModel *price2 = item2.prices.firstObject;
            
            if (price1.cents && price2.cents) {
                return [price2.cents compare:price1.cents];
            }
            else {
                return NSOrderedSame;
            }
        }];
    }
    else if ([kSortAlcoholPercentage isEqualToString:sort]) {
        sortedItems = [items sortedArrayUsingComparator:^NSComparisonResult(MenuItemModel *item1, MenuItemModel *item2) {
            if (item1.drink.abv && item2.drink.abv) {
                return [item2.drink.abv compare:item1.drink.abv];
            }
            else {
                return NSOrderedSame;
            }
        }];
    }
    else if ([kSortBaseAlcohol isEqualToString:sort]) {
        sortedItems = [items sortedArrayUsingComparator:^NSComparisonResult(MenuItemModel *item1, MenuItemModel *item2) {
            BaseAlcoholModel *baseAlcohol1 = item1.drink.baseAlochols.firstObject;
            BaseAlcoholModel *baseAlcohol2 = item2.drink.baseAlochols.firstObject;
            if (baseAlcohol1.name.length && baseAlcohol2.name.length) {
                return [baseAlcohol1.name compare:baseAlcohol2.name];
            }
            else {
                return NSOrderedSame;
            }
        }];
    }
    else {
        sortedItems = [items sortedArrayUsingComparator:^NSComparisonResult(MenuItemModel *item1, MenuItemModel *item2) {
            return [item1.name compare:item2.name];
        }];
    }
    
    for (MenuItemModel *item in sortedItems) {
        // add each drink to the dictionary based on the name of the drink sub type
        
        NSString *drinkTypeName = item.drink.drinkType.name;
        NSString *drinkSubTypeName = item.menuType.name.length ? item.menuType.name : item.drink.drinkSubtype.name;
        
        if (item.drink.isCocktail) {
            drinkSubTypeName = drinkTypeName;
        }
        
        if (drinkTypeName.length && drinkSubTypeName.length) {
            // create the dictionary for the drink type if necessary
            if (!menuItems[drinkTypeName]) {
                menuItems[drinkTypeName] = @{}.mutableCopy;
            }
            // create the array for the drink sub type if necessary
            if (!menuItems[drinkTypeName][drinkSubTypeName]) {
                menuItems[drinkTypeName][drinkSubTypeName] = @[].mutableCopy;
            }
            
            NSMutableArray *items = menuItems[drinkTypeName][drinkSubTypeName];
            [items addObject:item];
        }
    }
    
    self.menuItems = menuItems;
}

- (void)prepareDisplay {
    NSDictionary *sections = [self sections];
    
    if (sections.allKeys.count) {
        self.tableView.hidden = FALSE;
        self.noDrinksLabel.hidden = TRUE;
        
        if (self.segmentedControl.selectedSegmentIndex == kIndexBeer) {
            self.tableView.contentOffset = self.offsetBeer;
        }
        else if (self.segmentedControl.selectedSegmentIndex == kIndexWine) {
            self.tableView.contentOffset = self.offsetWine;
        }
        else if (self.segmentedControl.selectedSegmentIndex == kIndexCocktails) {
            self.tableView.contentOffset = self.offsetCocktails;
        }
    }
    else {
        self.tableView.hidden = TRUE;
        
        if (self.segmentedControl.selectedSegmentIndex == kIndexBeer) {
            self.noDrinksLabel.text = @"No Beers";
        }
        else if (self.segmentedControl.selectedSegmentIndex == kIndexWine) {
            self.noDrinksLabel.text = @"No Wines";
        }
        else if (self.segmentedControl.selectedSegmentIndex == kIndexCocktails) {
            self.noDrinksLabel.text = @"No Cocktails";
        }
        else {
            self.noDrinksLabel.text = nil;
        }
        
        self.noDrinksLabel.hidden = FALSE;
    }
    
    self.currentIndex = self.segmentedControl.selectedSegmentIndex;
}

- (NSDictionary *)sections {
    NSDictionary *sections = nil;
    
    if (self.segmentedControl.selectedSegmentIndex == kIndexBeer) {
        NSString *name = [[DrinkTypeModel beerDrinkType] name];
        sections = self.menuItems[name];
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexWine) {
        NSString *name = [[DrinkTypeModel wineDrinkType] name];
        sections = self.menuItems[name];
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexCocktails) {
        NSString *name = [[DrinkTypeModel cocktailDrinkType] name];
        sections = self.menuItems[name];
    }
    
    return sections;
}

- (MenuItemModel *)itemAtIndexPath:(NSIndexPath *)indexPath {
    MenuItemModel *item = nil;
    
    // menuItems[type][subtype]
    // menuItems[section][item]
    // menuItems[@"Beer"][@"Draft"][indexPath.row]
    // how to map section to type key?
    
    // section here will be Draft or Bottle/Can using indexPath.section to get the dictionary key
    
    NSDictionary *sections = [self sections];
    
    if (indexPath.section < sections.allKeys.count) {
        NSString *sectionKey = sections.allKeys[indexPath.section];
        NSArray *items = sections[sectionKey];
        if (indexPath.row < items.count) {
            item = items[indexPath.row];
        }
    }
    
    return item;
}

#pragma mark - Sorting
#pragma mark -

- (void)toggleSort {
    if (self.segmentedControl.selectedSegmentIndex == kIndexBeer) {
        self.sortIndexForBeer++;
        NSArray *sorts = self.sorts[kIndexBeer];
        if (self.sortIndexForBeer >= sorts.count) {
            self.sortIndexForBeer = 0;
        }
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexWine) {
        self.sortIndexForWine++;
        NSArray *sorts = self.sorts[kIndexWine];
        if (self.sortIndexForWine >= sorts.count) {
            self.sortIndexForWine = 0;
        }
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexCocktails) {
        self.sortIndexForCocktail++;
        NSArray *sorts = self.sorts[kIndexCocktails];
        if (self.sortIndexForCocktail >= sorts.count) {
            self.sortIndexForCocktail = 0;
        }
    }
    
    [self updateSortTitle];
    [self sortMenuItems:self.menu.items];
    
    CGFloat topHeight = CGRectGetHeight(self.topView.frame);
    CGPoint offset = CGPointMake(0, topHeight * -1);
    self.tableView.contentOffset = offset;
    
    [self.tableView reloadData];
}

- (void)updateSortTitle {
    if (self.segmentedControl.selectedSegmentIndex == kIndexBeer) {
        NSArray *sorts = self.sorts[kIndexBeer];
        NSString *title = sorts[self.sortIndexForBeer];
        [self.sortButton setTitle:title forState:UIControlStateNormal];
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexWine) {
        NSArray *sorts = self.sorts[kIndexWine];
        NSString *title = sorts[self.sortIndexForWine];
        [self.sortButton setTitle:title forState:UIControlStateNormal];
    }
    else if (self.segmentedControl.selectedSegmentIndex == kIndexCocktails) {
        NSArray *sorts = self.sorts[kIndexCocktails];
        NSString *title = sorts[self.sortIndexForCocktail];
        [self.sortButton setTitle:title forState:UIControlStateNormal];
    }
}

#pragma mark - Rendering Cells
#pragma mark -

- (void)loadImageForDrink:(DrinkModel *)drink intoImageView:(UIImageView *)imageView atIndexPath:(NSIndexPath *)indexPath {
    imageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    imageView.layer.borderWidth = 1.0f;
    imageView.layer.cornerRadius = 6.0f;
    imageView.clipsToBounds = YES;
    imageView.image = drink.placeholderImage;
    
    if (drink.highlightImage.smallUrl.length) {
        NSURL *smallUrl = [NSURL URLWithString:drink.highlightImage.smallUrl];
        NSOperation *operation = [ImageUtil fetchImageWithURL:smallUrl cachable:TRUE withCompletionBlock:^(UIImage *image, NSError *error) {
            if (!error && image) {
                imageView.image = image;
            }
        }];
        
        self.operations[indexPath] = operation;
    }
}

- (UITableViewCell *)renderBeerCellInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BeerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *firstLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *secondLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *thirdLabel = (UILabel *)[cell viewWithTag:4];
    UILabel *fourthLabel = (UILabel *)[cell viewWithTag:6];
    SHRatingStarsView *ratingStarsView = (SHRatingStarsView *)[cell viewWithTag:5];
    
    imageView.image = nil;
    firstLabel.text = nil;
    secondLabel.text = nil;
    thirdLabel.text = nil;
    fourthLabel.text = nil;
    
    MenuItemModel *item = [self itemAtIndexPath:indexPath];
    DrinkModel *drink = item.drink;

    [self loadImageForDrink:drink intoImageView:imageView atIndexPath:indexPath];
    ratingStarsView.rating = drink.averageReview.rating.floatValue;
    
    NSString *priceSummary = item.priceSummary;
    
    // first label
    firstLabel.text = drink.name;
    
    // second label
    if (drink.spot.name.length && drink.style.length) {
        secondLabel.text = [NSString stringWithFormat:@"%@ - %@", drink.spot.name, drink.style];
    }
    else if (drink.spot.name.length) {
        secondLabel.text = drink.spot.name;
    }
    else if (drink.style.length) {
        secondLabel.text = drink.style;
    }
    
    // third label
    if (priceSummary.length) {
        thirdLabel.text = priceSummary;
    }
    
    // fourth label
    if (drink.abv.floatValue > 0) {
        fourthLabel.text = [NSString stringWithFormat:@"%@ AbV", drink.abvPercentString];
    }
    
    return cell;
}

- (UITableViewCell *)renderWineCellInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"WineCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *firstLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *secondLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *thirdLabel = (UILabel *)[cell viewWithTag:4];
    SHRatingStarsView *ratingStarsView = (SHRatingStarsView *)[cell viewWithTag:5];
    
    imageView.image = nil;
    firstLabel.text = nil;
    secondLabel.text = nil;
    thirdLabel.text = nil;
    
    MenuItemModel *item = [self itemAtIndexPath:indexPath];
    DrinkModel *drink = item.drink;
    
    [self loadImageForDrink:drink intoImageView:imageView atIndexPath:indexPath];
    ratingStarsView.rating = drink.averageReview.rating.floatValue;
    
    NSString *priceSummary = item.priceSummary;
    
    // first label
    if (drink.spot.name.length) {
        firstLabel.text = [NSString stringWithFormat:@"%@ - %@", drink.name, drink.spot.name];
    }
    else {
        firstLabel.text = drink.name;
    }
    
    // second label
    if (drink.abv.floatValue > 0 && drink.varietal.length) {
        secondLabel.text = [NSString stringWithFormat:@"%@ - %@ AbV", drink.varietal, drink.abvPercentString];
    }
    else if (drink.abv.floatValue > 0) {
        secondLabel.text = [NSString stringWithFormat:@"%@ AbV", drink.abvPercentString];
    }
    else if (drink.varietal.length) {
        secondLabel.text = drink.varietal;
    }

    // third label
    if (priceSummary.length) {
        thirdLabel.text = priceSummary;
    }
    
    return cell;
}

- (UITableViewCell *)renderCocktailCellInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CocktailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *firstLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *secondLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *thirdLabel = (UILabel *)[cell viewWithTag:5];
    SHRatingStarsView *ratingStarsView = (SHRatingStarsView *)[cell viewWithTag:4];
    
    imageView.image = nil;
    firstLabel.text = nil;
    secondLabel.text = nil;
    thirdLabel.text = nil;
    
    MenuItemModel *item = [self itemAtIndexPath:indexPath];
    DrinkModel *drink = item.drink;
    
    [self loadImageForDrink:drink intoImageView:imageView atIndexPath:indexPath];
    ratingStarsView.rating = drink.averageReview.rating.floatValue;
    
    NSString *priceSummary = item.priceSummary;
    
    BaseAlcoholModel *baseAlcohol = drink.baseAlochols.firstObject;
    
    // first label
    firstLabel.text = drink.name;
    
    // second label
    if (baseAlcohol.name.length) {
        secondLabel.text = [NSString stringWithFormat:@"%@ base", baseAlcohol.name];
    }
    
    // third label
    if (priceSummary.length) {
        thirdLabel.text = priceSummary;
    }
    
    return cell;
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSDictionary *sections = [self sections];
    return sections.allKeys.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    
    NSDictionary *sections = [self sections];
    if (sections.allKeys.count > 1 && section < sections.allKeys.count) {
        title = sections.allKeys[section];
    }
    
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    
    NSDictionary *sections = [self sections];
    if (section < sections.allKeys.count) {
        NSString *sectionKey = sections.allKeys[section];
        NSArray *items = sections[sectionKey];
        count = items.count;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuItemModel *item = [self itemAtIndexPath:indexPath];
    DrinkModel *drink = item.drink;
    
    UITableViewCell *cell = nil;
    
    if (drink.isBeer) {
        cell = [self renderBeerCellInTableView:tableView atIndexPath:indexPath];
    }
    else if (drink.isWine) {
        cell = [self renderWineCellInTableView:tableView atIndexPath:indexPath];
    }
    else if (drink.isCocktail) {
        cell = [self renderCocktailCellInTableView:tableView atIndexPath:indexPath];
    }
    
    return cell;
    
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    
    return title.length ? 28.0 : 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    
    if (!title.length) {
        return nil;
    }
    
    UIColor *backgroundColor = [UIColor colorWithRed:0.9412 green:0.9412 blue:0.9412 alpha:1.0];
    UIColor *textColor = [UIColor colorWithRed:0.5569 green:0.5569 blue:0.5569 alpha:1.0];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 24.0)];
    headerView.backgroundColor = [backgroundColor colorWithAlphaComponent:0.9];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 4.0, 320.0, 18.0)];
    label.font = [UIFont fontWithName:@"Lato-Light" size:16.0];
    label.textColor = textColor;
    label.translatesAutoresizingMaskIntoConstraints = YES;
    label.text = title;
    [headerView addSubview:label];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView willEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    NSOperation *operation = self.operations[indexPath];
    
    if (operation) {
        if (operation.isExecuting) {
            [operation cancel];
        }
        
        [self.operations removeObjectForKey:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SHDrinkProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SHDrinkProfileVC"];
    MenuItemModel *item = [self itemAtIndexPath:indexPath];
    vc.drink = item.drink;
    
    [self.navigationController pushViewController:vc animated:TRUE];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    });
}
#pragma mark - UIScrollViewDelegate
#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

@end
