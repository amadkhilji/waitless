//
//  PaymentMethodsAlertView.h
//  WaitlessPO
//
//  Created by Amad Khilji on 17/03/2014.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertViewDelegate.h"

@class PODetailsViewController;

@interface PaymentMethodsAlertView : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UITableView    *paymentMethodTable;
    NSMutableArray *paymentMethods;
}

@property (nonatomic, retain) IBOutlet  UIView      *alertView;
@property (nonatomic, retain) IBOutlet  UIView      *backgroundView;
@property (nonatomic, assign) IBOutlet  id<CustomAlertViewDelegate, NSObject> delegate;
@property (nonatomic, assign) PODetailsViewController *parentController;

- (void)show;
- (IBAction)dismiss;

@end
