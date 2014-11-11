//
//  SHMenuAdminPickerViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 11/10/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHMenuAdminPickerViewController.h"

#import "SHStyleKit+Additions.h"
#import "SpotModel.h"
#import "DrinkModel.h"

typedef enum {
    SHPickerModeNone = 0,
    SHPickerModeBreweries,
    SHPickerModeWineries,
    SHPickerModeBeerStyles
} SHPickerMode;

@interface SHMenuAdminPickerViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (assign, nonatomic) SHPickerMode pickerMode;

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (strong, nonatomic) NSString *searchText;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *breweries;
@property (strong, nonatomic) NSArray *wineries;
@property (strong, nonatomic) NSArray *allBeerStyles;
@property (strong, nonatomic) NSArray *beerStyles;

@end

@implementation SHMenuAdminPickerViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    MAAssert(self.searchTextField, @"Outlet is required");
    MAAssert(self.searchTextField.delegate, @"Delegate is required");
    MAAssert(self.tableView, @"Outlet is required");
    MAAssert(self.tableView.dataSource, @"DataSource is required");
    MAAssert(self.tableView.delegate, @"Delegate is required");
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    switch (self.pickerMode) {
        case SHPickerModeBreweries:
            
            self.title = @"Pick a Brewery";
            self.searchTextField.placeholder = @"Search Breweries";
            
            break;
        case SHPickerModeWineries:
            
            self.title = @"Pick a Winery";
            self.searchTextField.placeholder = @"Search Wineries";
            
            break;
        case SHPickerModeBeerStyles:
            
            self.title = @"Pick a Beer Style";
            self.searchTextField.placeholder = @"Search Beer Styles";
            
            break;
            
        default:
            break;
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.searchTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - Base Overrides
#pragma mark -

- (UIScrollView *)mainScrollView {
    return self.tableView;
}

#pragma mark - Public
#pragma mark -

- (void)prepareForBreweries {
    self.pickerMode = SHPickerModeBreweries;
    self.breweries = @[];
}

- (void)prepareForWineries {
    self.pickerMode = SHPickerModeWineries;
    self.wineries = @[];
}

- (void)prepareForBeerStyles {
    self.pickerMode = SHPickerModeBeerStyles;
    self.beerStyles = @[];
    
    [[DrinkModel fetchBeerStyles] then:^(NSArray *styles) {
        self.allBeerStyles = styles;
        self.beerStyles = styles.copy;
        [self.tableView reloadData];
    } fail:^(id error) {
    } always:nil];
}

#pragma mark - Private
#pragma mark -

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.pickerMode) {
        case SHPickerModeBreweries:
            if (indexPath.row < self.breweries.count) {
                return self.breweries[indexPath.row];
            }
            
            break;
        case SHPickerModeWineries:
            if (indexPath.row < self.wineries.count) {
                return self.wineries[indexPath.row];
            }
            
            break;
        case SHPickerModeBeerStyles:
            if (indexPath.row < self.beerStyles.count) {
                return self.beerStyles[indexPath.row];
            }
            
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (void)renderCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    
    MAAssert(titleLabel, @"Label is required");
    
    id item = [self itemAtIndexPath:indexPath];
    
    if (item) {
        switch (self.pickerMode) {
            case SHPickerModeBreweries: {
                SpotModel *spot = (SpotModel *)item;
                titleLabel.text = spot.name;
                }
                break;
                
            case SHPickerModeWineries: {
                SpotModel *spot = (SpotModel *)item;
                titleLabel.text = spot.name;
                }
                break;
                
            case SHPickerModeBeerStyles: {
                NSString *style = (NSString *)item;
                titleLabel.text = style;
                }
                
                break;
                
            default:
                break;
        }
    }
    else {
        titleLabel.text = @"";
    }
}

- (void)runSearch {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(runSearch) object:nil];
    
    switch (self.pickerMode) {
        case SHPickerModeBreweries: {
            [self searchBreweriesWithText:self.searchText];
        }
            
            break;
        case SHPickerModeWineries: {
            [self searchWineriesWithText:self.searchText];
        }
            break;
        case SHPickerModeBeerStyles: {
            [self searchBeerStylesWithText:self.searchText];
        }
            
            break;
            
        default:
            break;
    }
}

- (void)searchBreweriesWithText:(NSString *)text {
    if (text.length) {
        [self startSearching];
        [[SpotModel queryBreweriesWithText:text page:@1] then:^(NSArray *breweries) {
            [self stopSearching];
            self.breweries = breweries;
            [self.tableView reloadData];
            self.tableView.contentOffset = CGPointMake(0, 0);
        } fail:^(id error) {
            // TODO: log error
        } always:nil];
    }
    else {
        self.breweries = @[];
        [self.tableView reloadData];
        self.tableView.contentOffset = CGPointMake(0, 0);
    }
}

- (void)searchWineriesWithText:(NSString *)text {
    if (text.length) {
        [self startSearching];
        [[SpotModel queryWineriesWithText:text page:@1] then:^(NSArray *wineries) {
            [self stopSearching];
            self.wineries = wineries;
            [self.tableView reloadData];
            self.tableView.contentOffset = CGPointMake(0, 0);
        } fail:^(id error) {
            // TODO: log error
        } always:nil];
    }
    else {
        self.wineries = @[];
        [self.tableView reloadData];
        self.tableView.contentOffset = CGPointMake(0, 0);
    }
}

- (void)searchBeerStylesWithText:(NSString *)text {
    if (text.length) {
        [self startSearching];
        self.beerStyles = [self.allBeerStyles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", text]];
        [self stopSearching];
        [self.tableView reloadData];
        self.tableView.contentOffset = CGPointMake(0, 0);
    }
    else {
        self.beerStyles = self.allBeerStyles.copy;
        [self.tableView reloadData];
        self.tableView.contentOffset = CGPointMake(0, 0);
    }
}

- (void)startSearching {
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    activityIndicatorView.tintColor = [SHStyleKit color:SHStyleKitColorMyTintColor];
    
    CGRect frame = activityIndicatorView.frame;
    frame.size.width += 5.0f;
    UIView *containerView = [[UIView alloc] initWithFrame:frame];
    [containerView addSubview:activityIndicatorView];
    
    self.searchTextField.rightView = containerView;
    self.searchTextField.rightViewMode = UITextFieldViewModeAlways;
    [activityIndicatorView startAnimating];
}

- (void)stopSearching {
    self.searchTextField.rightView = nil;
    self.searchTextField.rightViewMode = UITextFieldViewModeNever;
}

#pragma mark - UITextFieldDelegate
#pragma mark -

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.searchText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    [self performSelector:@selector(runSearch) withObject:nil afterDelay:0.25];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.searchText = @"";
    
    [self performSelector:@selector(runSearch) withObject:nil afterDelay:0.25];
    
    return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:TRUE];
    
    return TRUE;
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;

    switch (self.pickerMode) {
        case SHPickerModeBreweries:
            count = self.breweries.count;
            break;
        case SHPickerModeWineries:
            count = self.wineries.count;
            break;
        case SHPickerModeBeerStyles:
            count = self.beerStyles.count;
            break;
            
        default:
            break;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TitleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self renderCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pickerView:didSelectItem:)]) {
        id item = [self itemAtIndexPath:indexPath];
        [self.delegate pickerView:self didSelectItem:item];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    });
}

@end
