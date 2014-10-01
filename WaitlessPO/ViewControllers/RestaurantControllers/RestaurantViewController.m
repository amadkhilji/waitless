//
//  RestaurantViewController.m
//  WaitlessPO
//
//  Created by Amad Khilji on 01/11/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "RestaurantViewController.h"
#import "RestaurantModel.h"
#import "UserModel.h"
#import "SVProgressHUD.h"
#import "RestaurantCell.h"
#import "UIImageView+WebCache.h"
#import "MFSideMenu.h"
#import "PageSwipeController.h"
//#import "RestaurantDetailsViewController.h"
#import <MapKit/MapKit.h>

@interface RestaurantViewController ()

-(void)showPaymentAlert;
-(void)requestForRestaurants;
-(void)parseRestaurantsList:(id)list;
-(void)parseYelpRestaurantsList:(id)list;

@end

@implementation RestaurantViewController

@synthesize restaurantTable;
@synthesize requestCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        requestCount = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    requestCount = 0;

    locationManager = [[CLLocationManager alloc] init];
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.menuContainerViewController.panMode = MFSideMenuPanModeDefault;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Private Methods

-(void)showPaymentAlert {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_PAYMENT_ALERT_NOTIFICATION object:Nil];
}

-(void)requestForRestaurants {
    
    if ([[AppInfo sharedInfo].restaurantsList count] == 0) {
        [SVProgressHUD showWithStatus:@"Loading Restaurants..." maskType:SVProgressHUDMaskTypeGradient];
    }
    requestCount = 0;
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:coordinate.latitude], @"latitude", [NSNumber numberWithFloat:coordinate.longitude], @"longitude", [AppInfo sharedInfo].user.tokenID, @"tokenid", nil];
    [HTTPRequest requestGetWithMethod:@"RestaurantService/Restaurants" Params:data andDelegate:self];
    [HTTPRequest getYelpRestaurantsWithCoordinates:coordinate andDelegate:self];
}

-(void)parseRestaurantsList:(id)list {
    
    if (list && [list isKindOfClass:[NSArray class]]) {
        
        NSMutableArray *array = [NSMutableArray array];
        for (int i=0; i<[list count]; i++) {
            RestaurantModel *restaurant = [[RestaurantModel alloc] init];
            [restaurant loadData:[list objectAtIndex:i]];
            [array addObject:restaurant];
        }
        [[AppInfo sharedInfo] setRestaurantList:array];
        [restaurantTable reloadData];
    }
}

-(void)parseYelpRestaurantsList:(id)list {
    
    if (list && [list isKindOfClass:[NSArray class]]) {
        
        [[AppInfo sharedInfo] setYelpRestaurantList:list];
        [restaurantTable reloadData];
    }
}

#pragma mark
#pragma mark Logical Method

-(void)selectedRestaurantIndex:(int)index {
    
    PageSwipeController *pageController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PageSwipeController"];
    pageController.selectedIndex = index;
    [self.navigationController pushViewController:pageController animated:YES];
}

-(void)openMapWithRestaurantAtIndex:(int)index {
    
    @synchronized(self) {
        NSMutableString *address_string = [NSMutableString string];
        if (index < [[AppInfo sharedInfo].restaurantsList count]) {
            RestaurantModel *restaurantModel = [[AppInfo sharedInfo].restaurantsList objectAtIndex:index];
            [address_string appendFormat:@"%@ %@ %@ %@ %@", restaurantModel.restaurantName, restaurantModel.addressLine1, restaurantModel.city, restaurantModel.stateCode, restaurantModel.zipCode];
        }
        else {
            NSInteger row = index-[[AppInfo sharedInfo].restaurantsList count];
            NSDictionary *restaurantData = [[AppInfo sharedInfo].yelpRestaurantsList objectAtIndex:row];
            [address_string appendFormat:@"%@ %@ %@", [restaurantData objectForKey:@"name"], [[[restaurantData objectForKey:@"location"] objectForKey:@"display_address"] firstObject], [[[restaurantData objectForKey:@"location"] objectForKey:@"display_address"] lastObject]];
            
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

#pragma mark
#pragma mark IBAction Methods

-(IBAction)showSideMenu:(id)sender {
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}

#pragma mark
#pragma mark UITableViewDelegate/UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[AppInfo sharedInfo].restaurantsList count]+[[AppInfo sharedInfo].yelpRestaurantsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"RestaurantCellIdentifier";
    
    RestaurantCell *cell = (RestaurantCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RestaurantCell" owner:self options:nil] objectAtIndex:0];
        cell.parentController = self;

    }
    
    if (indexPath.row < [[AppInfo sharedInfo].restaurantsList count]) {
        
        RestaurantModel *restaurant = [[AppInfo sharedInfo].restaurantsList objectAtIndex:indexPath.row];
        cell.restaurantName_lbl.text = restaurant.restaurantName;
        cell.address_lbl.text = restaurant.addressLine1;
        cell.distance_lbl.text = [NSString stringWithFormat:@"%.2f mi", restaurant.distance];
        NSMutableString *string = [NSMutableString string];
        for (int i=0; i<[restaurant.restaurantCategoryList count]; i++) {
            
            if (i > 0) {
                [string appendString:@", "];
            }
            id obj = [restaurant.restaurantCategoryList objectAtIndex:i];
            [string appendString:[obj objectForKey:@"Name"]];
        }
        cell.restaurantCategory_lbl.text = string;
        cell.review_lbl.text = @"0 Reviews";
        [cell setRatings:0.0];
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ASSET_URL, restaurant.assetUrl]];
        cell.restaurantImage.image = Nil;
        [cell.restaurantImage setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"restaurant_place_holder.png"]];
    }
    else {
        
        NSInteger row = indexPath.row-[[AppInfo sharedInfo].restaurantsList count];
        NSDictionary *restaurant = [[AppInfo sharedInfo].yelpRestaurantsList objectAtIndex:row];
        cell.restaurantName_lbl.text = [restaurant objectForKey:@"name"];
        cell.address_lbl.text = [[[restaurant objectForKey:@"location"] objectForKey:@"address"] firstObject];
        cell.review_lbl.text = [NSString stringWithFormat:@"%@ Reviews", [restaurant objectForKey:@"review_count"]];
        float distance = [[restaurant objectForKey:@"distance"] floatValue]/MILE_IN_METERS;
        cell.distance_lbl.text = [NSString stringWithFormat:@"%.2f mi", distance];
        cell.restaurantCategory_lbl.text = [[[restaurant objectForKey:@"categories"] firstObject] firstObject];
        [cell setRatings:[[restaurant objectForKey:@"rating"] floatValue]];
        cell.restaurantImage.image = Nil;
        [cell.restaurantImage setImageWithURL:[NSURL URLWithString:[restaurant objectForKey:@"image_url"]] placeholderImage:[UIImage imageNamed:@"restaurant_place_holder.png"]];
    }
    
    cell.tag = indexPath.row;
    return cell;
}

#pragma mark
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [locationManager stopUpdatingLocation];
    coordinate.latitude = newLocation.coordinate.latitude;
    coordinate.longitude = newLocation.coordinate.longitude;
    
    [self requestForRestaurants];
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {
    
    [locationManager stopUpdatingLocation];
    CLLocation *location = [locations lastObject];
    coordinate.latitude = location.coordinate.latitude;
    coordinate.longitude = location.coordinate.longitude;

    [self requestForRestaurants];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please check your Location Settings and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
    
    coordinate.latitude = 36.049805;
    coordinate.longitude = -115.244096;
    [self requestForRestaurants];
}

#pragma mark
#pragma mark HTTPRequestDelegate Methods

-(void)didFinishRequest:(HTTPRequest*)httpRequest withData:(id)data {
    
    if (data && [data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue] == true && [data objectForKey:@"List"] && [[data objectForKey:@"List"] isKindOfClass:[NSArray class]]) {
        [self parseRestaurantsList:[data objectForKey:@"List"]];
    }
    requestCount++;
    if (requestCount > 1) {
        [SVProgressHUD dismiss];
        if ([[AppInfo sharedInfo] shouldShowPaymentSignUp]) {
            [self performSelector:@selector(showPaymentAlert) withObject:Nil afterDelay:2.0];
        }
    }
}

-(void)didFinishRequest:(HTTPRequest*)httpRequest withYelpData:(id)data {
    
    if (data && [data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"businesses"] && [[data objectForKey:@"businesses"] isKindOfClass:[NSArray class]]) {
        [self parseYelpRestaurantsList:[data objectForKey:@"businesses"]];
    }
    requestCount++;
    if (requestCount > 1) {
        [SVProgressHUD dismiss];
        if ([[AppInfo sharedInfo] shouldShowPaymentSignUp]) {
            [self performSelector:@selector(showPaymentAlert) withObject:Nil afterDelay:2.0];
        }
    }
}

-(void)didFailRequest:(HTTPRequest*)httpRequest withError:(NSString*)errorMessage {
    
    requestCount++;
    if (requestCount > 1) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

#pragma mark
#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([[AppInfo sharedInfo] shouldShowPaymentSignUp]) {
        [self performSelector:@selector(showPaymentAlert) withObject:Nil afterDelay:1.0];
    }
}

@end
