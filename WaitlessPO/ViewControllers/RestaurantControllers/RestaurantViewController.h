//
//  RestaurantViewController.h
//  WaitlessPO
//
//  Created by Amad Khilji on 01/11/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "HTTPRequest.h"

@interface RestaurantViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, HTTPRequestDelegate> {
    
    CLLocationManager *locationManager;
    CLLocationCoordinate2D coordinate;
}

@property (atomic, readonly) int requestCount;
@property (atomic, readonly) IBOutlet UITableView    *restaurantTable;

-(void)selectedRestaurantIndex:(int)index;
-(void)openMapWithRestaurantAtIndex:(int)index;

-(IBAction)showSideMenu:(id)sender;

@end
