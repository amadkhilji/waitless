//
//  ShareOrderVC.h
//  WaitlessPO
//
//  Created by Amad Khilji on 03/02/2014.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPRequest.h"

@class PODetailsViewController;

@interface ShareOrderVC : UIViewController <UITextFieldDelegate, UITextViewDelegate, HTTPRequestDelegate> {
    
    IBOutlet UITextField *name_TF, *email_TF;
    IBOutlet UITextView  *comments_TV;
    IBOutlet UIView *header_view, *share_view;
    IBOutlet UILabel *title_lbl;
    IBOutlet UIToolbar *toolbar;
    
    NSString *firstName, *lastName;
    
    PODetailsViewController *parentController;
}

@property (atomic, strong) NSString *parkedOrderId, *parkedOrderTitle, *restaurantTitle;

-(void)showShareOrderAlert;
-(void)setParentController:(PODetailsViewController*)viewController;

-(IBAction)doneToolbarAction:(id)sender;
-(IBAction)cancelAction:(id)sender;
-(IBAction)shareAction:(id)sender;

@end
