//
//  POTransactionVC.h
//  WaitlessPO
//
//  Created by SSASOFT on 1/20/14.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPRequest.h"

@interface POTransactionVC : UIViewController <UITextFieldDelegate, UITextViewDelegate, HTTPRequestDelegate> {
    
    IBOutlet UIView *donation_view, *send_money_view, *summary_view, *insufficient_funds_view, *available_payment_view, *header_view;
    IBOutlet UILabel *title_lbl, *subtotal_lbl, *tax_lbl, *gratuity_lbl, *donation_lbl, *convenience_fee_lbl, *convenience_fee_title, *donate_change_lbl, *total_lbl, *pay_now_lbl;
    IBOutlet UITextField *pinTF, *customAmountTF;
    IBOutlet UITextView *notesTV;
    IBOutlet UIButton *donate_change_btn, *donate_one_btn, *donate_three_btn, *donate_five_btn, *custom_donate_btn, *pay_now_btn;
    IBOutlet UIToolbar *toolbar;
}

@property (atomic, strong) NSString *parkedOrderId, *parkedOrderTitle;
@property (atomic, assign) float subTotal, tax, gratuity, donation, convenience_fee, total, change;
@property (atomic, assign) BOOL isConvenienceFee;
@property (atomic, weak) id<PaymentDelegate> delegate;

-(void)showPaymentAlert;

-(IBAction)doneToolbarAction:(id)sender;
-(IBAction)donateAmountAction:(id)sender;
-(IBAction)okDwollaButtonAction:(id)sender;
-(IBAction)okButtonAction:(id)sender;
-(IBAction)cancelButtonAction:(id)sender;
-(IBAction)backButtonAction:(id)sender;
-(IBAction)donateButtonAction:(id)sender;
-(IBAction)notNowButtonAction:(id)sender;
-(IBAction)continueButtonAction:(id)sender;
-(IBAction)goToSecondHarvest:(id)sender;

@end
