//
//  LogoutViewController.h
//  WaitlessPO
//
//  Created by SSASOFT on 12/9/13.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LogoutDelegate <NSObject>

-(void)logoutUser;

@end

@interface LogoutViewController : UIViewController

@property (atomic, weak) id<LogoutDelegate> delegate;

-(void)showLogoutAlert;

-(IBAction)okButtonAction:(id)sender;
-(IBAction)cancelButtonAction:(id)sender;

@end
