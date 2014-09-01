//
//  POEditViewController.h
//  WaitlessPO
//
//  Created by Amad Khilji on 15/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPRequest.h"

@class PODetailsViewController;

@interface POEditViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, HTTPRequestDelegate> {
    
    IBOutlet UILabel *restaurant_name_lbl, *address_lbl, *city_state_lbl, *price_lbl, *tax_rate_lbl, *sub_total_lbl, *gratuity_title_lbl, *total_cost_lbl, *order_date_lbl, *button_title_lbl;
    IBOutlet UITextField *date_timeTF, *party_sizeTF, *gratuity_rateTF, *pickUp_timeTF;
    IBOutlet UIButton *phone_btn;
    IBOutlet UIImageView *restaurant_image;
    IBOutlet UIView *footerView, *delete_order_view, *pickup_time_alert_view;
    IBOutlet UIPickerView *partySizePicker, *pickUp_timePicker;
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UIToolbar          *toolBar;
    IBOutlet UIBarButtonItem    *toolBar_btn;
    
    IBOutlet UITableView *orderTable;
    
    UITextField *quantityTF;
    NSMutableDictionary *orderDetails;
    NSMutableArray *foodItemsList, *selectedItems, *pickUpTimeList;
    BOOL isUpdateRequest, isGetRequest, shouldUpdate;
}

@property (atomic, assign) float gratuity_rate;
@property (atomic, weak) PODetailsViewController *parentController;

-(void)setFoodItemsList:(NSArray*)foodItems;
-(void)setOrderDetails:(NSDictionary*)details;
-(void)selectFoodItemAtIndex:(NSInteger)index Selected:(BOOL)isSelected;

-(IBAction)phoneButtonClick:(id)sender;
-(IBAction)updateOrderAction:(id)sender;
-(IBAction)deleteOrderAction:(id)sender;
-(IBAction)cancelDeleteOrderAction:(id)sender;
-(IBAction)doneDeleteOrderAction:(id)sender;
-(IBAction)updateDateAction:(id)sender;
-(IBAction)doneToolbarAction:(id)sender;
-(IBAction)donePickUpTimeAction:(id)sender;
-(IBAction)cancelPickUpTimeAction:(id)sender;

-(IBAction)longPressGesture:(UILongPressGestureRecognizer*)sender;

@end
