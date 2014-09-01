//
//  SideMenuViewController.h
//  WaitlessPO
//
//  Created by SSASOFT on 11/29/13.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogoutViewController.h"
#import "HTTPRequest.h"

@interface SideMenuViewController : UIViewController <LogoutDelegate, HTTPRequestDelegate> {
    
    
    IBOutlet UITableView    *sideMenuTableView;
    
    NSArray* itemLabels;
    NSArray* itemIcons;
    
    LogoutViewController *logoutVC;
    
    BOOL shouldShowPaymentAlert;
}

@end
