//
//  SignupViewController.m
//  WaitlessPO
//
//  Created by SSASOFT on 11/21/13.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "SignupViewController.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"

@interface SignupViewController ()

-(void)setFormattedDate;
-(NSString*)getFormattedDateString;
-(void)moveScrollViewToTop;
-(void)resignAllTextFields;
-(void)requestForSignup;

@end

@implementation SignupViewController

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
    // Do any additional setup after loading the view from its nib.

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignAllTextFields)];
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    [scrollView addGestureRecognizer:tapGesture];
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, 504)];
        
    genderList = [NSArray arrayWithObjects:@"Male", @"Female", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit fromDate:datePicker.date];
    NSInteger year = [dateComponents year];
    year -= 18;
    [dateComponents setYear:year];
    [datePicker setDate:[calendar dateFromComponents:dateComponents] animated:NO];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Private Methods

-(void)setFormattedDate {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    dateOfBirthTF.text = [formatter stringFromDate:datePicker.date];
}

-(NSString*)getFormattedDateString {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yy"];
    return [formatter stringFromDate:datePicker.date];
}

-(void)moveScrollViewToTop {
    
    CGFloat offset7 = 0.0;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        offset7 = 20.0;
    }
    CGRect frame = scrollView.frame;
    frame.origin = CGPointMake(0, TOP_BAR_HEIGHT+offset7);
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        
        scrollView.frame = frame;
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)resignAllTextFields {
    
    for (UIView *view in scrollView.subviews) {
        
        if ([view isKindOfClass:[UITextField class]]) {
            
            UITextField *textField = (UITextField*)view;
            if ([textField isFirstResponder]) {
                if (textField == dateOfBirthTF || textField == genderTF) {
                    [self doneToolbarAction:Nil];
                }
                else {
                    [textField resignFirstResponder];
                }
                textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
        }
    }
    [self moveScrollViewToTop];
}

-(void)requestForSignup {
//    [[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN]
    [SVProgressHUD showWithStatus:@"Creating account..." maskType:SVProgressHUDMaskTypeGradient];
    UIDevice *device = [UIDevice currentDevice];
    NSString *deviceId = [NSString stringWithFormat:@"%@ %@ %@ %@", device.name, device.model, device.systemName, device.systemVersion];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:firstNameTF.text, @"firstName", lastNameTF.text, @"lastName", emailTF.text, @"emailAddress", passwordTF.text, @"password", @"", @"city", @"", @"state", zipCodeTF.text, @"zipCode", [self getFormattedDateString], @"dateofBirth", [[genderTF.text substringToIndex:1] lowercaseString], @"gender", [NSNumber numberWithBool:YES], @"readTerms", deviceId, @"deviceId", nil];
    [HTTPRequest requestPostWithMethod:@"MembershipService/User/Add" Params:params andDelegate:self];
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)loginAction:(id)sender {
    
    [self resignAllTextFields];
    [self dismissViewControllerAnimated:YES completion:Nil];
}

-(IBAction)selectDateAction:(id)sender {
    
    [self setFormattedDate];
}

-(IBAction)doneToolbarAction:(id)sender {
    
    if (toolBar_btn.tag == dateOfBirthTF.tag) {
        [dateOfBirthTF resignFirstResponder];
        [self setFormattedDate];
    }
    else if (toolBar_btn.tag == genderTF.tag) {
        [genderTF resignFirstResponder];
        genderTF.text = [genderList objectAtIndex:[genderPicker selectedRowInComponent:0]];
    }
    
    if (scrollView.frame.origin.y < TOP_BAR_HEIGHT) {
        [self moveScrollViewToTop];
    }
}

-(IBAction)submitAction:(id)sender {

    NSInteger alertTag = 0;
    NSMutableString *errorMessage = [NSMutableString string];
    if ([firstNameTF.text length] == 0) {
        alertTag = firstNameTF.tag;
        [errorMessage appendString:@"Please enter your first name."];
    }
    else if ([lastNameTF.text length] == 0) {
        alertTag = lastNameTF.tag;
        [errorMessage appendString:@"Please enter your last name."];
    }
    else if ([emailTF.text length] == 0) {
        alertTag = emailTF.tag;
        [errorMessage appendString:@"Please enter your email address."];
    }
    else if (![AppInfo isValidEmail:emailTF.text]) {
        alertTag = emailTF.tag;
        [errorMessage appendString:@"Please enter a valid email address."];
    }
    else if ([passwordTF.text length] == 0) {
        alertTag = passwordTF.tag;
        [errorMessage appendString:@"Please enter your password."];
    }
    else if (![AppInfo isValidPassword:passwordTF.text]) {
        alertTag = passwordTF.tag;
        [errorMessage appendString:@"Password must be at at least 8 characters long. Must contain a Number and an Upper case character."];
    }
    else if ([zipCodeTF.text length] == 0) {
        alertTag = zipCodeTF.tag;
        [errorMessage appendString:@"Please enter your zipCode."];
    }
    else if ([genderTF.text length] == 0) {
        alertTag = genderTF.tag;
        [errorMessage appendString:@"Please select your gender."];
    }
    else if ([dateOfBirthTF.text length] == 0) {
        alertTag = dateOfBirthTF.tag;
        [errorMessage appendString:@"Please enter your date of birth."];
    }
    else if ([AppInfo age:datePicker.date] < 18) {
        alertTag = dateOfBirthTF.tag;
        [errorMessage appendString:@"Your age must be 18 years or older in order to use waitless services."];
    }
    
    [self resignAllTextFields];
    
    if (errorMessage.length > 0) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Input!" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        alertView.tag = alertTag;
        [alertView show];
    }
    else {
        //submit sign up
        [self requestForSignup];
    }
}

#pragma mark
#pragma mark UIPickerViewDelegate/UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [genderList count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [genderList objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    genderTF.text = [genderList objectAtIndex:row];
}

#pragma mark
#pragma marl UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    CGFloat offset7 = 0.0;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        offset7 = 20.0;
    }
    CGFloat height = self.view.frame.size.height-260-offset7;
    CGRect frame = scrollView.frame;
    CGFloat yPoint = textField.frame.origin.y+textField.frame.size.height;
    if (yPoint > height) {
        frame.origin = CGPointMake(0, height-yPoint);
    }
    else {
        frame.origin = CGPointMake(0, TOP_BAR_HEIGHT+offset7);
    }
    [scrollView setContentOffset:CGPointZero animated:YES];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        
        scrollView.frame = frame;
        
    } completion:^(BOOL finished) {
        
    }];
    
    if (textField == genderTF) {
       
        [toolBar_btn setTitle:@"Select Gender"];
        toolBar_btn.tag = genderTF.tag;
        genderTF.inputAccessoryView = toolBar;
        genderTF.inputView = genderPicker;
    }
    else if (textField == dateOfBirthTF) {
        
        [toolBar_btn setTitle:@"Select Date"];
        toolBar_btn.tag = dateOfBirthTF.tag;
        dateOfBirthTF.inputAccessoryView = toolBar;
        dateOfBirthTF.inputView = datePicker;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == firstNameTF) {
        [firstNameTF resignFirstResponder];
        [lastNameTF becomeFirstResponder];
    }
    else if (textField == lastNameTF) {
        [lastNameTF resignFirstResponder];
        [emailTF becomeFirstResponder];
    }
    else if (textField == emailTF) {
        [emailTF resignFirstResponder];
        [passwordTF becomeFirstResponder];
    }
    else if (textField == passwordTF) {
        [passwordTF resignFirstResponder];
        [zipCodeTF becomeFirstResponder];
    }
    else if (textField == zipCodeTF) {
        [zipCodeTF resignFirstResponder];
        [genderTF becomeFirstResponder];
    }
    else {
        
        [self moveScrollViewToTop];
    }
    
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == passwordTF) {
        NSInteger length = textField.text.length+string.length;
        if (length > 15) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark
#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    for (UIView *view in scrollView.subviews) {
        
        if ([view isKindOfClass:[UITextField class]]) {
            
            UITextField *textField = (UITextField*)view;
            if (textField.tag == alertView.tag) {
                [textField becomeFirstResponder];
                break;
            }
        }
    }
}

#pragma mark
#pragma mark UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [AppInfo sharedInfo].isPaymentMethodVisible = NO;
    }
    else {
        [AppInfo sharedInfo].isPaymentMethodVisible = YES;
    }
    [self dismissViewControllerAnimated:YES completion:^ {
        if (parentController && [parentController respondsToSelector:@selector(showLoginAlert)]) {
            [parentController showLoginAlert];
        }
    }];
}

#pragma mark
#pragma mark HTTPRequestDelegate Methods

-(void)didFinishRequest:(HTTPRequest*)httpRequest withData:(id)data {
    
    [SVProgressHUD dismiss];
    
    if (data && [data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue] == true) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:emailTF.text forKey:EMAIL];
        [defaults setObject:passwordTF.text forKey:PASSWORD];
        [defaults synchronize];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[data objectForKey:@"Message"] delegate:self cancelButtonTitle:@"Later" destructiveButtonTitle:nil otherButtonTitles:@"Set up a Payment method Now", nil];
        [actionSheet showInView:self.view];
    }
    else {
        NSMutableString *message = [NSMutableString string];
        if (data && [data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"Message"] && (NSNull*)[data objectForKey:@"Message"] != [NSNull null]) {
            [message appendString:[data objectForKey:@"Message"]];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

-(void)didFailRequest:(HTTPRequest*)httpRequest withError:(NSString*)errorMessage {
    
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
