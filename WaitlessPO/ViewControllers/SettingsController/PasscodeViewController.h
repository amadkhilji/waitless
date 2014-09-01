//
//  PasscodeViewController.h
//  WaitlessPO
//
//  Created by SSASOFT on 12/30/13.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPRequest.h"

@class LoginViewController;

@interface PasscodeViewController : UIViewController <HTTPRequestDelegate, UITextFieldDelegate> {
    
    IBOutlet UITextField *passcode_TF, *rePasscode_TF, *passcode_alert_TF;
    IBOutlet UIView *passcode_AlertView;
    IBOutlet UIButton *set_passcode_btn, *continue_passcode_btn;
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIView *textField_view;
    BOOL isAlertPasscodeView;
    int incorrectCount;
}

@property (atomic, weak) LoginViewController *parentController;
@property (atomic, assign) BOOL isAlertPasscodeView;

-(IBAction)backAction:(id)sender;
-(IBAction)doneToolbarAction:(id)sender;
-(IBAction)setPasscodeButtonAction:(id)sender;
-(IBAction)enterPasscodeButtonAction:(id)sender;

@end
