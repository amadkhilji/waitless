//
//  LoginViewController.h
//  WaitlessPO
//
//  Created by Amad Khilji on 28/10/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <GooglePlus/GooglePlus.h>
#import "HTTPRequest.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate, HTTPRequestDelegate> {//, GPPSignInDelegate> {
    
    IBOutlet UIButton   *login_btn, *done_btn;
    IBOutlet UIScrollView   *scrollView;
    IBOutlet UIView *zipCodeView;
    
    HTTPRequestType requestType;
}

@property (nonatomic, assign) BOOL isPasscodeEnabled;
@property (nonatomic, weak) IBOutlet  UITextField *emailTF, *passwordTF, *zipCodeTF;

-(void)showLoginAlert;

-(IBAction)loginButtonClick:(id)sender;
-(IBAction)signInWithGoogle:(id)sender;
-(IBAction)signInWithFB:(id)sender;
-(IBAction)doneZipCodeAction:(id)sender;
-(IBAction)createAccount:(id)sender;
-(IBAction)forgotPasswordAccount:(id)sender;
-(IBAction)termsAction:(id)sender;
-(IBAction)privacyAction:(id)sender;

@end
