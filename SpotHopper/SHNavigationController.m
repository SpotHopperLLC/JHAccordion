//
//  SHNavigationController.m
//  SpotHopper
//
//  Created by Josh Holtz on 12/30/13.
//  Copyright (c) 2013 RokkinCat. All rights reserved.
//

#import "SHNavigationController.h"

#import "SidebarViewController.h"

#import "SHLabelLatoLight.h"

#import <JHSidebar/JHSidebarViewController.h>

@interface SHNavigationController ()<JHSidebarDelegate>

@end

@implementation SHNavigationController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupSidebar];
    
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:
                              kColorOrange,UITextAttributeTextColor,
                              [UIFont fontWithName:@"Lato-Bold" size:18.0f],
                              UITextAttributeFont,[NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                              nil];
    self.navigationBar.titleTextAttributes = attributes;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setup {
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:( SYSTEM_VERSION_LESS_THAN(@"7.0") ? @"nav_bar_background_ios6" : @"nav_bar_background_ios7" )] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    [self.navigationBar setTintColor:kColorOrange];
}

- (void)setupSidebar {
    if (self.sidebarViewController == nil) {
        
    }
    
    // Set up sidebar options
    [self.sidebarViewController setDelegate:self];
    [self.sidebarViewController enableTapGesture];
}

#pragma mark - JHSidebarDelegate

- (void)sidebar:(JHSidebarSide)side stateChanged:(JHSidebarState)state {
    if (JHSidebarRight == side) {
        SidebarViewController *sidebarViewController = (SidebarViewController*) self.sidebarViewController.rightViewController;
        [sidebarViewController sidebar:side stateChanged:state];
    }
}

@end
