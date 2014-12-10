//
//  ViewController.m
//  SpotHopper Menu Admin
//
//  Created by Tracee Pettigrew on 6/18/14.
//  Copyright (c) 2014 com.SpotHopper.admin. All rights reserved.
//

#import <limits.h>
#import <Crashlytics/Crashlytics.h>
#import "UIView+AutoLayout.h"

#import "SHMenuAdminHomeViewController.h"
#import "SHMenuAdminLoginViewController.h"
#import "SHMenuAdminSearchViewController.h"
#import "SHMenuAdminSidebarViewController.h"
#import "SHMenuAdminDrinkProfileViewController.h"
#import "SHMenuAdminTransloaditManager.h"

#import "SHAppUtil.h"

#import "UIActionSheet+BlocksKit.h"

#import "Haneke.h"
#import "JHSidebarViewController.h"

#import "SHJSONAPIResource.h"

#import "UserModel.h"
#import "SpotModel.h"
#import "MenuItemModel.h"
#import "MenuTypeModel.h"
#import "DrinkModel.h"
#import "DrinkTypeModel.h"
#import "DrinkSubTypeModel.h"
#import "BaseAlcoholModel.h"
#import "PriceModel.h"
#import "SizeModel.h"
#import "ImageModel.h"
#import "ErrorModel.h"

#import "SHMenuAdminNetworkManager.h"
#import "ImageUtil.h"
#import "ClientSessionManager.h"

#import "UIButton+FilterStyling.h"
#import "NSNumber+Currency.h"
#import "SHMenuAdminStyleSupport.h"

#import "SHMenuAdminPriceSizeRowView.h"

#import "SHMenuAdminSwipeableDrinkTableViewCell.h"
#import "SHMenuAdminEditMenuItemTableViewCell.h"

#import "SHMenuAdminIndexPathViewPair.h"

typedef enum {
	DrinkTypeBeer = 0,
	DrinkTypeWine,
	DrinkTypeCocktail
}DrinkTypes;

typedef enum {
	MenuSubtypeNone = 0,
	MenuSubtypeOnTap,
	MenuSubtypeBottles,
	MenuSubtypeRedWine,
	MenuSubtypeWhiteWine,
	MenuSubtypeSparklingWine,
	MenuSubtypeRoseWine,
	MenuSubtypeFortifiedWine,
	MenuSubtypeHouseCocktail,
	MenuSubtypeCommonCocktail
}MenuSubtypes;

#define kFilterButtonContainerHeightOffset 80.0f

#define kTopViewContainerHeight 160.0f

#define kTagPickerCell 1
#define kTagPickerView 2
#define kCookie @"Cookie"
#define kPickerCellIdentifier @"PickerCell"

#define kSizeNameNone @"None"
#define kSizeNameNoneValue @"per size"

#define MAX_PRICES_SHOWN 5

#define kMenuSubtypeNameOnTap @"Draft"
#define kMenuSubtypeNameBottled @"Cans/Bottles"
#define kMenuSubtypeNameRedWine @"Red"
#define kMenuSubtypeNameWhiteWine @"White"
#define kMenuSubtypeNameSparklingWine @"Sparkling"
#define kMenuSubtypeNameRoseWine @"Rose"
#define kMenuSubtypeNameFortifiedWine @"Fortified"
#define kMenuSubtypeNameHouseCocktail @"House Cocktails"
#define kMenuSubtypeNameCommonCocktail @"Common Cocktails"

#define kSegueHomeToSearch @"HomeToSearch"
#define kSegueHomeToDrink @"HomeToDrink"

@interface SHMenuAdminHomeViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SHMenuAdminSidebarViewControllerDelegate, SHMenuAdminSwipeableDrinkCellDelegate, SHMenuAdminEditMenuItemCellDelegate, SHMenuAdminSearchViewControllerDelegate, SHMenuAdminLoginDelegate>

@property (nonatomic, strong) SHMenuAdminSidebarViewController *rightSidebarViewController;

@property (nonatomic, strong) UserModel *user;

@property (strong, nonatomic) SpotModel *spot;
@property (assign, nonatomic) BOOL isSpotSearch;

@property (strong, nonatomic) UIButton *btnCurrentDrink;
@property (strong, nonatomic) UIButton *btnCurrentMenuSubType;

@property (assign, nonatomic) DrinkTypes currentDrinkTypeEnum;
@property (assign, nonatomic) MenuSubtypes currentMenuTypeEnum;

@property (strong, nonatomic) DrinkTypeModel *currentDrinkType;
@property (strong, nonatomic) NSString *currentMenuSubType;
@property (strong, nonatomic) UIView *currentSubTypesContainer;
@property (strong, nonatomic) SHMenuAdminPriceSizeRowView *lastSelectedContainer;

@property (strong, nonatomic) NSMutableArray *menuItems;
@property (strong, nonatomic) NSMutableArray *filteredMenuItems;

//keeps track of the index path of the cell which a photo is being taken for
@property (strong, nonatomic) NSIndexPath *indexPathForPhotoTaken;

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSIndexPath *sizePickerIndexPath;
@property (assign, nonatomic) CGFloat pickerCellRowHeight;

@property (strong, nonatomic) NSSet *menuTypes; //todo: consolidate menuTypes and menuTypeMap into one property
@property (strong, nonatomic) NSMutableDictionary *menuTypeMap;
@property (strong, nonatomic) NSMutableDictionary *typeSizeMap;
@property (strong, nonatomic) NSArray *sizes;

//dictionary of drink type enums and set of indexpaths of the cells that are currently open
@property (strong, nonatomic) NSMutableDictionary *cellWithOpenDrawers;
//drink passed to drink profile
@property (strong, nonatomic) DrinkModel *drinkToShow;
@property (weak, nonatomic) IBOutlet UILabel *lblEmpty;

//empty view that's shown when there are no menu items
@property (weak, nonatomic) IBOutlet UIView *emptyView;

#pragma mark - Pan Gesture Properties
#pragma mark -

@property (weak, nonatomic) IBOutlet UIView *topContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topContainerViewTopConstraint;
@property (assign, nonatomic) BOOL isOpeningTopContainerView;
@property (assign, nonatomic) BOOL isClosingTopContainerView;

#pragma mark - Editing Properties
#pragma mark -

@property (nonatomic, strong) MenuItemModel *editMenuItem;
//toggles whether an item is being added
@property (nonatomic, assign) BOOL isAddingMenuItem;
//toggles whether an item is being edited
@property (nonatomic, assign) BOOL isEditingMenuItem;
//tracks the index of the cell that is being edited
@property (nonatomic, assign) NSInteger indexOfRowForEditing;
//tracks the pricesizerowcontainers per index path, view, and menu typ
@property (nonatomic, strong) NSMutableDictionary *indexPathViewPairMap;
@property (nonatomic, strong) SHMenuAdminPriceSizeRowContainerView *addContainer;

#pragma mark - Main Menu Properties
#pragma mark -

@property (weak, nonatomic) IBOutlet UIView *menuTypeFilterContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnBeer;
@property (weak, nonatomic) IBOutlet UIButton *btnWine;
@property (weak, nonatomic) IBOutlet UIButton *btnCocktails;

#pragma mark - Beer Menu Properties
#pragma mark -

@property (weak, nonatomic) IBOutlet UIView *beerSubTypeContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnOnTap;
@property (weak, nonatomic) IBOutlet UIButton *btnBottles;

#pragma mark - Wine Menu Properties
#pragma mark -

@property (weak, nonatomic) IBOutlet UIView *wineSubTypeContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnRedWine;
@property (weak, nonatomic) IBOutlet UIButton *btnWhiteWine;
@property (weak, nonatomic) IBOutlet UIButton *btnSparklingWine;
@property (weak, nonatomic) IBOutlet UIButton *btnRoseWine;
@property (weak, nonatomic) IBOutlet UIButton *btnFortifiedWine;

#pragma mark - Cocktail Properties
#pragma mark -

@property (weak, nonatomic) IBOutlet UIView *cocktailSubTypeContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnHouseCocktail;
@property (weak, nonatomic) IBOutlet UIButton *btnCommonCocktail;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *txtfldContainer;
@property (weak, nonatomic) IBOutlet UITextField *txtfldAddDrink;

@end

@implementation SHMenuAdminHomeViewController

#pragma mark - Lifecycle Methods
#pragma mark -

- (void)viewDidLoad {
	[super viewDidLoad];

	// fetch supported menu sizes and types
	[self fetchMenuSizes];
	[self fetchMenuTypes];

	//setup sidebar menu
	self.rightSidebarViewController = (SHMenuAdminSidebarViewController *)self.navigationController.sidebarViewController.rightViewController;
	//[self.sidebarViewController enablePanGesture];
	[self.sidebarViewController enableTapGesture];
	self.rightSidebarViewController.delegate = self;

	//initalize stuff
	_isAddingMenuItem = FALSE;
	_isEditingMenuItem = FALSE;
	_indexOfRowForEditing = 0;

    UIEdgeInsets insets = UIEdgeInsetsMake(kTopViewContainerHeight, 0, 0, 0);
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    self.cellWithOpenDrawers = @{}.mutableCopy;

	self.menuTypes = [NSSet setWithArray:@[kMenuSubtypeNameOnTap, kMenuSubtypeNameBottled, kMenuSubtypeNameRedWine, kMenuSubtypeNameWhiteWine, kMenuSubtypeNameRoseWine, kMenuSubtypeNameFortifiedWine, kMenuSubtypeNameSparklingWine, kMenuSubtypeNameHouseCocktail, kMenuSubtypeNameCommonCocktail]];

	self.menuTypeMap = @{}.mutableCopy;
	self.typeSizeMap = @{}.mutableCopy;
	self.sizes = @[].mutableCopy;

	//initialize picker
	UITableViewCell *pickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:kPickerCellIdentifier];
	self.pickerCellRowHeight = pickerViewCellToCheck.frame.size.height;

	self.indexPathViewPairMap = [NSMutableDictionary dictionary];
	self.addContainer = nil;

	//apply styling
	[self styleHome];

	//set beer as default
	self.btnBeer.enabled = FALSE;
	self.btnCurrentDrink = self.btnBeer;
	self.btnCurrentDrink.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].ORANGE;
	self.currentDrinkType = [DrinkTypeModel beerDrinkType];
	[self changeAddTextToDrinkType:self.currentDrinkType];
	self.currentDrinkTypeEnum = DrinkTypeBeer;

	//set on-tap as default
	self.btnOnTap.enabled = FALSE;
	self.btnCurrentMenuSubType = self.btnOnTap;
	self.btnCurrentMenuSubType.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].ORANGE;
	self.currentMenuSubType = kMenuSubtypeNameOnTap;
	self.currentMenuTypeEnum = MenuSubtypeOnTap;

	self.currentSubTypesContainer = self.beerSubTypeContainer;

	if (([[ClientSessionManager sharedClient] isLoggedIn]) && ([[ClientSessionManager sharedClient] hasSeenLaunch])) {
		[self showHUD:@"Loading Menu"];

		[self configureForUser];

		//show hud while loading menu initially
		[self fetchUserSpots: ^{
		    //fetch menu items
		    [self fetchMenuItems];
		} failure:^{
            [self hideHUD];
        }];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
	    // if the user is not logged in or has not seen the launch screen at once... go to the login screen
	    if (!([[ClientSessionManager sharedClient] isLoggedIn]) || !([[ClientSessionManager sharedClient] hasSeenLaunch])) {
	        [self performSegueWithIdentifier:@"HomeToLogin" sender:self];
		}
	    else if ([[ClientSessionManager sharedClient] isLoggedIn]) {
	        UserModel *currentUser = [UserModel currentUser];

	        if ([@"user" isEqualToString: currentUser.role]) {
	            // display a modal explaining that they are not set up to manage
	            // any spot yet and provide a button which will bring up the mail
	            // message sheet to email support.
	            [self hideHUD];
	            [self performSegueWithIdentifier:@"HomeToNotAdmin" sender:self];
			}
		}
	});

	self.navigationController.title = self.spot.name;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    if (self.tableView.hidden) {
        DebugLog(@"Table View is Hidden");
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.destinationViewController isKindOfClass:[SHMenuAdminLoginViewController class]]) {
		SHMenuAdminLoginViewController *vc = (SHMenuAdminLoginViewController *)segue.destinationViewController;
		vc.delegate = self;
	}
	else if ([segue.destinationViewController isKindOfClass:[SHMenuAdminSearchViewController class]]) {
		SHMenuAdminSearchViewController *vc = (SHMenuAdminSearchViewController *)segue.destinationViewController;

		//todo: implement logic for isSpotSearch
		if (self.isSpotSearch) {
			vc.isSpotSearch = TRUE;
		}

		//get current drink type based on button and pass drink type
		vc.drinkType = self.currentDrinkType;
		vc.filteredMenuItems = self.filteredMenuItems;
		vc.menuType = self.currentMenuSubType;

		if ([self.currentMenuSubType isEqualToString:kMenuSubtypeNameHouseCocktail]) {
			vc.isHouseCocktail = TRUE;
			vc.spot = self.spot;
			vc.drinkSubType = [DrinkSubTypeModel houseCocktailDrinkSubType];
		}
		else if ([self.currentMenuSubType isEqualToString:kMenuSubtypeNameCommonCocktail]) {
			vc.drinkSubType = [DrinkSubTypeModel commonCocktailDrinkSubType];
			vc.spot = nil;
		}

		vc.delegate = self;
	}
	else if ([segue.destinationViewController isKindOfClass:[SHMenuAdminDrinkProfileViewController class]]) {
		SHMenuAdminDrinkProfileViewController *vc = (SHMenuAdminDrinkProfileViewController *)segue.destinationViewController;
		vc.drink = self.drinkToShow;
	}
}

#pragma mark - Menu Toggle Actions
#pragma mark -

- (void)changeAddTextToDrinkType:(DrinkTypeModel *)drinkType {
	if ([drinkType isBeer]) {
		self.txtfldAddDrink.text = @"Add new beer named...";
	}
	else if ([drinkType isWine]) {
		self.txtfldAddDrink.text = @"Add new wine named...";
	}
	else if ([drinkType isCocktail]) {
		self.txtfldAddDrink.text = @"Add new cocktail named...";
	}
}

- (IBAction)toggleDrinkTypeButtons:(UIButton *)buttonPressed {
	MAAssert(buttonPressed, @"button can't be null");
	//return old drink button to original state
	self.btnCurrentDrink.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].LIGHT_ORANGE;
	self.btnCurrentDrink.enabled = TRUE;

	self.btnCurrentDrink = buttonPressed;
	self.btnCurrentDrink.enabled = FALSE;
	self.btnCurrentDrink.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].ORANGE;

	if ([buttonPressed isEqual:self.btnBeer]) {
		self.beerSubTypeContainer.hidden = FALSE;

		[self setCurrentSubTypesButton:self.btnOnTap];
		[self setSubTypesContainer:self.beerSubTypeContainer];

		self.currentDrinkType = [DrinkTypeModel beerDrinkType];
		self.currentMenuSubType = kMenuSubtypeNameOnTap;
		[self changeAddTextToDrinkType:self.currentDrinkType];

		//set state of enums
		self.currentDrinkTypeEnum = DrinkTypeBeer;
		self.currentMenuTypeEnum = MenuSubtypeOnTap;

		[self filterMenuItems:DrinkTypeBeer subTypes:MenuSubtypeOnTap];
	}
	else if ([buttonPressed isEqual:self.btnWine]) {
		self.wineSubTypeContainer.hidden = FALSE;

		[self setCurrentSubTypesButton:self.btnRedWine];
		[self setSubTypesContainer:self.wineSubTypeContainer];

		self.currentDrinkType = [DrinkTypeModel wineDrinkType];
		self.currentMenuSubType = kMenuSubtypeNameRedWine;
		[self changeAddTextToDrinkType:self.currentDrinkType];

		self.currentDrinkTypeEnum = DrinkTypeWine;
		self.currentMenuTypeEnum = MenuSubtypeRedWine;

		[self filterMenuItems:DrinkTypeWine subTypes:MenuSubtypeRedWine];
	}
	else if ([buttonPressed isEqual:self.btnCocktails]) {
		self.cocktailSubTypeContainer.hidden = FALSE;

		[self setCurrentSubTypesButton:self.btnHouseCocktail];
		[self setSubTypesContainer:self.cocktailSubTypeContainer];

		self.currentDrinkType = [DrinkTypeModel cocktailDrinkType];
		self.currentMenuSubType = kMenuSubtypeNameHouseCocktail;
		[self changeAddTextToDrinkType:self.currentDrinkType];

		self.currentDrinkTypeEnum = DrinkTypeCocktail;
		self.currentMenuTypeEnum = MenuSubtypeHouseCocktail;

		[self filterMenuItems:DrinkTypeCocktail subTypes:MenuSubtypeHouseCocktail];
	}
}

- (IBAction)toggleBeerSubtypeButtons:(UIButton *)buttonPressed {
	MAAssert(buttonPressed, @"button can't be null");

	[self setCurrentSubTypesButton:buttonPressed];

	if ([buttonPressed isEqual:self.btnOnTap]) {
		self.currentMenuSubType = kMenuSubtypeNameOnTap;
		self.currentMenuTypeEnum = MenuSubtypeOnTap;

		[self filterMenuItems:DrinkTypeBeer subTypes:MenuSubtypeOnTap];
	}
	else if ([buttonPressed isEqual:self.btnBottles]) {
		self.currentMenuSubType = kMenuSubtypeNameBottled;
		self.currentMenuTypeEnum = MenuSubtypeBottles;

		[self filterMenuItems:DrinkTypeBeer subTypes:MenuSubtypeBottles];
	}
	else {
		MAAssert(buttonPressed, @"button pressed must be a beer btn");
	}
}

- (IBAction)toggleWineSubtypeButtons:(UIButton *)buttonPressed {
	MAAssert(buttonPressed, @"button can't be null");

	[self setCurrentSubTypesButton:buttonPressed];

	if ([buttonPressed isEqual:self.btnRedWine]) {
		self.currentMenuSubType = kMenuSubtypeNameRedWine;
		self.currentMenuTypeEnum = MenuSubtypeRedWine;

		[self filterMenuItems:DrinkTypeWine subTypes:MenuSubtypeRedWine];
	}
	else if ([buttonPressed isEqual:self.btnWhiteWine]) {
		self.currentMenuSubType = kMenuSubtypeNameWhiteWine;
		self.currentMenuTypeEnum = MenuSubtypeWhiteWine;

		[self filterMenuItems:DrinkTypeWine subTypes:MenuSubtypeWhiteWine];
	}
	else if ([buttonPressed isEqual:self.btnSparklingWine]) {
		self.currentMenuSubType = kMenuSubtypeNameSparklingWine;
		self.currentMenuTypeEnum = MenuSubtypeSparklingWine;

		[self filterMenuItems:DrinkTypeWine subTypes:MenuSubtypeSparklingWine];
	}
	else if ([buttonPressed isEqual:self.btnRoseWine]) {
		self.currentMenuSubType = kMenuSubtypeNameRoseWine;
		self.currentMenuTypeEnum = MenuSubtypeRoseWine;

		[self filterMenuItems:DrinkTypeWine subTypes:MenuSubtypeRoseWine];
	}
	else if ([buttonPressed isEqual:self.btnFortifiedWine]) {
		self.currentMenuSubType = kMenuSubtypeNameFortifiedWine;
		self.currentMenuTypeEnum = MenuSubtypeFortifiedWine;

		[self filterMenuItems:DrinkTypeWine subTypes:MenuSubtypeFortifiedWine];
	}
	else {
		MAAssert(buttonPressed, @"button pressed must be a wine btn");
	}
}

- (IBAction)toggleCocktailSubtypeButtons:(UIButton *)buttonPressed {
	MAAssert(buttonPressed, @"button can't be null");

	[self setCurrentSubTypesButton:buttonPressed];

	if ([buttonPressed isEqual:self.btnHouseCocktail]) {
		self.currentMenuSubType = kMenuSubtypeNameHouseCocktail;
		self.currentMenuTypeEnum = MenuSubtypeHouseCocktail;

		[self filterMenuItems:DrinkTypeCocktail subTypes:MenuSubtypeHouseCocktail];
	}
	else if ([buttonPressed isEqual:self.btnCommonCocktail]) {
		self.currentMenuSubType = kMenuSubtypeNameCommonCocktail;
		self.currentMenuTypeEnum = MenuSubtypeCommonCocktail;

		[self filterMenuItems:DrinkTypeCocktail subTypes:MenuSubtypeCommonCocktail];
	}
	else {
		MAAssert(buttonPressed, @"button pressed must be a cocktail btn");
	}
}

#pragma mark - SHMenuAdminLoginDelegate
#pragma mark -

- (void)loginDidFinish:(SHMenuAdminLoginViewController *)loginViewController {
//    [self hideHUD];
	[self configureForUser];
	[self fetchUserSpots: ^{
	    [self fetchMenuItems];
	} failure:^{
        DebugLog(@"Failed to load user spots");
    }];
}

#pragma mark - Sidebar Menu/Delegate
#pragma mark -

- (IBAction)onClickRight:(id)sender {
	// open sidebar
	[self.navigationController.sidebarViewController toggleRightSidebar];
}

- (void)closeButtonTapped:(SHMenuAdminSidebarViewController *)sidebarViewController {
	//close sidebar
	[self.navigationController.sidebarViewController toggleRightSidebar];
}

- (void)viewAllSpotsTapped:(SHMenuAdminSidebarViewController *)sidebarViewController {
	[self.navigationController.sidebarViewController toggleRightSidebar];
	self.isSpotSearch = TRUE;

	[self performSegueWithIdentifier:kSegueHomeToSearch sender:self];
}

- (void)spotTapped:(SHMenuAdminSidebarViewController *)sidebarViewController spot:(SpotModel *)spot {
	[self.navigationController.sidebarViewController toggleRightSidebar];

	[self updateSpot:spot];
}

- (void)logoutTapped:(SHMenuAdminSidebarViewController *)sidebarViewController {
	[[ClientSessionManager sharedClient] logout];
	[[ClientSessionManager sharedClient] setHasSeenLaunch:FALSE];

	[self performSegueWithIdentifier:@"HomeToLogin" sender:self];
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rows = self.filteredMenuItems.count;

	if ([self sizePickerIsShown]) {
		rows++;
	}

	return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"ButtonsCell";
	static NSString *EditCellIdentifier = @"EditCell";
    
	if ([self sizePickerIsShown] && (self.sizePickerIndexPath.row == indexPath.row)) {
		UITableViewCell *pickerCell = [tableView dequeueReusableCellWithIdentifier:kPickerCellIdentifier];

		if (!pickerCell) {
			pickerCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPickerCellIdentifier];
		}

        self.pickerView = (UIPickerView *)[pickerCell viewWithTag:kTagPickerView];
        
        MAAssert(pickerCell, @"Cell must be defined");

		return pickerCell;
	}

	//if the cell is being edited then cause it to grow
	if (self.isEditingMenuItem || self.isAddingMenuItem) {
		if (indexPath.section == 0 && indexPath.row == self.indexOfRowForEditing) {
            MAAssert(self.editMenuItem, @"edit menu item should be set");

			SHMenuAdminEditMenuItemTableViewCell *editCell = [tableView dequeueReusableCellWithIdentifier:EditCellIdentifier];
			editCell.delegate = self;

			//handle if adding item and not editing
			if (self.isAddingMenuItem) {
				[editCell configureCellForAdd];
			}
			else {
				[editCell configureCellForEdit];
			}

			editCell.lblDrinkName.text = self.editMenuItem.drink.name;
			editCell.lblBrewSpot.text = self.editMenuItem.drink.spot.name;

			if ([self.editMenuItem.drink.drinkType isBeer]) {
				editCell.lblDrinkSpecifics.text = self.editMenuItem.drink.style;
			}
			else if ([self.editMenuItem.drink.drinkType isWine]) {
				editCell.lblDrinkSpecifics.text = self.editMenuItem.drink.varietal;
			}
			else if ([self.editMenuItem.drink.drinkType isCocktail]) {
				//check to see if there are base alcohols
				if (self.editMenuItem.drink.baseAlochols.count > 0) {
					BaseAlcoholModel *baseAlcohol = [self.editMenuItem.drink.baseAlochols objectAtIndex:0];
					editCell.lblDrinkSpecifics.text = baseAlcohol.name;
				}
			}
			else {
				MAAssert(FALSE, @"Drink Type is not supported");
			}

			if (self.editMenuItem.drink.images.count) {
				//assumption that there is only one photo per drink
				ImageModel *imageModel = [self.editMenuItem.drink.images firstObject];
				[editCell.drinkImage hnk_setImageFromURL:[NSURL URLWithString:imageModel.thumbUrl]];
			}
			else {
				//placeholder images
				UIImage *placeHolderImage = [self placeHolderImageForType:self.editMenuItem];
				editCell.drinkImage.image = placeHolderImage;
			}

			//remove container already in the wrappper if there is one
			[[editCell.priceSizeWrapper.subviews firstObject] removeFromSuperview];

			SHMenuAdminPriceSizeRowContainerView *container;

			if (self.isEditingMenuItem) {
				if (!(container = [self getViewForEditCellAtIndexPath:indexPath])) {
					//create a new indexpathview pair since one doesn't exist
					//add container to view
					container = [[SHMenuAdminPriceSizeRowContainerView alloc]init];
					container.delegate = editCell;
					SHMenuAdminIndexPathViewPair *ipvp = [[SHMenuAdminIndexPathViewPair alloc]init:indexPath view:container];
					[self addNewPathViewPair:ipvp];
				}
			}
			else {
				container = [self containerForAdd:editCell];
			}

			[editCell.priceSizeWrapper addSubview:container];

			//configure cell rows
			if (self.editMenuItem.prices.count) {
				SHMenuAdminPriceSizeRowContainerView *container = [editCell.priceSizeWrapper.subviews firstObject];
				//for each price
				// if the first price use default row provided
				//else (each additional row)
				//add new row to container
				//configure new container
				for (NSInteger i = 0; i < self.editMenuItem.prices.count; i++) {
					//default case
					if (i == 0) {
						SHMenuAdminPriceSizeRowView *row = [container.subviews firstObject];
						[self configurePriceSizeRow:row withPriceSize:[self.editMenuItem.prices firstObject]];
					}
					else {
						//if the container subviews are less than the number of prices
						//add new row
						//configure row
						if (container.subviews.count < self.editMenuItem.prices.count) {
							SHMenuAdminPriceSizeRowView *row = [container addNewPriceSizeRow];
							PriceModel *price = self.editMenuItem.prices[i];
							[self configurePriceSizeRow:row withPriceSize:price];
						}
					}
				}
			}

            editCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            MAAssert(editCell, @"Cell must be defined");
            
			return editCell;
		}
	}

	//normal view
	if (indexPath.row < self.menuItems.count) {
		MenuItemModel *menuItem = [self.filteredMenuItems objectAtIndex:indexPath.row];

		SHMenuAdminSwipeableDrinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
		cell.delegate = self;

		cell.lblDrinkName.text = menuItem.drink.name;
		cell.lblBrewSpot.text = menuItem.drink.spot.name;

		if ([menuItem.drink.drinkType.name isEqualToString:kDrinkTypeNameBeer]) {
			cell.lblDrinkSpecifics.text = menuItem.drink.style;
		}
		else if ([menuItem.drink.drinkType.name isEqualToString:kDrinkTypeNameWine]) {
			cell.lblDrinkSpecifics.text = menuItem.drink.varietal;
		}
		else if ([menuItem.drink.drinkType.name isEqualToString:kDrinkTypeNameCocktail]) {
			//check to see if there are base alcohols
			if (menuItem.drink.baseAlochols.count > 0) {
				BaseAlcoholModel *baseAlcohol = [menuItem.drink.baseAlochols objectAtIndex:0];
				cell.lblDrinkSpecifics.text = baseAlcohol.name;
			}
		}
		else {
			MAAssert(menuItem.drink.drinkType.name, @"Unknown type for drinks");
		}

		if (menuItem.drink.images.count) {
			//assumption that there is only one photo per drink
			ImageModel *imageModel = [menuItem.drink.images firstObject];
			[cell.drinkImage hnk_setImageFromURL:[NSURL URLWithString:imageModel.thumbUrl]];
		}
		else {
			//placeholder images
			UIImage *placeHolderImage = [self placeHolderImageForType:menuItem];
			if (!placeHolderImage) {
				MAAssert(placeHolderImage, @"unsupported drink type");
			}
			cell.drinkImage.image = placeHolderImage;
		}

		if (menuItem.prices.count) {
			//sort prices HERE
			menuItem.prices = [menuItem.prices sortedArrayUsingComparator: ^NSComparisonResult (PriceModel *a, PriceModel *b) {
			    return [a.cents compare:b.cents];
			}];

			NSString *prices = @"";
			NSInteger count = 0;

			for (PriceModel *price in menuItem.prices) {
				if ((price.cents || price.size) && (count <= MAX_PRICES_SHOWN)) {
					NSString *priceString = [price priceAndSize];
					if (priceString.length) {
						prices = [NSString stringWithFormat:@"%@ \n", [prices stringByAppendingString:priceString]];
					}
				}
				count++;
			}

			cell.lblPrice.text = prices;
		}
		else {
			cell.lblPrice.text = @"";
		}

		//find the current subtype
		//get set out of dictionary
		//check if set has cell needs to be open
		//open cell
		if ([self.cellWithOpenDrawers objectForKey:self.currentMenuSubType]) {
			NSMutableSet *storedIndexes = [self.cellWithOpenDrawers objectForKey:self.currentMenuSubType];
			if ([storedIndexes containsObject:indexPath]) {
				[cell openCell];
			}
		}
        
        MAAssert(cell, @"Cell must be defined");

		return cell;
	}

    // HACK: create a dummy cell to prevent crashes (should not be necessary but is a hack for now until it can be fixed properly)
    DebugLog(@"Returning Hack Cell");
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HackCell"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 120.f;
	//if the size picker is showing then indexpath row does not match the backing array of
	//filtered menu itemss
	MenuItemModel *menuItem = nil;
	if ([self sizePickerIsShown]) {
		if (indexPath.row > self.sizePickerIndexPath.row) {
			NSInteger row = indexPath.row - 1;
			menuItem = [self.filteredMenuItems objectAtIndex:row];
		}
	}
	else {
		menuItem = [self.filteredMenuItems objectAtIndex:indexPath.row];
	}

	//if the cell is being edited then cause it to grow
	if (self.isEditingMenuItem || self.isAddingMenuItem) {
		if (indexPath.section == 0 && indexPath.row == self.indexOfRowForEditing) {
			SHMenuAdminPriceSizeRowContainerView *container;
			if (self.isEditingMenuItem) {
				container = [self getViewForEditCellAtIndexPath:indexPath];
			}
			else {
				container = self.addContainer;
			}

			if (container.subviews.count > self.editMenuItem.prices.count) {
				height =  175.0f + container.height + 8.0f; //8.0f = bottom padding
			}
			else {
				NSInteger menuPrices = 0;

				if (self.editMenuItem.prices.count > MAX_PRICES_SHOWN) {
					menuPrices = MAX_PRICES_SHOWN;
				}
				else {
					menuPrices = self.editMenuItem.prices.count;
				}

				height = 175.0f + (menuPrices * kPriceSizeRowHeight) + 8.0f;
			}

			return height;
		}
	}

	if ([self sizePickerIsShown] && (self.sizePickerIndexPath.row == indexPath.row)) {
		return height = self.pickerCellRowHeight;
	}

	NSString *prices = @"";
	for (PriceModel *price in menuItem.prices) {
		if (price.cents || price.size) {
			NSString *priceString = [price priceAndSize];
			if (priceString.length) {
				prices = [NSString stringWithFormat:@"%@ \n", [prices stringByAppendingString:priceString]];
			}
		}
	}

	CGFloat priceTextHeight = [[SHAppUtil defaultInstance] heightForString:prices font:[UIFont systemFontOfSize:10.0f] maxWidth:self.tableView.frame.size.width];

	return height + priceTextHeight;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//do nothing
}

#pragma mark - UIScrollViewDelegate
#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isOpeningTopContainerView && scrollView == self.tableView) {
        if (scrollView.hidden) {
            // do not scroll table view when it is hidden
            return;
        }
        
        CGFloat y = scrollView.contentOffset.y + kTopViewContainerHeight;
        if (y > 0) {
            CGFloat targetY = MAX(0 - kTopViewContainerHeight, 0 - y);
            CGRect frame = self.topContainerView.frame;
            if (frame.origin.y > targetY) {
                frame.origin.y = targetY;
                self.topContainerView.frame = frame;
                self.topContainerViewTopConstraint.constant = targetY;
            }
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == self.tableView) {
        CGFloat y = targetContentOffset->y + kTopViewContainerHeight;
        if (y == 0 && velocity.y < 0) {
            [self openTopContainerViewWithCompletionBlock:^{
                // done
            }];
        }
    }
}

#pragma mark - SwipeableDrinkCellDelegate - User Actions
#pragma mark -

- (void)drinkLabelTapped:(SHMenuAdminSwipeableDrinkTableViewCell *)cell {
	DebugLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)photoButtonTapped:(SHMenuAdminSwipeableDrinkTableViewCell *)cell {
	[self selectPhotoForCell:cell];
}

- (void)flavorProfileButtonTapped:(SHMenuAdminSwipeableDrinkTableViewCell *)cell {
	DebugLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)editButtonTapped:(SHMenuAdminSwipeableDrinkTableViewCell *)cell {
	//set isEditing bool TRUE
	//trigger reload on table view @ index of the cell to resize the cell
	//disable swipe gestures on the cell
	//show edit view

	self.isEditingMenuItem = TRUE;

	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

	if (!indexPath) {
		MAAssert(indexPath, @"cell should've been found");
	}

	self.indexOfRowForEditing = indexPath.row;
	self.editMenuItem = [[self.filteredMenuItems objectAtIndex:indexPath.row] copy];

	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];

    CGRect frame = [self.tableView rectForRowAtIndexPath:indexPath];
    LOG_FRAME(@"cell", frame);
    [self.tableView setContentOffset:frame.origin animated:TRUE];
    
    //scroll cell to top that's being edited
//    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
    
//    [self closeTopContainerViewWithCompletionBlock:^{
//    }];
}

- (void)deleteButtonTapped:(SHMenuAdminSwipeableDrinkTableViewCell *)cell {
	//get menu item @ index
	//do request to delete
	//update view on success

	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

	if (!indexPath) {
		MAAssert(indexPath, @"cell should've been found");
	}

	MenuItemModel *menuItem = self.filteredMenuItems[indexPath.row];
    
    [SpotModel deleteMenuItem:menuItem spot:self.spot success:^{
        [self.filteredMenuItems removeObject:menuItem];
        [self.menuItems removeObject:menuItem];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        
        if (!self.filteredMenuItems.count) {
            [self openTopContainerViewWithCompletionBlock:^{
                // done
            }];
            [self showEmptyView:TRUE];
        }
    } failure:^(ErrorModel *errorModel) {
        [self showAlert:@"Error" message:@"Unable to delete menu item."];
        CLS_LOG(@"network error deleting menu item [%@]. Error:%@", menuItem, errorModel.humanValidations);
    }];
}

#pragma mark - SwipeableDrinkCellDelegate - Open/Close callbacks
#pragma mark -

- (void)cellDidOpen:(UITableViewCell *)cell {
	if (cell) {
		NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];

		if ([self.cellWithOpenDrawers objectForKey:self.currentMenuSubType]) {
			//if key already exists...
			NSMutableSet *storedIndexes = [self.cellWithOpenDrawers objectForKey:self.currentMenuSubType];
			[storedIndexes addObject:currentEditingIndexPath];
			[self.cellWithOpenDrawers setObject:storedIndexes forKey:self.currentMenuSubType];
		}
		else {
			//if the key is not already in dictionary, add key and new array with size
			//if supported filter type
			if ([self.menuTypes containsObject:self.currentMenuSubType]) {
				NSMutableSet *storedIndexes = [NSMutableSet set];
				[storedIndexes addObject:currentEditingIndexPath];

				[self.cellWithOpenDrawers setObject:storedIndexes forKey:self.currentMenuSubType];
			}
		}
	}
}

- (void)cellDidClose:(UITableViewCell *)cell {
	if (cell) {
		if ([self.cellWithOpenDrawers objectForKey:self.currentMenuSubType]) {
			NSMutableSet *storedIndexes = [self.cellWithOpenDrawers objectForKey:self.currentMenuSubType];
			[storedIndexes removeObject:[self.tableView indexPathForCell:cell]];
		}
	}
}

#pragma mark - EditMenuItemCellDelegate - User Actions
#pragma mark -

- (void)addPriceAndSizeButtonTapped:(SHMenuAdminEditMenuItemTableViewCell *)cell {
	self.editMenuItem = [self gatherInfoToCreateMenuItem:cell];

	//if the cell is the last cell then offset the tableview
	NSInteger totalRows = [self.tableView numberOfRowsInSection:0];
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

	if (indexPath.row == (totalRows - 1)) {
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:TRUE];
	}

	[self.tableView reloadData];
}

- (void)removePriceAndSizeButtonTapped:(SHMenuAdminEditMenuItemTableViewCell *)cell indexOfRemoved:(NSInteger)indexOfRemovedRow {
	//have to figure out the index of prices which you have to remove
	if (indexOfRemovedRow < self.editMenuItem.prices.count) {
		NSMutableArray *editPrices = [self.editMenuItem.prices mutableCopy];
		[editPrices removeObjectAtIndex:indexOfRemovedRow];
		self.editMenuItem.prices = editPrices;
	}

	[self.tableView reloadData];
}

- (void)cancelButtonTapped:(SHMenuAdminEditMenuItemTableViewCell *)cell {
	self.editMenuItem = nil;

	//set isEditing to FALSE and reload table view
	if (self.isEditingMenuItem) {
		self.isEditingMenuItem = FALSE;
	}

	if (self.isAddingMenuItem) {
		self.isAddingMenuItem = FALSE;
		self.addContainer = nil;
		[self.filteredMenuItems removeObjectAtIndex:0]; //removes the newly added drink
	}

	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

	if ([self sizePickerIsShown]) {
		[self toggleSizePicker:indexPath];
	}

	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];

	if (!self.filteredMenuItems.count) {
		[self showEmptyView:TRUE];
	}
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CGRect frame = [self.tableView rectForRowAtIndexPath:indexPath];
        CGPoint point = frame.origin;
        point.y -= kTopViewContainerHeight;
        [self.tableView setContentOffset:point animated:TRUE];
        [self openTopContainerViewWithCompletionBlock:^{
            // done
        }];
    });
}

- (void)addButtonTapped:(SHMenuAdminEditMenuItemTableViewCell *)cell {
	__weak SHMenuAdminHomeViewController *hvc = self;
	self.editMenuItem = [self gatherInfoToCreateMenuItem:cell];

	//post new menu item
	[self createMenuItem:self.editMenuItem success: ^{
	    //show save alert
	    //1. remove edit cell at that row
	    //2. close drawer and hide picker or keyboard if shown
	    //3. show updated tableview
	    //   remove the cell from list of cells that are open

	    hvc.isAddingMenuItem = FALSE;
	    hvc.addContainer = nil;

        [hvc.view endEditing:TRUE];

	    //refresh view
	    [hvc.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
	}];
}

- (void)saveButtonTapped:(SHMenuAdminEditMenuItemTableViewCell *)cell {
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	MenuItemModel *menuItem = self.filteredMenuItems[indexPath.row];

	self.editMenuItem = [self gatherInfoToCreateMenuItem:cell];

	[self saveEdits:self.editMenuItem success: ^{
	    //show save alert

	    //1. remove edit cell at that row
	    //2. close drawer and hide picker or keyboard if shown
	    //3. show updated tableview
	    self.isEditingMenuItem = FALSE;

	    // replace edit menu item prices with menu item
	    menuItem.prices = self.editMenuItem.prices;

	    //remove the cell from list of cells that are oepn
	    if ([self.cellWithOpenDrawers objectForKey:self.currentMenuSubType]) {
	        NSMutableSet *storedIndexes = [self.cellWithOpenDrawers objectForKey:self.currentMenuSubType];

	        if ([storedIndexes containsObject:indexPath]) {
	            [storedIndexes removeObject:indexPath];
			}
		}

        [self.view endEditing:TRUE];

	    //refresh view
	    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            CGRect frame = [self.tableView rectForRowAtIndexPath:indexPath];
            CGPoint point = frame.origin;
            point.y -= kTopViewContainerHeight;
            [self.tableView setContentOffset:point animated:TRUE];
            [self openTopContainerViewWithCompletionBlock:^{
                // done
            }];
        });
	}];
}

- (void)sizeLabelTapped:(SHMenuAdminEditMenuItemTableViewCell *)cell priceSizeContainer:(SHMenuAdminPriceSizeRowView *)row {
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	MenuItemModel *menuItem = self.filteredMenuItems[indexPath.row];
	[self.view endEditing:TRUE];

	//if the size picker is not shown
	//show size picker
	//if already shown
	//refresh the pciker data source with the sizes
	if (![self sizePickerIsShown]) {
		[self toggleSizePicker:indexPath];
	}

	//set sizes for the picker view
	if ([self.menuTypes containsObject:menuItem.menuType.name]) {
		NSMutableArray *displaySizes = [[self.typeSizeMap objectForKey:menuItem.menuType.name] mutableCopy];
		SizeModel *none = [SizeModel new];
		none.name = kSizeNameNone;
		none.ID = [NSNumber numberWithInt:INT32_MAX];
		[displaySizes insertObject:none atIndex:0];

		self.sizes = displaySizes;
	}

	self.lastSelectedContainer = row;

	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
	[self.pickerView reloadAllComponents];
}

#pragma mark - Image Picker Delegate
#pragma mark -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
	if (!image) {
		// get the original image instead of the edited version
		image = [info objectForKey:UIImagePickerControllerOriginalImage];
	}

	//todo: show image in the appropriate cell
	SHMenuAdminSwipeableDrinkTableViewCell *cell = (SHMenuAdminSwipeableDrinkTableViewCell *)[self.tableView cellForRowAtIndexPath:self.indexPathForPhotoTaken];
	cell.drinkImage.image = image;

	MenuItemModel *menuItem = [self.filteredMenuItems objectAtIndex:self.indexPathForPhotoTaken.row];

	if (!menuItem) {
		MAAssert(menuItem, @"menu item which picture was taken for should exist");
	}

	[self showHUD:@"Uploading..."];

	SHMenuAdminTransloaditManager *transloaditManager = [[SHMenuAdminTransloaditManager alloc] init];
	[transloaditManager uploadDrinkImageToTransloadit:image withCompletionBlock: ^(NSString *path, NSError *error) {
	    [DrinkModel createPhotoForDrink:path drink:menuItem.drink success: ^(ImageModel *imageModel) {
	        [self hideHUD];
	        //insert photo into array
	        NSMutableArray *images = [menuItem.drink.images mutableCopy];
	        [images insertObject:imageModel atIndex:0];
	        menuItem.drink.images = images;
		} failure: ^(ErrorModel *error) {
	        [self hideHUD];
	        CLSLog(@"saving image path to backend failed");
		}];
	}];

	[picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - PickerView Datasource
#pragma mark -

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return self.sizes.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	SizeModel *size = self.sizes[row];
	return size.name;
}

#pragma mark -  PickerView Delegate
#pragma mark -

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	SizeModel *size = self.sizes[row];

	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.indexOfRowForEditing inSection:0];
	SHMenuAdminEditMenuItemTableViewCell *cell = (SHMenuAdminEditMenuItemTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];

	if (!self.lastSelectedContainer || ![cell.priceSizeWrapper.subviews containsObject:self.lastSelectedContainer]) {
		MAAssert(self.lastSelectedContainer, @"last selected price size container cannot be nil");
	}

	NSString *displaySize = nil;
	if ([size.name isEqualToString:kSizeNameNone]) {
		displaySize = kSizeNameNoneValue;
	}
	else {
		displaySize = size.name;
	}

	self.lastSelectedContainer.lblSize.text = displaySize;
}

#pragma mark - Picker Helpers
#pragma mark -

- (BOOL)sizePickerIsShown {
	return self.sizePickerIndexPath != nil;
}

- (void)toggleSizePicker:(NSIndexPath *)indexPath {
	[self.tableView beginUpdates];

	if ([self sizePickerIsShown]) {
		[self hideExistingPicker];
	}
	else {
		NSIndexPath *newPickerIndexPath = [self calculateIndexPathForNewPicker:indexPath];

		if ([self sizePickerIsShown]) {
			[self hideExistingPicker];
		}

		[self showNewPickerAtIndex:newPickerIndexPath];

		self.sizePickerIndexPath = [NSIndexPath indexPathForRow:newPickerIndexPath.row + 1 inSection:0];

		//find the menu item at the index of the active container
		//if the menu item has a size
		//find index of the size
		//initialize picker at that position
		NSIndexPath *indexPath = [[self.tableView indexPathsForVisibleRows]firstObject];
		MenuItemModel *menuItem =  [self.filteredMenuItems objectAtIndex:indexPath.row];

		PriceModel *price = [menuItem.prices firstObject];

		if (price.size) {
			NSInteger index = [self.sizes indexOfObject:price.size];
			[self.pickerView selectRow:index inComponent:0 animated:TRUE];
		}
	}

	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self.tableView endUpdates];
}

- (NSIndexPath *)calculateIndexPathForNewPicker:(NSIndexPath *)selectedIndexPath {
	NSIndexPath *newIndexPath;

	if (([self sizePickerIsShown]) && (self.sizePickerIndexPath.row < selectedIndexPath.row)) {
		newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row - 1 inSection:0];
	}
	else {
		newIndexPath = [NSIndexPath indexPathForRow:selectedIndexPath.row inSection:0];
	}

	return newIndexPath;
}

- (void)showNewPickerAtIndex:(NSIndexPath *)indexPath {
	NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
	[self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void)hideExistingPicker {
	[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.sizePickerIndexPath.row inSection:0]]
	                      withRowAnimation:UITableViewRowAnimationFade];

	self.sizePickerIndexPath = nil;
}

#pragma mark - Layout Helpers
#pragma mark -

- (void)openTopContainerViewWithCompletionBlock:(void (^)())completionBlock {
    self.isOpeningTopContainerView = TRUE;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:5.0 options:options animations:^{
        CGRect frame = self.topContainerView.frame;
        frame.origin.y = 0;
        self.topContainerView.frame = frame;
    } completion:^(BOOL finished) {
        self.topContainerViewTopConstraint.constant = 0;
        // give it a moment to settle
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.isOpeningTopContainerView = FALSE;
            
            if (completionBlock) {
                completionBlock();
            }
        });
    }];
}

- (void)closeTopContainerViewWithCompletionBlock:(void (^)())completionBlock {
    self.isClosingTopContainerView = TRUE;
    CGFloat targetY = kTopViewContainerHeight * -1;
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:5.0 options:options animations:^{
        CGRect frame = self.topContainerView.frame;
        frame.origin.y = targetY;
        self.topContainerView.frame = frame;
    } completion:^(BOOL finished) {
        self.topContainerViewTopConstraint.constant = targetY;
        // give it a moment to settle
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.isClosingTopContainerView = FALSE;
            
            if (completionBlock) {
                completionBlock();
            }
        });
    }];
}

#pragma mark - SearchViewController Delegate
#pragma mark -

- (void)searchViewController:(SHMenuAdminSearchViewController *)viewController selectedDrink:(DrinkModel *)drink {
	DebugLog(@"%@", NSStringFromSelector(_cmd));

	if (!self.emptyView.isHidden) {
		[self showEmptyView:FALSE];
	}

	//create new menu item
	MenuItemModel *menuItem = [[MenuItemModel alloc] init];
	menuItem.drink = drink;

	//need menu type id
	MenuTypeModel *menuType = [[MenuTypeModel alloc] init];
	menuType.name = self.currentMenuSubType;
	menuItem.menuType = menuType;

	//set edit attributes
	self.editMenuItem = menuItem;
	self.isAddingMenuItem = TRUE;
	self.indexOfRowForEditing = 0;
	[self.filteredMenuItems insertObject:self.editMenuItem atIndex:0];

	// crash happens when reloading sections
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];

	//scroll to top of tableview
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	if (self.filteredMenuItems.count) {
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}

	[self.navigationController popToViewController:self animated:TRUE];
}

- (void)searchViewController:(SHMenuAdminSearchViewController *)viewController selectedSpot:(SpotModel *)spot {
	[self updateSpot:spot];
	[self.navigationController popToViewController:self animated:TRUE];
}

- (void)updateSpot:(SpotModel *)spot {
	//if the selected spot is the same as the current spot
	//do nothing
	if (![self.spot isEqual:spot]) {
		[self showHUD:@"Loading Menu"];

		self.spot = spot;
		self.title = spot.name;

		//reset edit state
		self.isEditingMenuItem = FALSE;
		self.isAddingMenuItem = FALSE;

		[self.indexPathViewPairMap removeAllObjects];
		[self.cellWithOpenDrawers removeAllObjects];

		[self fetchMenuItems];
	}
}

#pragma mark - Navigation
#pragma mark -

- (void)goToSearchView {
	self.isSpotSearch = FALSE;
	[self performSegueWithIdentifier:kSegueHomeToSearch sender:self];
}

#pragma mark - Fetch User Spots
#pragma mark -

- (void)configureForUser {
	//sets the current user and configure the network manager
	self.user = [[ClientSessionManager sharedClient] currentUser];
}

- (void)fetchUserSpots:(void (^)())successBlock failure:(void (^)())failureBlock {
	[UserModel fetchSpotsForUser:self.user query:nil page:@1 pageSize:@MAX_PRICES_SHOWN success: ^(NSArray *spots) {
	    [self.rightSidebarViewController changeSpots:spots];
	    if (spots.count > 1) {
	        [self.navigationController.sidebarViewController showRightSidebar:TRUE];
		}

	    //set default loaded spot as the first spot in the list
	    self.spot = [spots firstObject];
	    self.title = self.spot.name;

	    if (successBlock) {
	        successBlock();
		}
	} failure: ^(ErrorModel *errorModel) {
	    //  [self showAlert:@"Network error" message:@"Please try again"];
	    CLS_LOG(@"network error fetching user's spots: %@", errorModel.humanValidations);
        
        if (failureBlock) {
            failureBlock();
        }
	}];
}

#pragma mark - Fetch and filter menu items
#pragma mark -

- (void)fetchMenuItems {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
    
	self.menuItems = @[].mutableCopy;

	[[SHMenuAdminNetworkManager sharedInstance] fetchMenuItems:self.spot success: ^(NSArray *menuItems) {
	    if (menuItems.count) {
	        [self.menuItems addObjectsFromArray:menuItems];

	        [self filterMenuItems:self.currentDrinkTypeEnum subTypes:self.currentMenuTypeEnum];
		}
	    else {
	        [self showEmptyView:TRUE];

	        [self.filteredMenuItems removeAllObjects];
	        [self.menuItems removeAllObjects];
		}

	    [self.tableView reloadData];
	    //[self dataDidFinishRefreshing];
	    [self hideHUD];
	} failure: ^(ErrorModel *error) {
	    [self hideHUD];
	    CLS_LOG(@"network error fetching menu items: %@", error.humanValidations);
	    //try to fetch menu items again in a few seconds
	    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
	        [self fetchMenuItems];
		});
	}];
}

- (void)fetchMenuSizes {
	[[SHMenuAdminNetworkManager sharedInstance] fetchDrinkSizes:self.spot success: ^(NSArray *sizes) {
	    for (SizeModel * size in sizes) {
	        for (MenuTypeModel * menuType in size.menuTypes) {
	            //if menu type key found
	            if ([self.typeSizeMap objectForKey:menuType.name]) {
	                NSMutableArray *storedSizes = [self.typeSizeMap objectForKey:menuType.name];

	                if (![storedSizes containsObject:menuType.name]) {
	                    [storedSizes addObject:size];
	                    [self.typeSizeMap setObject:storedSizes forKey:menuType.name];
					}
				}
	            else {
	                //if the key is not already in dictionary, add key and new array with size
	                //if supported filter type
	                if ([self.menuTypes containsObject:menuType.name]) {
	                    NSMutableArray *storedSizes = [NSMutableArray new];
	                    [storedSizes addObject:size];

	                    [self.typeSizeMap setObject:storedSizes forKey:menuType.name];
					}
				}
			}
		}
	} failure: ^(ErrorModel *error) {
	    CLS_LOG(@"network error fetching menu sizes: %@", error.humanValidations);

	    //try to fetch sizes again in a few seconds
	    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
	        [self fetchMenuSizes];
		});
	}];
}

- (void)fetchMenuTypes {
	[[SHMenuAdminNetworkManager sharedInstance] fetchMenuTypes:self.spot success: ^(NSArray *menuTypes) {
	    if (menuTypes) {
	        for (MenuTypeModel * menuType in menuTypes) {
	            [self.menuTypeMap setObject:menuType.ID forKey:menuType.name];
			}
		}
	} failure: ^(ErrorModel *error) {
	    CLS_LOG(@"network error fetching menu types: %@", error.humanValidations);
	    //attempt to fetch types again if the error occurs

	    //try to fetch menu types again in a few seconds
	    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
	        [self fetchMenuTypes];
		});
	}];
}

- (void)filterMenuItems:(DrinkTypes)type subTypes:(MenuSubtypes)subtype {
	NSPredicate *typeFilter;
	NSPredicate *subtypeFilter;

	switch (type) {
		case DrinkTypeBeer: {
			typeFilter = [NSPredicate predicateWithFormat:@"drink.drinkType.name ==[c] %@", kDrinkTypeNameBeer];

			switch (subtype) {
				case MenuSubtypeOnTap: {
					subtypeFilter = [NSPredicate predicateWithFormat:@"menuType.name ==[c] %@", kMenuSubtypeNameOnTap];
				}
				break;

				case MenuSubtypeBottles: {
					subtypeFilter = [NSPredicate predicateWithFormat:@"menuType.name ==[c] %@", kMenuSubtypeNameBottled];
				}
				break;

				default:
					//show all subtypes
					break;
			}
		}
		break;

		case DrinkTypeWine: {
			typeFilter = [NSPredicate predicateWithFormat:@"drink.drinkType.name ==[c] %@", kDrinkTypeNameWine];

			switch (subtype) {
				case MenuSubtypeRedWine: {
					subtypeFilter = [NSPredicate predicateWithFormat:@"menuType.name ==[c] %@", kMenuSubtypeNameRedWine];
				}
				break;

				case MenuSubtypeWhiteWine: {
					subtypeFilter = [NSPredicate predicateWithFormat:@"menuType.name ==[c] %@", kMenuSubtypeNameWhiteWine];
				}
				break;

				case MenuSubtypeSparklingWine: {
					subtypeFilter = [NSPredicate predicateWithFormat:@"menuType.name ==[c] %@", kMenuSubtypeNameSparklingWine];
				}
				break;

				case MenuSubtypeRoseWine: {
					subtypeFilter = [NSPredicate predicateWithFormat:@"menuType.name ==[c] %@", kMenuSubtypeNameRoseWine];
				}
				break;

				case MenuSubtypeFortifiedWine: {
					subtypeFilter = [NSPredicate predicateWithFormat:@"menuType.name ==[c] %@", kMenuSubtypeNameFortifiedWine];
				}
				break;

				default:
					//show all subtypes
					break;
			}
		}
		break;

		case DrinkTypeCocktail: {
			typeFilter = [NSPredicate predicateWithFormat:@"drink.drinkType.name ==[c] %@", kDrinkTypeNameCocktail];

			switch (subtype) {
				case MenuSubtypeHouseCocktail: {
					subtypeFilter = [NSPredicate predicateWithFormat:@"menuType.name ==[c] %@", kMenuSubtypeNameHouseCocktail];
				}
				break;

				case MenuSubtypeCommonCocktail: {
					subtypeFilter = [NSPredicate predicateWithFormat:@"menuType.name ==[c] %@", kMenuSubtypeNameCommonCocktail];
				}
				break;

				default:
					//show all subtypes
					break;
			}
		}
		break;

		default:
			break;
	}

	//sizes have to be gotten from prices
	//once filtered, populate array with sizes for the menu types and store in array???
	//pass array to edit cell for picker...

	if (subtypeFilter != MenuSubtypeNone) {
		NSPredicate *search = [NSCompoundPredicate andPredicateWithSubpredicates:@[typeFilter, subtypeFilter]];
		self.filteredMenuItems = [[self.menuItems filteredArrayUsingPredicate:search] mutableCopy];
	}
	else {
		self.filteredMenuItems = [[self.menuItems filteredArrayUsingPredicate:typeFilter]mutableCopy];
	}

	[self.filteredMenuItems sortUsingComparator: ^NSComparisonResult (MenuItemModel *item1, MenuItemModel *item2) {
	    return [item1.drink.name compare:item2.drink.name];
	}];

	if (!self.filteredMenuItems.count) {
		//hide tableview
		//show empty
		[self showEmptyView:TRUE];
	}
	else {
		[self showEmptyView:FALSE];
		//update view after filtering
		[self.tableView reloadData];
	}
}

- (void)showEmptyView:(BOOL)show {
    DebugLog(@"%@", NSStringFromSelector(_cmd));
	if (show) {
		self.tableView.hidden = TRUE;
		self.emptyView.hidden = FALSE;
		self.lblEmpty.text = [NSString stringWithFormat:@"No %@s added.", [self.currentDrinkType.name lowercaseString]];
        [self openTopContainerViewWithCompletionBlock:nil];
	}
	else {
		self.emptyView.hidden = TRUE;
		self.tableView.hidden = FALSE;
	}
}

- (void)filterMenuItems:(DrinkTypes)drinkType {
	//on button tap filter off of enum?
	[self filterMenuItems:drinkType subTypes:MenuSubtypeNone];
}

- (void)addNewPathViewPair:(SHMenuAdminIndexPathViewPair *)indexPathViewPair {
	if ([self.indexPathViewPairMap objectForKey:self.currentMenuSubType]) {
		//if key already exists...
		NSMutableArray *indexPathViewPairs = [self.indexPathViewPairMap objectForKey:self.currentMenuSubType];
		[indexPathViewPairs addObject:indexPathViewPair];
		[self.indexPathViewPairMap setObject:indexPathViewPairs forKey:self.currentMenuSubType];
	}
	else {
		//if the key is not already in dictionary, add key and new array with size
		//if supported filter type
		if ([self.menuTypes containsObject:self.currentMenuSubType]) {
			NSMutableArray *indexPathViewPairs = [NSMutableArray array];
			[indexPathViewPairs addObject:indexPathViewPair];

			[self.indexPathViewPairMap setObject:indexPathViewPairs forKey:self.currentMenuSubType];
		}
	}
}

- (SHMenuAdminPriceSizeRowContainerView *)getViewForEditCellAtIndexPath:(NSIndexPath *)indexPath {
	SHMenuAdminPriceSizeRowContainerView *container = nil;

	if ([self.indexPathViewPairMap objectForKey:self.currentMenuSubType]) {
		NSMutableArray *indexPathViewPairs = [self.indexPathViewPairMap objectForKey:self.currentMenuSubType];

		if (indexPathViewPairs.count) {
			for (SHMenuAdminIndexPathViewPair *pair in indexPathViewPairs) {
				if ([pair.indexPath isEqual:indexPath]) {
					container = pair.container;
				}
			}
		}
	}

	return container;
}

- (SHMenuAdminPriceSizeRowContainerView *)containerForAdd:(SHMenuAdminEditMenuItemTableViewCell *)editCell {
	//if addContainer doesn't exist
	//create a new container and add new pair to dictionary
	//else
	//grab the container from the dictionary and return it
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:INT32_MIN];

	if (!self.addContainer) {
		self.addContainer = [[SHMenuAdminPriceSizeRowContainerView alloc]init];
		self.addContainer.delegate = editCell;

		SHMenuAdminIndexPathViewPair *ipvp = [[SHMenuAdminIndexPathViewPair alloc]init:indexPath view:self.addContainer];
		[self addNewPathViewPair:ipvp];
	}

	return self.addContainer;
}

#pragma mark - Private - Make Edits
#pragma mark -

- (MenuItemModel *)gatherInfoToCreateMenuItem:(SHMenuAdminEditMenuItemTableViewCell *)cell {
	MenuItemModel *menuItem = self.editMenuItem;

	//get base info from the cell
	menuItem.name = cell.lblDrinkName.text;

	NSMutableArray *prices = [NSMutableArray array];

	SHMenuAdminPriceSizeRowContainerView *container = [cell.priceSizeWrapper.subviews firstObject]; //only one container ever added

	for (SHMenuAdminPriceSizeRowView *row in container.subviews) {
		PriceModel *price = [PriceModel new];

		if ([row.lblSize.text isEqualToString:kSizeNameNoneValue] && [row.txtfldPrice.text isEqualToString:@""]) {
			break;
		}

		if (![row.txtfldPrice.text isEqualToString:@""]) {
			NSNumberFormatter *formatter = [NSNumberFormatter new];
			//multiply by 100 to get cents
			NSInteger formatted = [[formatter numberFromString:row.txtfldPrice.text]floatValue] * 100;
			NSNumber *cents = [NSNumber numberWithInteger:formatted];
			price.cents = cents;
		}

		NSString *sizeFromPicker = row.lblSize.text;

		if (![sizeFromPicker isEqualToString:kSizeNameNoneValue]) {
			for (SizeModel *size in self.sizes) {
				if ([size.name isEqualToString:sizeFromPicker]) {
					price.size = size;
				}
			}
		}

		if (price.cents || price.size) {
			[prices addObject:price];
		}
	}

	menuItem.prices = prices;

	return menuItem;
}

- (void)createMenuItem:(MenuItemModel *)menuItem success:(void (^)())successBlock {
	id ID = [self.menuTypeMap objectForKey:menuItem.menuType.name];
    
    [SpotModel createMenuItem:menuItem spot:self.spot menuType:ID success:^(MenuItemModel *created) {
        NSInteger index = [self.filteredMenuItems indexOfObject:menuItem];
        if (index != NSNotFound) {
            //execute success block
            [self.filteredMenuItems replaceObjectAtIndex:index withObject:created];
            
            //add menu item to overall array
            NSMutableArray *menuItems = [self.menuItems mutableCopy];
            [menuItems addObject:created];
            self.menuItems = menuItems;
            
            if (menuItem.prices.count) {
                //set menu item
                created.prices = menuItem.prices;
                //use newly fetched menu item to post prices to
                [self postPrices:created success:successBlock];
            }
            else {
                if (successBlock) {
                    successBlock();
                }
            }
        }
        else {
            MAAssert(index, @"object should exist");
        }
    } failure:^(ErrorModel *error) {
        [self showAlert:@"Error" message:@"Unable to create menu item. Please try again."];
        CLS_LOG(@"network error adding new menu item [name: %@]. Error: %@", menuItem.name, error.humanValidations);
    }];
}

- (void)saveEdits:(MenuItemModel *)menuItem success:(void (^)())successBlock {
	[[SHMenuAdminNetworkManager sharedInstance] updatePrices:menuItem success: ^(NSArray *prices) {
	    if (prices) {
	        menuItem.prices = prices;
		}

	    if (successBlock) {
	        successBlock();
		}
	} failure: ^(ErrorModel *error) {
	    CLS_LOG(@"network error adding new prices to menu item [name: %@]. Error: %@", menuItem, error.humanValidations);
	}];
}

- (void)postPrices:(MenuItemModel *)menuItem success:(void (^)())successBlock {
	//create params and post new prices
	if (menuItem.prices.count) {
		[[SHMenuAdminNetworkManager sharedInstance] createPrices:menuItem success: ^(NSArray *prices) {
		    if (prices) {
		        menuItem.prices = prices;
			}

		    if (successBlock) {
		        successBlock();
			}
		} failure: ^(ErrorModel *error) {
		    CLS_LOG(@"network error adding new prices to menu item [name: %@]. Error: %@", menuItem, error.humanValidations);
		}];
	}
}

#pragma mark - Private - Toggle (sub)types buttons
#pragma mark -

- (void)setCurrentSubTypesButton:(UIButton *)new {
	//return old menu subtype button to original state
	self.btnCurrentMenuSubType.enabled = TRUE;
	self.btnCurrentMenuSubType.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].LIGHT_ORANGE;

	self.btnCurrentMenuSubType = new;
	self.btnCurrentMenuSubType.enabled = FALSE;
	self.btnCurrentMenuSubType.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].ORANGE;
}

- (void)setSubTypesContainer:(UIView *)new {
	self.currentSubTypesContainer.hidden = TRUE;
	self.currentSubTypesContainer = new;
	self.currentSubTypesContainer.hidden = FALSE;
}

#pragma mark - Keyboard
#pragma mark -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	// Here You can do additional code or task instead of writing with keyboard
	if ([textField isEqual:self.txtfldAddDrink]) {
		[self goToSearchView];
	}
	return NO;
}

- (BOOL)keyboardWillShowWithHeight:(CGFloat)height duration:(CGFloat)duration animationOptions:(UIViewAnimationOptions)animationOptions {
    BOOL result = [super keyboardWillShowWithHeight:height duration:duration animationOptions:animationOptions];
    
    
    return result;
}

- (BOOL)keyboardWillHideWithHeight:(CGFloat)height duration:(CGFloat)duration animationOptions:(UIViewAnimationOptions)animationOptions {
    BOOL result = [super keyboardWillHideWithHeight:height duration:duration animationOptions:animationOptions];
    
    if ([self sizePickerIsShown]) {
        NSIndexPath *indexPath = [[self.tableView indexPathsForVisibleRows] firstObject];
        [self toggleSizePicker:indexPath];
    }

    return result;
}

#pragma mark - Base Overrides
#pragma mark -

- (UIScrollView *)mainScrollView {
    return self.tableView;
}

#pragma mark - Private Helpers
#pragma mark -

- (void)selectPhotoForCell:(SHMenuAdminSwipeableDrinkTableViewCell *)cell {
	if (!cell) {
		MAAssert(cell, @"cell cannnot be nil");
	}

	self.indexPathForPhotoTaken = [self.tableView indexPathForCell:cell];

	UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Select Photo"];

	[actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler: ^{
	}];

	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[actionSheet bk_addButtonWithTitle:@"Take New Photo" handler: ^{
		    [self takeNewPhoto];
		}];
	}

	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		[actionSheet bk_addButtonWithTitle:@"Select Existing Photo" handler: ^{
		    [self selectExistingPhoto];
		}];
	}

	[actionSheet showInView:self.view];
}

- (void)takeNewPhoto {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];

		imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
		imagePicker.allowsEditing = true;
		imagePicker.delegate = self;

		[self presentViewController:imagePicker animated:true completion:nil];
	}
	else {
		[self showAlert:@"No camera detected" message:@"Sorry, we must have permissions to use your camera to use this feature"];
	}
}

- (void)selectExistingPhoto {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];

		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
		imagePicker.allowsEditing = true;
		imagePicker.delegate = self;

		[self presentViewController:imagePicker animated:true completion:nil];
	}
	else {
		[self showAlert:@"No camera detected" message:@"Sorry, we must have permissions to use your camera to use this feature"];
	}
}

- (void)configurePriceSizeRow:(SHMenuAdminPriceSizeRowView *)container withPriceSize:(PriceModel *)priceInStupidCents {
	if (container) {
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[numberFormatter setLocale:[NSLocale currentLocale]];
		[numberFormatter setCurrencySymbol:@""];

		NSString *price = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:(priceInStupidCents.cents.floatValue / 100.0f)]];

		if (priceInStupidCents.cents != nil && priceInStupidCents.size != nil) {
			container.txtfldPrice.text = price;
			container.lblSize.text = priceInStupidCents.size.name;
		}
		else if (priceInStupidCents.cents != nil) {
			container.txtfldPrice.text = price;
			container.lblSize.text = kSizeNameNoneValue;
		}
		else if (priceInStupidCents.size != nil) {
			container.txtfldPrice.text = @"$0.00";
			container.lblSize.text = priceInStupidCents.size.name;
		}
	}
}

- (UIImage *)placeHolderImageForType:(MenuItemModel *)menuItem {
	UIImage *placeholder = nil;

	if ([menuItem.drink.drinkType isBeer]) {
		placeholder = [UIImage imageNamed:@"placeholderBeer"];
	}
	else if ([menuItem.drink.drinkType isWine]) {
		placeholder = [UIImage imageNamed:@"placeholderWine"];
	}
	else if ([menuItem.drink.drinkType isCocktail]) {
		placeholder = [UIImage imageNamed:@"placeholderCocktail"];
	}

	return placeholder;
}

#pragma mark - Styling
#pragma mark -

- (void)styleHome {
	[self styleButtons];

	self.lblEmpty.font = [UIFont fontWithName:@"Lato-Bold" size:20.0f];
	self.lblEmpty.textColor = [SHMenuAdminStyleSupport sharedInstance].DARK_ORANGE;
	self.txtfldContainer.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].LIGHT_ORANGE;
	self.txtfldAddDrink.backgroundColor = [SHMenuAdminStyleSupport sharedInstance].DARK_ORANGE;
	self.txtfldAddDrink.font = [UIFont fontWithName:@"Lato-Italic" size:16.0f];
	self.txtfldAddDrink.textColor = [UIColor whiteColor];
}

- (void)styleButtons {
	[self.btnBeer styleAsFilterButtonWithTopImage:[UIImage imageNamed:@"beerIcon"] text:kDrinkTypeNameBeer];
	[self.btnBeer addBottomBorder];
	[self.btnBeer addTopBorder];

	[self.btnWine styleAsFilterButtonWithTopImage:[UIImage imageNamed:@"wineIcon"] text:kDrinkTypeNameWine];
	self.btnWine.layer.borderColor = [UIColor whiteColor].CGColor;
	self.btnWine.layer.borderWidth = 0.5f;

	[self.btnCocktails styleAsFilterButtonWithTopImage:[UIImage imageNamed:@"cocktailIcon"] text:kDrinkTypeNameCocktail];
	[self.btnCocktails addBottomBorder];
	[self.btnCocktails addTopBorder];
	[self.btnCocktails addLeftBorder];

	[self.btnOnTap styleAsFilterButtonWithSideImage:[UIImage imageNamed:@"onTap"] text:@"On Tap"];
	[self.btnOnTap addBottomBorder];

	[self.btnBottles styleAsFilterButtonWithSideImage:[UIImage imageNamed:@"bottlesIcon"] text:@"Bottles & Cans"];
	[self.btnBottles addBottomBorder];
	[self.btnBottles addLeftBorder];

	[self.btnRedWine styleAsFilterButtonWithTopImage:[UIImage imageNamed:@"redIcon"] text:kMenuSubtypeNameRedWine];
	[self.btnRedWine addBottomBorder];

	[self.btnWhiteWine styleAsFilterButtonWithTopImage:[UIImage imageNamed:@"wineIcon"] text:kMenuSubtypeNameWhiteWine];
	[self.btnWhiteWine addBottomBorder];
	[self.btnWhiteWine addLeftBorder];

	[self.btnFortifiedWine styleAsFilterButtonWithTopImage:[UIImage imageNamed:@"fortifiedIcon"] text:kMenuSubtypeNameFortifiedWine];
	[self.btnFortifiedWine addBottomBorder];
	[self.btnFortifiedWine addLeftBorder];

	[self.btnSparklingWine styleAsFilterButtonWithTopImage:[UIImage imageNamed:@"sparklingIcon"] text:kMenuSubtypeNameSparklingWine];
	[self.btnSparklingWine addBottomBorder];
	[self.btnSparklingWine addLeftBorder];

	[self.btnRoseWine styleAsFilterButtonWithTopImage:[UIImage imageNamed:@"roseIcon"] text:kMenuSubtypeNameRoseWine];
	[self.btnRoseWine addBottomBorder];
	[self.btnRoseWine addLeftBorder];

	[self.btnHouseCocktail styleAsFilterButtonWithSideImage:[UIImage imageNamed:@"houseCocktailsIcon"] text:kMenuSubtypeNameHouseCocktail];
	[self.btnHouseCocktail addBottomBorder];

	[self.btnCommonCocktail styleAsFilterButtonWithSideImage:[UIImage imageNamed:@"cocktailIcon"] text:kMenuSubtypeNameCommonCocktail];
	[self.btnCommonCocktail addBottomBorder];
	[self.btnCommonCocktail addLeftBorder];
}

@end
