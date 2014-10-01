//
//  RestaurantDetailsViewController.m
//  WaitlessPO
//
//  Created by SSASOFT on 12/3/13.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "RestaurantDetailsViewController.h"
#import "UIImageView+WebCache.h"
#import "MFSideMenu.h"
#import "RestaurantModel.h"
#import "UserModel.h"
#import "SVProgressHUD.h"
#import "FoodCategoriesViewController.h"
#import "WebViewController.h"
#import "PODetailsViewController.h"
#import "PageSwipeController.h"
#import "OffersCell.h"
#import "PaymentsViewController.h"
#import <MapKit/MapKit.h>

#define DATE_STRING         @"Select Date"
#define TIME_STRING         @"Select Time"
#define PICK_UP_TIME_STRING @"Select Pick-up Time"
#define PARTY_SIZE_STRING   @"Select Party Size"

@interface RestaurantDetailsViewController ()

-(void)loadRestaurantDetails;
-(void)loadOffers;
-(void)setRatings:(float)ratings;
-(void)requestForCreatingOrder;
-(void)requestForUpdateParkedOrderWithData:(NSDictionary*)data;
-(void)requestForGettingParkedOrderWithData:(NSDictionary*)data;
-(NSString*)getFormattedDateString;
-(NSString*)getFormattedDateStringFromString:(NSString*)dateString;
-(NSDate*)getParkedOrderDate;
-(NSString*)getPartySize;

-(void)hideParkedOrderCreationViewsOnFailure;

@end

@implementation RestaurantDetailsViewController

@synthesize pageController;
@synthesize isYelpRestaurant;
@synthesize selectedIndex;

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    offersTable.tableFooterView = footer_view;
    payNowTimeList = [[NSMutableArray alloc] initWithObjects:@"20 Minutes", @"40 Minutes", @"1 Hour", nil];
    [self loadRestaurantDetails];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
//    self.menuContainerViewController.panMode = MFSideMenuPanModeDefault;
    [self loadOffers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Private Methods

-(void)loadRestaurantDetails {
    
    order_menu_view.hidden = isYelpRestaurant;
    waitless_btn_view.hidden = !isYelpRestaurant;
    website_view.hidden = !isYelpRestaurant;
    if (isYelpRestaurant) {
        if (restaurantData) {
            title_lbl.text = [restaurantData objectForKey:@"name"];
            restaurantName_lbl.text = [restaurantData objectForKey:@"name"];
            address_lbl.text = [[[restaurantData objectForKey:@"location"] objectForKey:@"display_address"] firstObject];
            city_state_lbl.text = [[[restaurantData objectForKey:@"location"] objectForKey:@"display_address"] lastObject];
            [phone_btn setTitle:[restaurantData objectForKey:@"display_phone"] forState:UIControlStateNormal];
            float distance = [[restaurantData objectForKey:@"distance"] floatValue]/MILE_IN_METERS;
            distance_lbl.text = [NSString stringWithFormat:@"%.2f mi", distance];
            NSMutableString *categories = [NSMutableString string];
            NSArray *list = [restaurantData objectForKey:@"categories"];
            if (list && [list isKindOfClass:[NSArray class]]) {
                for (int i=0; i<[list count]; i++) {
                    [categories appendString:[[list objectAtIndex:i] firstObject]];
                    if ((i+1) < [list count]) {
                        [categories appendString:@", "];
                    }
                }
            }
            categories_lbl.text = categories;
            description_TV.text = [restaurantData objectForKey:@"snippet_text"];
            reviews_lbl.text = [NSString stringWithFormat:@"%@ Reviews", [restaurantData objectForKey:@"review_count"]];
            [self setRatings:[[restaurantData objectForKey:@"rating"] floatValue]];
            [restaurant_image setImageWithURL:[NSURL URLWithString:[restaurantData objectForKey:@"image_url"]] placeholderImage:[UIImage imageNamed:@"restaurant_place_holder.png"]];
        }
    }
    else {
        if (restaurantModel) {
            title_lbl.text = restaurantModel.restaurantName;
            restaurantName_lbl.text = restaurantModel.restaurantName;
            address_lbl.text = restaurantModel.addressLine1;
            city_state_lbl.text = [NSString stringWithFormat:@"%@, %@. %@", restaurantModel.city, restaurantModel.stateCode, restaurantModel.zipCode];
            if (restaurantModel.primaryPhone.length >= 10 && [restaurantModel.primaryPhone rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound) {
                NSMutableString *phoneNumber = [NSMutableString stringWithString:restaurantModel.primaryPhone];
                [phoneNumber insertString:@"(" atIndex:0];
                [phoneNumber insertString:@") " atIndex:4];
                [phoneNumber insertString:@"-" atIndex:9];
                [phone_btn setTitle:phoneNumber forState:UIControlStateNormal];
            }
            distance_lbl.text = [NSString stringWithFormat:@"%.2f mi", restaurantModel.distance];
            NSMutableString *string = [NSMutableString string];
            for (int i=0; i<[restaurantModel.restaurantCategoryList count]; i++) {
                if (i > 0) {
                    [string appendString:@", "];
                }
                id obj = [restaurantModel.restaurantCategoryList objectAtIndex:i];
                [string appendString:[obj objectForKey:@"Name"]];
            }
            categories_lbl.text = string;
            description_TV.text = restaurantModel.description;
            reviews_lbl.text = @"0 Reviews";
            [self setRatings:0.0];
            hours_lbl.text = restaurantModel.businessHours;
            NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ASSET_URL, restaurantModel.assetUrl]];
            [restaurant_image setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"restaurant_place_holder.png"]];
            CGSize size = [hours_lbl.text sizeWithFont:hours_lbl.font constrainedToSize:CGSizeMake(hours_lbl.frame.size.width, 200)];
            CGRect frame = hours_lbl.frame;
            if (size.height > frame.size.height) {
                frame.origin.y += 5.0;
                frame.size.height = size.height;
                hours_lbl.frame = frame;
            }
        }
    }
}

-(void)loadOffers {
    
    if (!offersList) {
        offersList = [NSMutableArray array];
    }
    else {
        [offersList removeAllObjects];
    }
    if (!isYelpRestaurant && restaurantModel) {
        [offersList addObjectsFromArray:[[AppInfo sharedInfo] getPromotionListWithRestaurantID:restaurantModel.restaurantID]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        [offersList sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
            NSDictionary *promotion1 = obj1;
            NSDictionary *promotion2 = obj2;
            if ([[promotion1 objectForKey:@"EndDate"] isEqualToString:[promotion2 objectForKey:@"EndDate"]]) {
                NSDate *date1 = [formatter dateFromString:[promotion1 objectForKey:@"StartDate"]];
                NSDate *date2 = [formatter dateFromString:[promotion2 objectForKey:@"StartDate"]];
                NSTimeInterval timeInterval1 = [date1 timeIntervalSince1970];
                NSTimeInterval timeInterval2 = [date2 timeIntervalSince1970];
                if (timeInterval1 > timeInterval2) {
                    return NSOrderedAscending;
                }
                else if (timeInterval1 < timeInterval2) {
                    return NSOrderedDescending;
                }
                else {
                    return NSOrderedSame;
                }
            }
            else {
                return NSOrderedSame;
            }
        }];
    }
    CGRect frame = header_view.frame;
    if ([offersList count] == 0) {
        frame.size.height = section_header_view.frame.origin.y;
        section_header_view.hidden = YES;
    }
    else {
        frame.size.height = section_header_view.frame.origin.y+section_header_view.frame.size.height;
        section_header_view.hidden = NO;
    }
    header_view.frame = frame;
    offersTable.tableHeaderView = header_view;
    [offersTable reloadData];
}

-(void)setRatings:(float)ratings {
    
    [star1_image setHighlighted:NO];
    [star2_image setHighlighted:NO];
    [star3_image setHighlighted:NO];
    [star4_image setHighlighted:NO];
    [star5_image setHighlighted:NO];
    
    int rate = (int)floorf(ratings);
    for (int i=1; i<=rate; i++) {
        UIImageView *star_image = (UIImageView*)[self.view viewWithTag:i];
        [star_image setHighlighted:YES];
    }
    int half_rate = (int)ceilf(ratings);
    if (half_rate > rate) {
        UIImageView *star_image = (UIImageView*)[self.view viewWithTag:half_rate];
        [star_image setHighlightedImage:[UIImage imageNamed:@"rate_active_star_half.png"]];
        [star_image setHighlighted:YES];
    }
}

-(NSString*)getFormattedDateStringFromString:(NSString*)dateString {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *date = [formatter dateFromString:dateString];
    [formatter setDateFormat:@"EEE, MMM dd"];
    return [formatter stringFromDate:date];
}

-(NSString*)getFormattedDateString {
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (restaurantModel.isPayNow) {
        NSInteger row = [payNowTimePicker selectedRowInComponent:0]+1;
        NSTimeInterval interval = (row*15)*60;
        date = [date dateByAddingTimeInterval:interval];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    }
    else {
        [formatter setDateFormat:@"EEE, dd MMM yyyy h:mm a"];
        date = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@", order_dateTF.text, order_timeTF.text]];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    }
    return [formatter stringFromDate:date];
}

-(NSDate*)getParkedOrderDate {
    
    NSDate *date = [NSDate date];
    if (restaurantModel.isPayNow) {
        NSInteger row = [payNowTimePicker selectedRowInComponent:0]+1;
        NSTimeInterval interval = (row*15)*60;
        date = [date dateByAddingTimeInterval:interval];
    }
    else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEE, dd MMM yyyy h:mm a"];
        date = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@", order_dateTF.text, order_timeTF.text]];
    }
    
    return date;
}

-(NSString*)getPartySize {
    
    if (restaurantModel.isPayNow) {
        return ([payNow_party_sizeTF.text isEqualToString:@"Party Size"])?@"1":payNow_party_sizeTF.text;
    }
    return ([order_party_sizeTF.text isEqualToString:@"Party Size"])?@"1":order_party_sizeTF.text;
}

-(void)requestForCreatingOrder {
    
    [SVProgressHUD showWithStatus:@"Creating parked order..." maskType:SVProgressHUDMaskTypeGradient];
    isCreateOrderRequest = YES;
    isGetParkedOrderRequest = NO;
    UserModel *user = [AppInfo sharedInfo].user;
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:user.loginID, user.tokenID, restaurantModel.restaurantID, [self getFormattedDateString], [NSNumber numberWithInteger:[[self getPartySize] integerValue]], nil] forKeys:[NSArray arrayWithObjects:@"loginId", @"tokenId", @"restaurantId", @"parkedOrderDate", @"partySize", nil]];
    [HTTPRequest requestGetWithMethod:@"RestaurantService/ParkedOrder/Request" Params:params andDelegate:self];
}

-(void)requestForUpdateParkedOrderWithData:(NSDictionary *)data {
    
    [SVProgressHUD showWithStatus:@"Creating parked order..." maskType:SVProgressHUDMaskTypeGradient];
    isCreateOrderRequest = NO;
    isGetParkedOrderRequest = NO;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[data objectForKey:@"TokenId"] forKey:@"TokenId"];
    [params setObject:[data objectForKey:@"LoginId"] forKey:@"LoginId"];
    [params setObject:[data objectForKey:@"Id"] forKey:@"ParkedOrderId"];
    [params setObject:[NSNumber numberWithDouble:0] forKey:@"Gratuity"];
    [params setObject:[NSNumber numberWithInt:0] forKey:@"IsCustomGratuity"];
    [params setObject:[NSNumber numberWithDouble:0] forKey:@"TotalCost"];
    [params setObject:[NSNumber numberWithInt:2] forKey:@"Status"];
    [params setObject:[NSNumber numberWithInt:[[self getPartySize] intValue]] forKey:@"PartySize"];
    [params setObject:[self getFormattedDateString] forKey:@"FulfillmentDate"];
    [params setObject:[NSMutableArray array] forKey:@"ParkedOrderItems"];
    [HTTPRequest requestPostWithMethod:@"RestaurantService/ParkedOrder/Update" Params:params andDelegate:self];
}

-(void)requestForGettingParkedOrderWithData:(NSDictionary*)data {
    
    [SVProgressHUD showWithStatus:@"Creating parked order..." maskType:SVProgressHUDMaskTypeGradient];
    isGetParkedOrderRequest = YES;
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[data objectForKey:@"TokenId"], [data objectForKey:@"ParkedOrderId"], nil] forKeys:[NSArray arrayWithObjects:@"tokenid", @"id", nil]];
    [HTTPRequest requestGetWithMethod:@"RestaurantService/ParkedOrder" Params:params andDelegate:self];
}

-(void)hideParkedOrderCreationViewsOnFailure {
    
    [self.view setUserInteractionEnabled:NO];
    CGRect frame1 = parked_order_view.frame;
    frame1.origin = CGPointMake(0, self.view.frame.size.height);
    CGRect frame2 = payNow_order_view.frame;
    frame2.origin = CGPointMake(0, self.view.frame.size.height);
    CGRect frame3 = payNow_alert_view.frame;
    frame3.origin = CGPointMake(0, self.view.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        parked_order_view.alpha = 0.0;
        payNow_order_view.alpha = 0.0;
        payNow_alert_view.alpha = 0.0;
    }completion:^(BOOL finished) {
        if (finished) {
            parked_order_view.frame = frame1;
            payNow_order_view.frame = frame2;
            payNow_alert_view.frame = frame3;
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

#pragma mark
#pragma mark Logical Methods

-(void)setRestaurantData:(NSDictionary *)data {
    
    restaurantData = [NSMutableDictionary dictionaryWithDictionary:data];
}

-(void)setRestaurantModel:(RestaurantModel*)restaurantObj {
    
    restaurantModel = restaurantObj;
}

-(NSString*)getRestaurantTitle {
    
    if (isYelpRestaurant) {
        return [NSString stringWithString:[restaurantData objectForKey:@"name"]];
    }
    else {
        return [NSString stringWithString:restaurantModel.restaurantName];
    }
}

-(void)reloadPromotions {
    
    [self loadOffers];
}

#pragma mark
#pragma mark UITableViewDelegate/UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([offersList count] > 1) {
        return 1;
    }
    return [offersList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"OffersCellIdentifier";
    
    OffersCell *cell = (OffersCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"OffersCell" owner:self options:nil] objectAtIndex:0];
    }
    
    NSDictionary *promotion = [offersList objectAtIndex:indexPath.row];
    cell.name_lbl.text = [promotion objectForKey:@"Name"];
    cell.description_TV.text = [promotion objectForKey:@"Description"];
    cell.date_lbl.text = [NSString stringWithFormat:@"Expires: %@", [self getFormattedDateStringFromString:[promotion objectForKey:@"EndDate"]]];
    if ([promotion objectForKey:@"Code"] && (NSNull*)[promotion objectForKey:@"Code"] != [NSNull null] && [[promotion objectForKey:@"Code"] isKindOfClass:[NSString class]] && [[promotion objectForKey:@"Code"] length] > 0) {
        cell.code_lbl.text = [NSString stringWithFormat:@"Promo Code: %@", [promotion objectForKey:@"Code"]];
        cell.code_lbl.hidden = NO;
    }
    else {
        cell.code_lbl.hidden = YES;
    }
    cell.value_lbl.text = [NSString stringWithFormat:@"$%i", [[promotion objectForKey:@"Value"] intValue]];

    return cell;
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)backAction:(id)sender {
    
    [pageController.navigationController popViewControllerAnimated:YES];
}

-(IBAction)phoneButtonClick:(id)sender {
    
    if (isYelpRestaurant) {
        NSString *phoneNumber = [@"tel://" stringByAppendingString:[restaurantData objectForKey:@"phone"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
    else {
        NSString *phoneNumber = [@"tel://" stringByAppendingString:restaurantModel.primaryPhone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}

-(IBAction)waitlessButtonClick:(id)sender {
    
    WebViewController *webVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"WebViewController"];
    webVC.url_str = SUGGEST_MERCHANT_URL;
    [pageController.navigationController pushViewController:webVC animated:YES];
}

-(IBAction)orderButtonClick:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    if (restaurantModel.isPayNow) {
        if ([[AppInfo sharedInfo] isPaymentMethodAvailable]) {
            NSDate *date = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEE, MMM dd"];
            payNow_date_lbl.text = [formatter stringFromDate:date];
            [payNowTimePicker selectRow:0 inComponent:0 animated:NO];
            [payNowPartySizePicker selectRow:0 inComponent:0 animated:NO];
            payNow_timeTF.text = [payNowTimeList objectAtIndex:0];
            payNow_party_sizeTF.text = @"1";
            
            payNow_order_view.alpha = 0.0;
            payNow_order_view.center = self.view.center;
            [UIView animateWithDuration:0.3 animations:^{
                payNow_order_view.alpha = 1.0;
            }completion:^(BOOL finished) {
                if (finished) {
                    [self.view setUserInteractionEnabled:YES];
                }
            }];
        }
        else {
            payNow_alert_view.alpha = 0.0;
            payNow_alert_view.center = self.view.center;
            [UIView animateWithDuration:0.3 animations:^{
                payNow_alert_view.alpha = 1.0;
            }completion:^(BOOL finished) {
                if (finished) {
                    [self.view setUserInteractionEnabled:YES];
                }
            }];
        }
    }
    else {
        NSDate *date = [NSDate date];
        [orderDatePicker setDate:date animated:NO];
        [orderTimePicker setDate:date animated:NO];
        [partySizePicker selectRow:0 inComponent:0 animated:NO];
        order_dateTF.text = @"Date";
        order_timeTF.text = @"Time";
        order_party_sizeTF.text = @"Party Size";
        
        parked_order_view.alpha = 0.0;
        parked_order_view.center = self.view.center;
        [UIView animateWithDuration:0.3 animations:^{
            parked_order_view.alpha = 1.0;
        }completion:^(BOOL finished) {
            if (finished) {
                [self.view setUserInteractionEnabled:YES];
            }
        }];
    }
}

-(IBAction)menuButtonClick:(id)sender {
    
    FoodCategoriesViewController *foodCategoriesVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"FoodCategoriesViewController"];
    [foodCategoriesVC setFoodCategories:restaurantModel.foodCategoryList];
    [pageController.navigationController pushViewController:foodCategoriesVC animated:YES];
}

-(IBAction)websiteButtonClick:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[restaurantData objectForKey:@"url"]]];
}

-(IBAction)dateChangedAction:(id)sender {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE, dd MMM yyyy"];
    order_dateTF.text = [formatter stringFromDate:orderDatePicker.date];
}

-(IBAction)timeChangedAction:(id)sender {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    order_timeTF.text = [formatter stringFromDate:orderTimePicker.date];
}

-(IBAction)doneOrderFieldsAction:(id)sender {

    if ([toolBar_btn.title isEqualToString:PARTY_SIZE_STRING]) {
        NSInteger row = [partySizePicker selectedRowInComponent:0];
        order_party_sizeTF.text = [NSString stringWithFormat:@"%i", (int)row+1];
        [order_party_sizeTF resignFirstResponder];
        row = [payNowPartySizePicker selectedRowInComponent:0];
        payNow_party_sizeTF.text = [NSString stringWithFormat:@"%i", (int)row+1];
        [payNow_party_sizeTF resignFirstResponder];
    }
    else {
        if ([toolBar_btn.title isEqualToString:DATE_STRING]) {
            [self dateChangedAction:Nil];
            [order_dateTF resignFirstResponder];
        }
        else if ([toolBar_btn.title isEqualToString:TIME_STRING]) {
            [self timeChangedAction:Nil];
            [order_timeTF resignFirstResponder];
        }
        else if ([toolBar_btn.title isEqualToString:PICK_UP_TIME_STRING]) {
            NSInteger row = [payNowTimePicker selectedRowInComponent:0];
            payNow_timeTF.text = [payNowTimeList objectAtIndex:row];
            [payNow_timeTF resignFirstResponder];
        }
    }
}

-(IBAction)createOrderAction:(id)sender {
    
    NSString *errorMessage = Nil;
    if ([order_dateTF.text isEqualToString:@"Date"]) {
        errorMessage = @"Please enter your parked order date.";
    }
    else if ([order_timeTF.text isEqualToString:@"Time"]) {
        errorMessage = @"Please enter your parked order time.";
    }
    else {
        [self requestForCreatingOrder];
    }
    if (errorMessage) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alertView show];
    }
}

-(IBAction)cancelOrderAction:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    CGRect frame = parked_order_view.frame;
    frame.origin = CGPointMake(0, self.view.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        parked_order_view.alpha = 0.0;
    }completion:^(BOOL finished) {
        if (finished) {
            parked_order_view.frame = frame;
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(IBAction)openRestaurantMap:(id)sender {
    
    @synchronized(self) {
        NSMutableString *address_string = [NSMutableString string];
        if (isYelpRestaurant) {
            [address_string appendFormat:@"%@ %@ %@", [restaurantData objectForKey:@"name"], [[[restaurantData objectForKey:@"location"] objectForKey:@"display_address"] firstObject], [[[restaurantData objectForKey:@"location"] objectForKey:@"display_address"] lastObject]];
        }
        else {
            [address_string appendFormat:@"%@ %@ %@ %@ %@", restaurantModel.restaurantName, restaurantModel.addressLine1, restaurantModel.city, restaurantModel.stateCode, restaurantModel.zipCode];
        }
        // Check for iOS 6
        Class mapItemClass = [MKMapItem class];
        if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
        {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:address_string
                         completionHandler:^(NSArray *placemarks, NSError *error) {
                             
                             // Convert the CLPlacemark to an MKPlacemark
                             // Note: There's no error checking for a failed geocode
                             CLPlacemark *geocodedPlacemark = [placemarks objectAtIndex:0];
                             MKPlacemark *placemark = [[MKPlacemark alloc]
                                                       initWithCoordinate:geocodedPlacemark.location.coordinate
                                                       addressDictionary:geocodedPlacemark.addressDictionary];
                             
                             // Create a map item for the geocoded address to pass to Maps app
                             MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                             [mapItem setName:geocodedPlacemark.name];
                             
                             // Set the directions mode to "Driving"
                             // Can use MKLaunchOptionsDirectionsModeWalking instead
                             NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
                             
//                             [mapItem openInMapsWithLaunchOptions:Nil];
                             // Get the "Current User Location" MKMapItem
                             MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
                             
                             // Pass the current location and destination map items to the Maps app
                             // Set the direction mode in the launchOptions dictionary
                             [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
                             
                             
                         }];
        }
        else
        {
            NSString *mapsURL = [NSString stringWithFormat:@"https://maps.google.com/maps?q=%@", [address_string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapsURL]];
        }
    }
}

-(IBAction)cancelPayNowOrderAction:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    CGRect frame = payNow_order_view.frame;
    frame.origin = CGPointMake(0, self.view.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        payNow_order_view.alpha = 0.0;
    }completion:^(BOOL finished) {
        if (finished) {
            payNow_order_view.frame = frame;
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(IBAction)cancelPayNowAlertAction:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    CGRect frame = payNow_alert_view.frame;
    frame.origin = CGPointMake(0, self.view.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        payNow_alert_view.alpha = 0.0;
    }completion:^(BOOL finished) {
        if (finished) {
            payNow_alert_view.frame = frame;
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(IBAction)payNowPaymentAction:(id)sender {
    
    PaymentsViewController *paymentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PaymentsViewController"];
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    navigationController.viewControllers = [NSArray arrayWithObject:paymentVC];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

-(IBAction)payNowOrderAction:(id)sender {
    
    [self requestForCreatingOrder];
}

#pragma mark
#pragma mark UIPickerViewDelegate/UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {

    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (pickerView == payNowTimePicker) {
        return [payNowTimeList count];
    }
    return 20;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (pickerView == payNowTimePicker) {
        return [payNowTimeList objectAtIndex:row];
    }
    return [NSString stringWithFormat:@"%i", (int)row+1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (pickerView == payNowTimePicker) {
         payNow_timeTF.text = [payNowTimeList objectAtIndex:row];
    }
    else if (pickerView == payNowPartySizePicker) {
        payNow_party_sizeTF.text = [NSString stringWithFormat:@"%i", (int)row+1];
    }
    else if (pickerView == partySizePicker) {
        order_party_sizeTF.text = [NSString stringWithFormat:@"%i", (int)row+1];
    }
}

#pragma mark
#pragma mark UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    if (textField == order_dateTF) {
        [toolBar_btn setTitle:DATE_STRING];
        textField.inputView = orderDatePicker;
        [self dateChangedAction:nil];
    }
    else if (textField == order_timeTF) {
        [toolBar_btn setTitle:TIME_STRING];
        textField.inputView = orderTimePicker;
        [self timeChangedAction:nil];
    }
    else if (textField == order_party_sizeTF) {
        [toolBar_btn setTitle:PARTY_SIZE_STRING];
        textField.inputView = partySizePicker;
    }
    else if (textField == payNow_timeTF) {
        [toolBar_btn setTitle:PICK_UP_TIME_STRING];
        textField.inputView = payNowTimePicker;
    }
    else if (textField == payNow_party_sizeTF) {
        [toolBar_btn setTitle:PARTY_SIZE_STRING];
        textField.inputView = payNowPartySizePicker;
    }
    textField.inputAccessoryView = toolBar;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == order_party_sizeTF) {
        int row = (int)[partySizePicker selectedRowInComponent:0];
        order_party_sizeTF.text = [NSString stringWithFormat:@"%i", row+1];
    }
    else if (textField == payNow_party_sizeTF) {
        int row = (int)[payNowPartySizePicker selectedRowInComponent:0];
        payNow_party_sizeTF.text = [NSString stringWithFormat:@"%i", row+1];
    }
    else {
        if (textField == order_dateTF) {
            [self dateChangedAction:Nil];
        }
        else if (textField == order_timeTF) {
            [self timeChangedAction:Nil];
        }
        else if (textField == payNow_timeTF) {
            int row = (int)[payNowTimePicker selectedRowInComponent:0];
            payNow_timeTF.text = [payNowTimeList objectAtIndex:row];
        }
    }
    return YES;
}

#pragma mark
#pragma mark HTTPRequestDelegate Methods

-(void)didFinishRequest:(HTTPRequest*)httpRequest withData:(id)data {
    
    [SVProgressHUD dismiss];
    if (data && [data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"IsSuccessful"]) {

        if ([[data objectForKey:@"IsSuccessful"] boolValue]) {
            if (isGetParkedOrderRequest) {
                [SVProgressHUD showSuccessWithStatus:@"Order created successfully."];
                NSDictionary *parkedOrder = [[data objectForKey:@"List"] firstObject];
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                [dictionary addEntriesFromDictionary:parkedOrder];
                [dictionary setObject:[self getParkedOrderDate] forKey:@"parkedOrderDate"];
                [dictionary setObject:restaurantModel forKey:@"restaurantModel"];
                [[AppInfo sharedInfo].user addParkedOrder:parkedOrder];
                PODetailsViewController *po_DetailsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PODetailsViewController"];
                po_DetailsVC.orderDetails = dictionary;
//                po_DetailsVC.gratuity_rate = [AppInfo sharedInfo].user.gratuity_rate;
                [pageController.navigationController pushViewController:po_DetailsVC animated:YES];
                if (restaurantModel.isPayNow) {
                    [self cancelPayNowOrderAction:nil];
                }
                else {
                    [self cancelOrderAction:Nil];
                }
            }
            else {
                if (isCreateOrderRequest) {
                    [self requestForUpdateParkedOrderWithData:data];
                }
                else {
                    [self requestForGettingParkedOrderWithData:data];
                }
            }
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[data objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [self hideParkedOrderCreationViewsOnFailure];
        }
    }
}

-(void)didFailRequest:(HTTPRequest*)httpRequest withError:(NSString*)errorMessage {
    
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
