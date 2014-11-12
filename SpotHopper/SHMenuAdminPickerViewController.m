//
//  SHMenuAdminPickerViewController.m
//  SpotHopper
//
//  Created by Brennan Stehling on 11/10/14.
//  Copyright (c) 2014 SpotHopper. All rights reserved.
//

#import "SHMenuAdminPickerViewController.h"

#import "SHStyleKit+Additions.h"

@interface SHMenuAdminPickerViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (strong, nonatomic) NSString *searchText;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
    
    self.title = [self titleText];
    self.searchTextField.placeholder = [self placeholderText];
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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Base Overrides
#pragma mark -

- (UIScrollView *)mainScrollView {
    return self.tableView;
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)cancelButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(pickerViewDidCancel:)]) {
        [self.delegate pickerViewDidCancel:self];
    }
}

#pragma mark - Public
#pragma mark -

- (void)reloadData {
    [self stopSearching];
    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointMake(0, 0);
}

- (void)startSearching {
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    activityIndicatorView.hidesWhenStopped = TRUE;
    activityIndicatorView.tag = 100;
    
    CGRect frame = activityIndicatorView.frame;
    frame.size.width += 5.0f;
    UIView *containerView = [[UIView alloc] initWithFrame:frame];
    [containerView addSubview:activityIndicatorView];
    
    self.searchTextField.rightView = containerView;
    self.searchTextField.rightViewMode = UITextFieldViewModeAlways;
    [activityIndicatorView startAnimating];
}

- (void)stopSearching {
    UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)[self.searchTextField.rightView viewWithTag:100];
    [activityIndicatorView stopAnimating];
    self.searchTextField.rightView = nil;
    self.searchTextField.rightViewMode = UITextFieldViewModeNever;
}

#pragma mark - Private
#pragma mark -

- (void)renderCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    MAAssert(titleLabel, @"Label is required");
    titleLabel.text = [self textAtIndexPath:indexPath];
}

- (void)runSearch {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(runSearch) object:nil];
    
    [self startSearching];
    [self changeSearchText:self.searchText];
}

#pragma mark - Delegate Calls
#pragma mark -

- (NSString *)titleText {
    if ([self.delegate respondsToSelector:@selector(titleTextForPickerView:)]) {
        return [self.delegate titleTextForPickerView:self];
    }
    
    return nil;
}

- (NSString *)placeholderText {
    if ([self.delegate respondsToSelector:@selector(placeholderTextForPickerView:)]) {
        return [self.delegate placeholderTextForPickerView:self];
    }
    
    return nil;
}

- (NSInteger)numberOfItems {
    if ([self.delegate respondsToSelector:@selector(numberOfItemsForPickerView:)]) {
        return [self.delegate numberOfItemsForPickerView:self];
    }
    
    return 0;
}

- (NSString *)textAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(textForPickerView:atIndexPath:)]) {
        return [self.delegate textForPickerView:self atIndexPath:indexPath];
    }
    
    return nil;
}

- (void)changeSearchText:(NSString *)searchText {
    if ([self.delegate respondsToSelector:@selector(pickerView:didChangeSearchText:)]) {
        return [self.delegate pickerView:self didChangeSearchText:searchText];
    }
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pickerView:didSelectItemAtIndexPath:)]) {
        return [self.delegate pickerView:self didSelectItemAtIndexPath:indexPath];
    }
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

    [self performSelector:@selector(runSearch) withObject:nil afterDelay:0.25];
    
    return TRUE;
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfItems];
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
    [self selectItemAtIndexPath:indexPath];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    });
}

@end
