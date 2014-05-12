//
//  LiveSpecialViewController.m
//  SpotHopper
//
//  Created by Josh Holtz on 3/27/14.
//  Copyright (c) 2014 RokkinCat. All rights reserved.
//

#import "LiveSpecialViewController.h"

#import "LiveSpecialModel.h"
#import "ErrorModel.h"
#import "SpotModel.h"
#import "Tracker.h"

#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface LiveSpecialViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblSpecial;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *lblAt;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LiveSpecialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad:@[kDidLoadOptionsNoBackground]];
    
    
    [self updateView];
    
    if (_needToFetch == YES) {
        [self fetchLiveSpecial];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // We don't need to listen for this here
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationPushReceived object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLiveSpecial:(LiveSpecialModel *)liveSpecial {
    _liveSpecial = liveSpecial;
    [self updateView];
    
    if (_needToFetch == YES) {
        [self fetchLiveSpecial];
    }
}

#pragma mark - Tracking

- (NSString *)screenName {
    return @"Live Special";
}

#pragma mark - Actions

- (IBAction)onClickClose:(id)sender {
    if ([_delegate respondsToSelector:@selector(liveSpecialViewControllerClickedClose:)]) {
        [_delegate liveSpecialViewControllerClickedClose:self];
    }
}

- (IBAction)onClickShare:(id)sender {
    if ([_delegate respondsToSelector:@selector(liveSpecialViewControllerClickedShare:)]) {
        [_delegate liveSpecialViewControllerClickedShare:self];
    }
}

#pragma mark - Private

- (void)fetchLiveSpecial {
    [_liveSpecial getLiveSpecial:nil success:^(LiveSpecialModel *liveSpecial, JSONAPI *jsonApi) {
        
        _needToFetch = NO;
        _liveSpecial = liveSpecial;
        
        [self updateView];
        
    } failure:^(ErrorModel *errorModel) {
        [self showAlert:@"Oops" message:[errorModel human]];
        [Tracker logError:errorModel.error class:[self class] trace:NSStringFromSelector(_cmd)];
    }];
}

- (void)updateView {
    
    if (_liveSpecial != nil) {
        
        if (_needToFetch == YES) {
            [_activityIndicator setHidden:NO];
            [_activityIndicator startAnimating];
            return;
        }
        
        [_activityIndicator setHidden:YES];
        [_activityIndicator stopAnimating];
        
        [_lblSpecial setText:_liveSpecial.text];
        
        NSString *spotName = _liveSpecial.spot.name;
        NSString *text = [NSString stringWithFormat:@"at %@>\nwith check in", spotName];
        
        // Styles label to have underline spot name
        [_lblAt setFont:[UIFont fontWithName:@"Lato-Light" size:17.0f]];
        [_lblAt setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            // Finds range for spot name
            NSRange range = [[mutableAttributedString string] rangeOfString:spotName options:NSCaseInsensitiveSearch];
            
            // Applies underline to spot name
            if (range.location != NSNotFound) {
                [mutableAttributedString addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:range];
            }
            
            return mutableAttributedString;
        }];
        
    }
    
}

@end
