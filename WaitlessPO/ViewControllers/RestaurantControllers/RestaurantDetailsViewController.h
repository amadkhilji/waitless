//
//  RestaurantDetailsViewController.h
//  WaitlessPO
//
//  Created by SSASOFT on 12/3/13.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPRequest.h"

@class RestaurantModel;
@class PageSwipeController;

@interface RestaurantDetailsViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, HTTPRequestDelegate> {
    
    IBOutlet UILabel *title_lbl, *restaurantName_lbl, *address_lbl, *city_state_lbl, *distance_lbl, *categories_lbl, *reviews_lbl, *hours_lbl, *payNow_date_lbl;
    IBOutlet UIButton *phone_btn;
    IBOutlet UIImageView *restaurant_image, *star1_image, *star2_image, *star3_image, *star4_image, *star5_image;
    IBOutlet UITextView *description_TV;
    IBOutlet UIView *waitless_btn_view, *order_menu_view, *website_view, *parked_order_view, *header_view, *footer_view, *section_header_view, *payNow_alert_view, *payNow_order_view;
    IBOutlet UITextField *order_dateTF, *order_timeTF, *order_party_sizeTF, *payNow_timeTF, *payNow_party_sizeTF;
    IBOutlet UIDatePicker *orderDatePicker, *orderTimePicker;
    IBOutlet UIPickerView *partySizePicker, *payNowPartySizePicker, *payNowTimePicker;
    IBOutlet UIToolbar          *toolBar;
    IBOutlet UIBarButtonItem    *toolBar_btn;
    IBOutlet UITableView        *offersTable;
    
    NSMutableDictionary *restaurantData;
    NSMutableArray      *offersList, *payNowTimeList;
    
    RestaurantModel *restaurantModel;
    BOOL isCreateOrderRequest;
    BOOL isGetParkedOrderRequest;
}

@property (nonatomic, weak) PageSwipeController *pageController;
@property (nonatomic, assign) BOOL isYelpRestaurant;
@property (nonatomic, assign) int selectedIndex;

-(void)setRestaurantData:(NSDictionary*)data;
-(void)setRestaurantModel:(RestaurantModel*)restaurantObj;
-(NSString*)getRestaurantTitle;
-(void)reloadPromotions;

-(IBAction)phoneButtonClick:(id)sender;
-(IBAction)waitlessButtonClick:(id)sender;
-(IBAction)orderButtonClick:(id)sender;
-(IBAction)menuButtonClick:(id)sender;
-(IBAction)websiteButtonClick:(id)sender;
-(IBAction)backAction:(id)sender;
-(IBAction)dateChangedAction:(id)sender;
-(IBAction)timeChangedAction:(id)sender;
-(IBAction)doneOrderFieldsAction:(id)sender;
-(IBAction)createOrderAction:(id)sender;
-(IBAction)cancelOrderAction:(id)sender;
-(IBAction)openRestaurantMap:(id)sender;
-(IBAction)cancelPayNowOrderAction:(id)sender;
-(IBAction)cancelPayNowAlertAction:(id)sender;
-(IBAction)payNowPaymentAction:(id)sender;
-(IBAction)payNowOrderAction:(id)sender;

@end
