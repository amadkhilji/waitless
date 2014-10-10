//
//  SettingsViewController.m
//  WaitlessPO
//
//  Created by Amad Khilji on 08/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "SettingsViewController.h"
#import "MFSideMenu.h"
#import "UserModel.h"
#import "SVProgressHUD.h"
#import "LegalPrivacyViewController.h"
#import "PasscodeViewController.h"

@interface SettingsViewController ()

-(void)showLogoutAlert;
-(void)showRemovePasscodeAlert;
-(void)hideRemovePasscodeAlert;
-(void)requestForSendingFeedback;
-(void)requestForUpdateGratuity;
-(void)requestForUpdateNotifyMe;
-(void)requestForUpdatePasscode;

@end

@implementation SettingsViewController

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
    
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, 710)];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UserModel *user = [AppInfo sharedInfo].user;
    email_lbl.text = user.emailAddress;
    gratuity_slider.value = user.gratuity_rate;
    gratuity_lbl.text = [NSString stringWithFormat:@"Gratuity Rate: %.1f%%", gratuity_slider.value];
    gratuity_slider_lbl.text = [NSString stringWithFormat:@"%.1f%%", gratuity_slider.value];
    notify_me_btn.selected = user.shouldNotifyMePromotions;
    if (user.isPasscodeActive && [defaults objectForKey:PASSCODE_VALUE] && [[defaults objectForKey:PASSCODE_VALUE] length] == 4) {
        passcode_btn.selected = YES;
    }
    else {
        passcode_btn.selected = NO;
    }
    version_lbl.text = APP_VERSION;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Private Methods

-(void)showLogoutAlert {
    
    if (!logoutVC) {
        logoutVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LogoutViewController"];
        logoutVC.delegate = self;
    }
    [logoutVC showLogoutAlert];
}

-(void)showRemovePasscodeAlert {
    
    CGRect frame = remove_passcode_view.frame;
    frame.origin = CGPointZero;
    remove_passcode_view.frame = frame;
    remove_passcode_view.alpha = 0.0;
    [self.view addSubview:remove_passcode_view];
    [UIView animateWithDuration:0.3 animations:^{
        remove_passcode_view.alpha = 1.0;
    }completion:^(BOOL finished){
        
    }];
}

-(void)hideRemovePasscodeAlert {
    
    [UIView animateWithDuration:0.3 animations:^{
        remove_passcode_view.alpha = 0.0;
    }completion:^(BOOL finished){
        
        if (finished) {
            [remove_passcode_view removeFromSuperview];
        }
    }];
}

-(void)requestForSendingFeedback {
    
    [SVProgressHUD showWithStatus:@"Sending feedback..." maskType:SVProgressHUDMaskTypeGradient];
    UserModel *user = [AppInfo sharedInfo].user;
    NSString *osVersion = [NSString stringWithFormat:@"%@ %@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:user.tokenID, user.userID, feedbackTV.text, version_lbl.text, osVersion, nil] forKeys:[NSArray arrayWithObjects:@"tokenId", @"userId", @"message", @"AppVersion", @"OSVersion", nil]];
    [HTTPRequest requestPostWithMethod:@"SettingService/Feedback/Add" Params:params andDelegate:self andRequestType:HTTPRequestTypeSettingsSendFeed];
}

-(void)requestForUpdateGratuity {
    
    [SVProgressHUD showWithStatus:@"Updating gratuity..." maskType:SVProgressHUDMaskTypeGradient];
    UserModel *user = [AppInfo sharedInfo].user;
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:user.tokenID, user.userID, [NSNumber numberWithInt:100], [NSNumber numberWithInt:user.gratuity_rate], nil] forKeys:[NSArray arrayWithObjects:@"tokenId", @"userId", @"type", @"value", nil]];
    [HTTPRequest requestGetWithMethod:@"SettingService/Update" Params:params andDelegate:self andRequestType:HTTPRequestTypeSettingsUpdateGratuity];
}

-(void)requestForUpdateNotifyMe {
    
    [SVProgressHUD showWithStatus:@"Updating promotions notification..." maskType:SVProgressHUDMaskTypeGradient];
    UserModel *user = [AppInfo sharedInfo].user;
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:user.tokenID, user.userID, [NSNumber numberWithInt:200], [NSNumber numberWithBool:user.shouldNotifyMePromotions], nil] forKeys:[NSArray arrayWithObjects:@"tokenId", @"userId", @"type", @"value", nil]];
    [HTTPRequest requestGetWithMethod:@"SettingService/Update" Params:params andDelegate:self andRequestType:HTTPRequestTypeSettingsUpdateNotifyMe];
}

-(void)requestForUpdatePasscode {
    
    [SVProgressHUD showWithStatus:@"Updating passcode..." maskType:SVProgressHUDMaskTypeGradient];
    UserModel *user = [AppInfo sharedInfo].user;
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:user.tokenID, user.userID, [NSNumber numberWithInt:300], [NSNumber numberWithBool:user.isPasscodeActive], nil] forKeys:[NSArray arrayWithObjects:@"tokenId", @"userId", @"type", @"value", nil]];
    [HTTPRequest requestGetWithMethod:@"SettingService/Update" Params:params andDelegate:self andRequestType:HTTPRequestTypeSettingsUpdatePasscode];
}

#pragma mark
#pragma mark LogoutDelegate Methods

-(void)logoutUser {
    
    [[AppInfo sharedInfo] logoutUser];
    [self.menuContainerViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)menuAction:(id)sender {
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}

-(IBAction)doneToolbarAction:(id)sender {
    
    [feedbackTV resignFirstResponder];
}

-(IBAction)gratuityButtonAction:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    CGRect frame = gratuity_view.frame;
    frame.origin = CGPointZero;
    gratuity_view.alpha = 0.0;
    [self.view addSubview:gratuity_view];
    
    [UIView animateWithDuration:0.3 animations:^{
        gratuity_view.alpha = 1.0;
    }completion:^(BOOL finished){
        if (finished) {
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(IBAction)gratuityDoneAction:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    
    gratuity_lbl.text = [NSString stringWithFormat:@"Gratuity Rate: %.1f%%", gratuity_slider.value];
    [AppInfo sharedInfo].user.gratuity_rate = gratuity_slider.value;
    [[AppInfo sharedInfo].user saveUser];
    
    [UIView animateWithDuration:0.3 animations:^{
        gratuity_view.alpha = 0.0;
    }completion:^(BOOL finished){
        if (finished) {
            [gratuity_view removeFromSuperview];
            [self.view setUserInteractionEnabled:YES];
            [self requestForUpdateGratuity];
        }
    }];
}

-(IBAction)gratuityValueChangedAction:(id)sender {
    
//    float fraction = ceilf(gratuity_slider.value)-gratuity_slider.value;
//    if (fraction < 0.5) {
//        gratuity_slider.value = floorf(gratuity_slider.value);
//    }
//    else {
//        gratuity_slider.value = ceilf(gratuity_slider.value);
//    }
    gratuity_slider_lbl.text = [NSString stringWithFormat:@"%.1f%%", gratuity_slider.value];
}

-(IBAction)logoutButtonAction:(id)sender {
    
    [self showLogoutAlert];
}

-(IBAction)passcodeButtonAction:(id)sender {
    
    passcode_btn.selected = !passcode_btn.selected;
    if (passcode_btn.selected) {
        PasscodeViewController *passcodeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PasscodeViewController"];
        [self.navigationController pushViewController:passcodeVC animated:YES];
    }
    else {
        [self showRemovePasscodeAlert];
    }
}

-(IBAction)removePasscodeAction:(id)sender {
    
    [AppInfo sharedInfo].user.isPasscodeActive = NO;
    [[AppInfo sharedInfo].user saveUser];
    [self hideRemovePasscodeAlert];
    [self requestForUpdatePasscode];
}

-(IBAction)cancelPasscodeAction:(id)sender {
    
    passcode_btn.selected = YES;
    [self hideRemovePasscodeAlert];
}

-(IBAction)notifyMeButtonAction:(id)sender {
    
    notify_me_btn.selected = !notify_me_btn.selected;
    [AppInfo sharedInfo].user.shouldNotifyMePromotions = notify_me_btn.selected;
    [[AppInfo sharedInfo].user saveUser];
    [self requestForUpdateNotifyMe];
}

-(IBAction)feedbackButtonAction:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    CGRect frame = feedback_view.frame;
    frame.origin = CGPointZero;
    if ([UIScreen mainScreen].bounds.size.height <= 480) {
        frame.origin.y = -45.0;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
            frame.origin.y += 20.0;
        }
    }
    feedback_view.frame = frame;
    feedback_view.alpha = 0.0;
    feedbackTV.text = @"";
    [self.view addSubview:feedback_view];
    
    [UIView animateWithDuration:0.3 animations:^{
        feedback_view.alpha = 1.0;
    }completion:^(BOOL finished){
        if (finished) {
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(IBAction)cancelFeedbackAction:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    [feedbackTV resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        feedback_view.alpha = 0.0;
    }completion:^(BOOL finished){
        if (finished) {
            [feedback_view removeFromSuperview];
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(IBAction)sendFeedbackAction:(id)sender {
    
    if (feedbackTV.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please write some feedback." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alertView show];
    }
    else {
        [self doneToolbarAction:Nil];
        [self requestForSendingFeedback];
        [self cancelFeedbackAction:Nil];
    }
}

-(IBAction)legalPrivacyButtonAction:(id)sender {
    
    LegalPrivacyViewController *legalPrivacyVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LegalPrivacyViewController"];
    [self.navigationController pushViewController:legalPrivacyVC animated:YES];
}

#pragma mark
#pragma mark UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {

    textView.inputAccessoryView = toolbar;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    [textView resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    return YES;
}

#pragma mark
#pragma mark HTTPRequestDelegate Methods

-(void)didFinishRequest:(HTTPRequest*)httpRequest withData:(id)data {
    
    [SVProgressHUD dismiss];
    if (data && [data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue]) {
        if (httpRequest.requestType == HTTPRequestTypeSettingsSendFeed) {
            [SVProgressHUD showSuccessWithStatus:@"Feedback sent successfully."];
        }
        else if (httpRequest.requestType == HTTPRequestTypeSettingsUpdateGratuity) {
            [SVProgressHUD showSuccessWithStatus:@"Gratuity updated successfully."];
        }
        else if (httpRequest.requestType == HTTPRequestTypeSettingsUpdateNotifyMe) {
            [SVProgressHUD showSuccessWithStatus:@"Promotion notification updated successfully."];
        }
        else if (httpRequest.requestType == HTTPRequestTypeSettingsUpdatePasscode) {
            [SVProgressHUD showSuccessWithStatus:@"Passcode updated successfully."];
        }
    }
}

-(void)didFailRequest:(HTTPRequest*)httpRequest withError:(NSString*)errorMessage {
    
    [SVProgressHUD dismiss];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
    [alertView show];
}

@end
