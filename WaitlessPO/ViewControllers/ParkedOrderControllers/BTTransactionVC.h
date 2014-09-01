//
//  BTTransactionVC.h
//  WaitlessPO
//
//  Created by Amad Khilji on 18/03/2014.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPRequest.h"

@interface BTTransactionVC : UIViewController <HTTPRequestDelegate> {
    
    IBOutlet UIView  *payment_alert_view, *summary_alert_view;
    IBOutlet UILabel *credit_card_lbl, *subtotal_lbl, *tax_lbl, *gratuity_lbl, *convenience_fee_lbl, *convenience_fee_title, *total_lbl, *pay_now_lbl;
    IBOutlet UIButton   *pay_now_btn;
}

@property (atomic, strong) NSString *parkedOrderId, *paymentTitle;
@property (atomic, assign) float subTotal, tax, gratuity, total;
@property (atomic, readonly) float convenience_fee;
@property (atomic, assign) BOOL isConvenienceFee;
@property (atomic, weak) id<PaymentDelegate> delegate;

-(void)showPaymentAlert;

-(IBAction)chargeButtonAction:(id)sender;
-(IBAction)okButtonAction:(id)sender;
-(IBAction)backButtonAction:(id)sender;
-(IBAction)cancelButtonAction:(id)sender;

@end
