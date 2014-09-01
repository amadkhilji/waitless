//
//  ShareOrderVC.m
//  WaitlessPO
//
//  Created by Amad Khilji on 03/02/2014.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import "ShareOrderVC.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "UserModel.h"
#import "PODetailsViewController.h"

@interface ShareOrderVC ()

-(void)dismissShareOrderAlert;
-(void)loadOrderDetails;
-(void)requestShareParkedOrder;
-(void)dismissShareOrderAlertWithMessage:(NSString*)message;

@end

@implementation ShareOrderVC

@synthesize parkedOrderId, parkedOrderTitle, restaurantTitle;

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
    
    [self loadOrderDetails];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Private Methods

-(void)loadOrderDetails {
    
    CGPoint center = self.view.center;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        center.y-=20.0;
    }
    title_lbl.text = parkedOrderTitle;
    share_view.center = center;
    name_TF.placeholder = @"First & Last Name of Recipient";
    name_TF.text = @"";
    email_TF.placeholder = @"Recipient Email";
    email_TF.text = @"";
    comments_TV.text = [NSString stringWithFormat:@"I'd like you to try this meal at %@", restaurantTitle];
}

-(void)dismissShareOrderAlert {
    
    [self dismissShareOrderAlertWithMessage:Nil];
}

-(void)dismissShareOrderAlertWithMessage:(NSString *)message {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0.0;
    }completion:^(BOOL finished){
        
        if (finished) {
            [self.view removeFromSuperview];
            if (message) {
                [parentController showSuccessMessage:message];
            }
        }
    }];
}

-(void)requestShareParkedOrder {
    
    [SVProgressHUD showWithStatus:@"Sharing parked order..." maskType:SVProgressHUDMaskTypeGradient];
    UserModel *user = [AppInfo sharedInfo].user;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:user.tokenID forKey:@"TokenId"];
    [params setObject:parkedOrderId forKey:@"ParkedOrderId"];
    [params setObject:firstName forKey:@"FirstName"];
    [params setObject:lastName forKey:@"LastName"];
    [params setObject:email_TF.text forKey:@"EmailAddress"];
    [params setObject:comments_TV.text forKey:@"Comments"];
    [HTTPRequest requestPostWithMethod:@"RestaurantService/ParkedOrder/Share" Params:params andDelegate:self];
}

#pragma mark
#pragma mark Public Methods

-(void)setParentController:(PODetailsViewController*)viewController {
    
    parentController = viewController;
}

-(void)showShareOrderAlert {
    
    CGRect frame = self.view.frame;
    frame.origin = CGPointZero;
    self.view.frame = frame;
    self.view.alpha = 0.0;
    [parentController.view addSubview:self.view];
    
    [self loadOrderDetails];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 1.0;
    }completion:^(BOOL finished){
        
        if (finished) {
//            [self.view removeFromSuperview];
        }
    }];
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)doneToolbarAction:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    [name_TF resignFirstResponder];
    [email_TF resignFirstResponder];
    [comments_TV resignFirstResponder];
    name_TF.enabled = YES;
    email_TF.enabled = YES;
    [comments_TV setUserInteractionEnabled:YES];
    CGPoint center = self.view.center;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        center.y-=20.0;
    }
    [UIView animateWithDuration:0.3 animations:^{
        share_view.center = center;
    }completion:^(BOOL finished){
        if (finished) {
            [self.view setUserInteractionEnabled:YES];
        }
    }];
}

-(IBAction)shareAction:(id)sender {
    
    NSString *errorMessage = Nil;
    firstName = @"";
    lastName = @"";
    NSArray *list = [name_TF.text componentsSeparatedByString:@" "];
    if (list && [list count] == 2) {
        firstName = [list objectAtIndex:0];
        lastName = [list objectAtIndex:1];
    }
    if (firstName.length == 0 || lastName.length == 0) {
        errorMessage = @"Invalid first name or last name. Please enter again.";
    }
    else if (![AppInfo isValidEmail:email_TF.text]) {
        errorMessage = @"Invalid email format. Please enter again.";
    }
    
    if (errorMessage) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Waitless" message:errorMessage delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alertView show];
    }
    else {
        [self requestShareParkedOrder];
    }
}

-(IBAction)cancelAction:(id)sender {
    
    [self dismissShareOrderAlert];
}

#pragma mark
#pragma mark UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [comments_TV setUserInteractionEnabled:NO];
    if (textField == name_TF) {
        email_TF.enabled = NO;
    }
    else {
        name_TF.enabled = NO;
    }
    textField.inputAccessoryView = toolbar;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    name_TF.enabled = YES;
    email_TF.enabled = YES;
    [comments_TV setUserInteractionEnabled:YES];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark
#pragma mark UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    [self.view setUserInteractionEnabled:NO];
    name_TF.enabled = NO;
    email_TF.enabled = NO;
    textView.inputAccessoryView = toolbar;
    CGPoint center = self.view.center;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        center.y-=20.0;
    }
    float yOffset = 0.0;
    if ([UIScreen mainScreen].bounds.size.height <= 480.0) {
        yOffset+=textView.frame.size.height;
    }
    else {
        yOffset+=(textView.frame.size.height/2.0);
    }
    center.y -= yOffset;
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        share_view.center = center;
    }completion:^(BOOL finished){
        if (finished) {
            [self.view setUserInteractionEnabled:YES];
        }
    }];
    return YES;
}

#pragma mark
#pragma mark HTTPRequestDelegate Methods

-(void)didFinishRequest:(HTTPRequest*)httpRequest withData:(id)data {
    
    [SVProgressHUD dismiss];
    if (data && [data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue]) {
        [self dismissShareOrderAlertWithMessage:[data objectForKey:@"Message"]];
    }
}

-(void)didFailRequest:(HTTPRequest*)httpRequest withError:(NSString*)errorMessage {
    
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
