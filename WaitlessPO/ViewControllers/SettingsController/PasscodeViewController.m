//
//  PasscodeViewController.m
//  WaitlessPO
//
//  Created by SSASOFT on 12/30/13.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "PasscodeViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "UserModel.h"
#import "LoginViewController.h"

@interface PasscodeViewController ()

-(void)dismissAlert;

@end

@implementation PasscodeViewController

@synthesize isAlertPasscodeView;
@synthesize parentController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    incorrectCount = 0;
    set_passcode_btn.enabled = NO;
    continue_passcode_btn.enabled = NO;
    
    passcode_AlertView.hidden = !isAlertPasscodeView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Private Methods

-(void)dismissAlert {
    
    if (parentController) {
        parentController.isPasscodeEnabled = NO;
    }
    [self dismissViewControllerAnimated:YES completion:Nil];
}

-(void)requestForUpdatePasscode {
    
    [SVProgressHUD showWithStatus:@"Updating passcode..." maskType:SVProgressHUDMaskTypeGradient];
    UserModel *user = [AppInfo sharedInfo].user;
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:user.tokenID, user.userID, [NSNumber numberWithInt:300], [NSNumber numberWithBool:user.isPasscodeActive], nil] forKeys:[NSArray arrayWithObjects:@"tokenId", @"userId", @"type", @"value", nil]];
    [HTTPRequest requestGetWithMethod:@"SettingService/Update" Params:params andDelegate:self andRequestType:HTTPRequestTypeSettingsUpdatePasscode];
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)backAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)doneToolbarAction:(id)sender {
    
    [passcode_TF resignFirstResponder];
    [rePasscode_TF resignFirstResponder];
    [passcode_alert_TF resignFirstResponder];
    if ([UIScreen mainScreen].bounds.size.height <= 480.0 && passcode_AlertView.hidden) {
        [self.view setUserInteractionEnabled:NO];
        CGRect frame = textField_view.frame;
        frame.origin.y = 85.0;
        [UIView animateWithDuration:0.3 animations:^{
            textField_view.frame = frame;
        }completion:^(BOOL finished){
            if (finished) {
                [self.view setUserInteractionEnabled:YES];
            }
        }];
    }
}

-(IBAction)setPasscodeButtonAction:(id)sender {
    
    if ([passcode_TF.text isEqualToString:rePasscode_TF.text]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:passcode_TF.text forKey:PASSCODE_VALUE];
        [defaults synchronize];
        [AppInfo sharedInfo].user.isPasscodeActive = YES;
        [[AppInfo sharedInfo].user saveUser];
        [self requestForUpdatePasscode];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Passcodes don't match. Please enter again." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alertView show];
    }
}

-(IBAction)enterPasscodeButtonAction:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:PASSCODE_VALUE] isEqualToString:passcode_alert_TF.text]) {
        [self dismissAlert];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"Wrong Passcode"];
        incorrectCount++;
        if (incorrectCount >= 3) {
            [[AppInfo sharedInfo] logoutUser];
            [self performSelector:@selector(dismissAlert) withObject:Nil afterDelay:1.5];
        }
    }
}

#pragma mark
#pragma mark UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    textField.inputAccessoryView = toolbar;
    if ([UIScreen mainScreen].bounds.size.height <= 480.0 && (textField == passcode_TF || textField == rePasscode_TF)) {
        [self.view setUserInteractionEnabled:NO];
        CGRect frame = textField_view.frame;
        frame.origin.y = 60.0;
        [UIView animateWithDuration:0.3 animations:^{
            textField_view.frame = frame;
        }completion:^(BOOL finished){
            if (finished) {
                [self.view setUserInteractionEnabled:YES];
            }
        }];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([UIScreen mainScreen].bounds.size.height <= 480.0 && (textField == passcode_TF || textField == rePasscode_TF)) {
        [self.view setUserInteractionEnabled:NO];
        CGRect frame = textField_view.frame;
        frame.origin.y = 85.0;
        [UIView animateWithDuration:0.3 animations:^{
            textField_view.frame = frame;
        }completion:^(BOOL finished){
            if (finished) {
                [self.view setUserInteractionEnabled:YES];
            }
        }];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL shouldChange = YES;
    NSInteger length = textField.text.length+string.length;
    if ((textField.text.length == 4 && string.length == 0) || length < 4) {
        set_passcode_btn.enabled = NO;
        continue_passcode_btn.enabled = NO;
    }
    else {
        set_passcode_btn.enabled = YES;
        continue_passcode_btn.enabled = YES;
    }
    if (length > 4) {
        shouldChange = NO;
    }
    return shouldChange;
}

#pragma mark
#pragma mark HTTPRequestDelegate Methods

-(void)didFinishRequest:(HTTPRequest*)httpRequest withData:(id)data {
    
    [SVProgressHUD dismiss];
    if (data && [data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue]) {
        [SVProgressHUD showSuccessWithStatus:@"Passcode updated successfully."];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)didFailRequest:(HTTPRequest*)httpRequest withError:(NSString*)errorMessage {
    
    [SVProgressHUD dismiss];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
    [alertView show];
}

@end
