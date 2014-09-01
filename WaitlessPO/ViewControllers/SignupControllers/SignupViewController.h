//
//  SignupViewController.h
//  WaitlessPO
//
//  Created by SSASOFT on 11/21/13.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPRequest.h"

@class LoginViewController;

@interface SignupViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, HTTPRequestDelegate> {
    
    IBOutlet UIScrollView       *scrollView;
    IBOutlet UITextField        *firstNameTF, *lastNameTF, *emailTF, *passwordTF, *zipCodeTF, *dateOfBirthTF, *genderTF;
    IBOutlet UIPickerView       *genderPicker;
    IBOutlet UIDatePicker       *datePicker;
    IBOutlet UIToolbar          *toolBar;
    IBOutlet UIBarButtonItem    *toolBar_btn;
    
    NSArray *genderList;
}

@property (nonatomic, weak) LoginViewController *parentController;

-(IBAction)loginAction:(id)sender;
-(IBAction)selectDateAction:(id)sender;
-(IBAction)doneToolbarAction:(id)sender;
-(IBAction)submitAction:(id)sender;

@end
