//
//  PODetailsViewController.h
//  WaitlessPO
//
//  Created by Amad Khilji on 14/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPRequest.h"
#import "CustomAlertViewDelegate.h"

@class POTransactionVC;
@class BTTransactionVC;
@class ShareOrderVC;
@class ReviewOrderVC;

@interface PODetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UITextViewDelegate, HTTPRequestDelegate, PaymentDelegate, CustomAlertViewDelegate> {
    
    IBOutlet UILabel *title_lbl, *restaurant_name_lbl, *address_lbl, *city_state_lbl, *time_lbl, *date_lbl, *party_size_lbl, *price_lbl, *tax_rate_lbl, *sub_total_lbl, *gratuity_title_lbl, *gratuity_rate_lbl, *total_cost_lbl, *credit_card_lbl, *convenience_lbl, *pickUpTime_lbl, *order_number_lbl, *button_title_lbl;
    IBOutlet UIButton *phone_btn, *isFavorite_btn1, *isFavorite_btn2, *credit_card_btn, *update_order_btn;
    IBOutlet UIImageView *restaurant_image;
    IBOutlet UIView *delete_order_view, *footerView, *opened_order_bar, *closed_order_bar, *fulfilled_order_bar, *no_payment_view, *available_payment_view, *notes_view, *ok_btn_view, *send_btn_view, *credit_card_alert, *payNow_alert_view, *convenience_footer_view, *pickUpTime_footer_view;
    IBOutlet UITextView *notesTV;
    IBOutlet UIToolbar *toolbar;
    IBOutlet UITableView *orderTable;
    
    BOOL isUpdateRequest, isGetRequest, isPaymentUpdateRequest, shouldGoBack, isParkedOrderUpdated, isBackgroundUpdate, isForegroundUpdate, isBackButtonUpdate;
    
    POTransactionVC *transactionVC;
    BTTransactionVC *bt_TransactionVC;
    ShareOrderVC *shareOrderVC;
    ReviewOrderVC *reviewOrderVC;
}

@property (atomic, assign) float gratuity_rate;
@property (nonatomic, readonly) NSMutableArray *foodItemsList;
@property (nonatomic, retain) NSDictionary *orderDetails;

-(void)reloadParkedOrderData;
-(void)setFoodItem:(NSDictionary*)foodItem;
-(void)updateFoodItems:(NSArray*)foodItems andParkedOrderDetails:(NSDictionary*)details;
-(void)showSuccessMessage:(NSString *)message;
-(void)showErrorMessage:(NSString*)message;

-(IBAction)backAction:(id)sender;
-(IBAction)cancelDeleteAction:(id)sender;
-(IBAction)deleteOrderAction:(id)sender;
-(IBAction)phoneButtonClick:(id)sender;
-(IBAction)listButtonClick:(id)sender;
-(IBAction)menuButtonClick:(id)sender;
-(IBAction)plusButtonClick:(id)sender;
-(IBAction)pencilButtonClick:(id)sender;
-(IBAction)tickButtonClick:(id)sender;
-(IBAction)trashButtonClick:(id)sender;
-(IBAction)favoriteButtonClick:(id)sender;
-(IBAction)shareButtonClick:(id)sender;
-(IBAction)mapButtonClick:(id)sender;
-(IBAction)reviewButtonClick:(id)sender;
-(IBAction)creditCardButtonClick:(id)sender;
-(IBAction)dwollaButtonClick:(id)sender;
-(IBAction)noPaymentOKAction:(id)sender;
-(IBAction)paymentOKAction:(id)sender;
-(IBAction)paymentCancelAction:(id)sender;
-(IBAction)doneToolbarAction:(id)sender;
-(IBAction)notesButtonClick:(id)sender;
-(IBAction)cancelNotesAction:(id)sender;
-(IBAction)sendNotesAction:(id)sender;
-(IBAction)okNotesAction:(id)sender;
-(IBAction)okCreditCardAction:(id)sender;
-(IBAction)cancelCreditCardAction:(id)sender;
-(IBAction)payNowOrderAction:(id)sender;
-(IBAction)cancelPayNowOrderAction:(id)sender;
-(IBAction)editPayNowOrderAction:(id)sender;

-(IBAction)longPressGesture:(UILongPressGestureRecognizer*)sender;

@end
