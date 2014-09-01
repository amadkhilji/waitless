//
//  PaymentsViewController.h
//  WaitlessPO
//
//  Created by Amad Khilji on 08/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    IBOutlet UITableView *paymentsTable;
    IBOutlet UIView *footerView, *renew_payment_alert;
    IBOutlet UILabel *renew_title_lbl, *renew_description_lbl;
    
    NSMutableArray *myPaymentMethods, *otherPaymentMethods, *creditCardPaymentMethods;
    
    PaymentType    renewPaymentType;
}

-(void)selectPaymentMethodAtIndexPath:(NSIndexPath*)indexPath withPaymentType:(PaymentType)paymentType;

-(IBAction)menuAction:(id)sender;
-(IBAction)myPaymentsAction:(id)sender;
-(IBAction)okRenewPaymentAction:(id)sender;
-(IBAction)cancelRenewPaymentAction:(id)sender;

@end
