//
//  ParkedOrderViewController.h
//  WaitlessPO
//
//  Created by Amad Khilji on 08/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPRequest.h"

@interface ParkedOrderViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, HTTPRequestDelegate> {
    
    IBOutlet UITableView *orderTableView;
    IBOutlet UIView      *create_parked_order_view;
    NSMutableArray  *availableParkedOrders;
    BOOL isUpdateRequest;
}

-(void)updateParkedOrders;
-(IBAction)menuAction:(id)sender;
-(IBAction)createParkedOrderAction:(id)sender;

@end
