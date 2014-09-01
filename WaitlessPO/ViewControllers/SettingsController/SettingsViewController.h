//
//  SettingsViewController.h
//  WaitlessPO
//
//  Created by Amad Khilji on 08/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPRequest.h"
#import "LogoutViewController.h"

@interface SettingsViewController : UIViewController <UITextViewDelegate, HTTPRequestDelegate, LogoutDelegate> {
    
    IBOutlet UILabel *email_lbl, *gratuity_lbl, *gratuity_slider_lbl, *version_lbl;
    IBOutlet UIButton *passcode_btn, *notify_me_btn;
    IBOutlet UITextView *feedbackTV;
    IBOutlet UISlider *gratuity_slider;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIView *gratuity_view, *feedback_view, *remove_passcode_view;
    
    LogoutViewController *logoutVC;
}

-(IBAction)menuAction:(id)sender;
-(IBAction)doneToolbarAction:(id)sender;
-(IBAction)gratuityValueChangedAction:(id)sender;
-(IBAction)gratuityButtonAction:(id)sender;
-(IBAction)gratuityDoneAction:(id)sender;
-(IBAction)logoutButtonAction:(id)sender;
-(IBAction)notifyMeButtonAction:(id)sender;
-(IBAction)passcodeButtonAction:(id)sender;
-(IBAction)removePasscodeAction:(id)sender;
-(IBAction)cancelPasscodeAction:(id)sender;
-(IBAction)feedbackButtonAction:(id)sender;
-(IBAction)cancelFeedbackAction:(id)sender;
-(IBAction)sendFeedbackAction:(id)sender;
-(IBAction)legalPrivacyButtonAction:(id)sender;

@end
