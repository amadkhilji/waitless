//
//  POTransactionVC.m
//  WaitlessPO
//
//  Created by SSASOFT on 1/20/14.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import "POTransactionVC.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "UserModel.h"

@interface POTransactionVC ()

-(void)loadOrderCost;
-(void)dismissPaymentAlert;

@end

@implementation POTransactionVC


@synthesize subTotal, tax, gratuity, donation, convenience_fee, total, change;
@synthesize isConvenienceFee;
@synthesize delegate;
@synthesize parkedOrderId, parkedOrderTitle;

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
    if (!isConvenienceFee) {
        convenience_fee = 0.0;
    }
    else {
        convenience_fee = 0.38;
    }
    [self loadOrderCost];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Private Methods

-(void)dismissPaymentAlert {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0.0;
    }completion:^(BOOL finished){
        
        if (finished) {
            [self.view removeFromSuperview];
        }
    }];
}

-(void)loadOrderCost {
    
    CGPoint center = self.view.center;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        center.y-=20.0;
    }
    title_lbl.text = parkedOrderTitle;
    donation_view.hidden = NO;
    donation_view.center = center;
    customAmountTF.enabled = NO;
    customAmountTF.alpha = 0.5;
    summary_view.hidden = YES;
    summary_view.center = center;
    send_money_view.hidden = YES;
    send_money_view.center = center;
    insufficient_funds_view.hidden = YES;
    insufficient_funds_view.center = center;
    available_payment_view.hidden = YES;
    available_payment_view.center = center;
    donation = change;
    donate_change_lbl.text = [NSString stringWithFormat:@"Donation Change ($%.2f)", change];
    convenience_fee_lbl.text = [NSString stringWithFormat:@"$%.2f", convenience_fee];
    customAmountTF.text = @"5.00";
    pinTF.text = @"";
    notesTV.text = @"";
    donate_change_btn.selected = YES;
    donate_one_btn.selected = NO;
    donate_three_btn.selected = NO;
    donate_five_btn.selected = NO;
    custom_donate_btn.selected = NO;
    
    convenience_fee_lbl.hidden = !isConvenienceFee;
    convenience_fee_title.hidden = !isConvenienceFee;
    
    if (total > 0.0) {
        pay_now_lbl.alpha = 1.0;
        pay_now_btn.enabled = YES;
        [pay_now_btn setUserInteractionEnabled:YES];
    }
    else {
        pay_now_lbl.alpha = 0.5;
        pay_now_btn.enabled = NO;
        [pay_now_btn setUserInteractionEnabled:NO];
    }
}

#pragma mark
#pragma mark Public Methods

-(void)showPaymentAlert {
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIWindow *window = appDelegate.window;
    CGRect frame = self.view.frame;
    frame.origin = CGPointZero;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        frame.origin = CGPointMake(0, 20);
    }
    self.view.frame = frame;
    self.view.alpha = 0.0;
    [window addSubview:self.view];
    
    [self loadOrderCost];
    
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
    
    if (!donation_view.hidden) {
        [self.view setUserInteractionEnabled:NO];
        donation = [customAmountTF.text floatValue];
        [customAmountTF resignFirstResponder];
        CGPoint center = donation_view.center;
        center = self.view.center;
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
            center.y-=20.0;
        }
        [UIView animateWithDuration:0.3 animations:^{
            donation_view.center = center;
        }completion:^(BOOL finished){
            if (finished) {
                [self.view setUserInteractionEnabled:YES];
            }
        }];
    }
    else if (!send_money_view.hidden) {
        [self.view setUserInteractionEnabled:NO];
        [pinTF resignFirstResponder];
        [notesTV resignFirstResponder];
        pinTF.enabled = YES;
        [notesTV setUserInteractionEnabled:YES];
        CGPoint center = send_money_view.center;
        center = self.view.center;
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
            center.y-=20.0;
        }
        [UIView animateWithDuration:0.3 animations:^{
            send_money_view.center = center;
        }completion:^(BOOL finished){
            if (finished) {
                [self.view setUserInteractionEnabled:YES];
            }
        }];
    }
}

-(IBAction)donateAmountAction:(id)sender {
    
    UIButton *button = (UIButton*)sender;
    if (button.tag == 1) {
        //donation change
        [self.view setUserInteractionEnabled:NO];
        donation = change;
        donate_change_btn.selected = YES;
        donate_one_btn.selected = NO;
        donate_three_btn.selected = NO;
        donate_five_btn.selected = NO;
        custom_donate_btn.selected = NO;
        customAmountTF.enabled = NO;
        customAmountTF.alpha = 0.5;
        [customAmountTF resignFirstResponder];
        CGPoint center = donation_view.center;
        center = self.view.center;
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
            center.y-=20.0;
        }
        [UIView animateWithDuration:0.3 animations:^{
            donation_view.center = center;
        }completion:^(BOOL finished){
            if (finished) {
                [self.view setUserInteractionEnabled:YES];
            }
        }];
    }
    else if (button.tag == 2) {
        //1$ donation
        [self.view setUserInteractionEnabled:NO];
        donation = 1.0;
        donate_change_btn.selected = NO;
        donate_one_btn.selected = YES;
        donate_three_btn.selected = NO;
        donate_five_btn.selected = NO;
        custom_donate_btn.selected = NO;
        customAmountTF.enabled = NO;
        customAmountTF.alpha = 0.5;
        [customAmountTF resignFirstResponder];
        CGPoint center = donation_view.center;
        center = self.view.center;
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
            center.y-=20.0;
        }
        [UIView animateWithDuration:0.3 animations:^{
            donation_view.center = center;
        }completion:^(BOOL finished){
            if (finished) {
                [self.view setUserInteractionEnabled:YES];
            }
        }];
    }
    else if (button.tag == 3) {
        //3$ donation
        [self.view setUserInteractionEnabled:NO];
        donation = 3.0;
        donate_change_btn.selected = NO;
        donate_one_btn.selected = NO;
        donate_three_btn.selected = YES;
        donate_five_btn.selected = NO;
        custom_donate_btn.selected = NO;
        customAmountTF.enabled = NO;
        customAmountTF.alpha = 0.5;
        [customAmountTF resignFirstResponder];
        CGPoint center = donation_view.center;
        center = self.view.center;
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
            center.y-=20.0;
        }
        [UIView animateWithDuration:0.3 animations:^{
            donation_view.center = center;
        }completion:^(BOOL finished){
            if (finished) {
                [self.view setUserInteractionEnabled:YES];
            }
        }];
    }
    else if (button.tag == 4) {
        //5$ donation
        [self.view setUserInteractionEnabled:NO];
        donation = 5.0;
        donate_change_btn.selected = NO;
        donate_one_btn.selected = NO;
        donate_three_btn.selected = NO;
        donate_five_btn.selected = YES;
        custom_donate_btn.selected = NO;
        customAmountTF.enabled = NO;
        customAmountTF.alpha = 0.5;
        [customAmountTF resignFirstResponder];
        CGPoint center = donation_view.center;
        center = self.view.center;
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
            center.y-=20.0;
        }
        [UIView animateWithDuration:0.3 animations:^{
            donation_view.center = center;
        }completion:^(BOOL finished){
            if (finished) {
                [self.view setUserInteractionEnabled:YES];
            }
        }];
    }
    else if (button.tag == 5) {
        //custom donation
        donate_change_btn.selected = NO;
        donate_one_btn.selected = NO;
        donate_three_btn.selected = NO;
        donate_five_btn.selected = NO;
        custom_donate_btn.selected = YES;
        customAmountTF.enabled = YES;
        customAmountTF.alpha = 1.0;
        if (customAmountTF.text.length == 0) {
            donation = 0.0;
        }
        else {
            donation = [customAmountTF.text floatValue];
        }
    }
}

-(IBAction)okDwollaButtonAction:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Verifying account details..." maskType:SVProgressHUDMaskTypeGradient];
    UserModel *user = [AppInfo sharedInfo].user;
    [HTTPRequest requestGetWithMethod:@"DwollaService/Balance" Params:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:user.userID, user.tokenID, nil] forKeys:[NSArray arrayWithObjects:@"userId", @"tokenId", nil]] andDelegate:self andRequestType:HTTPRequestTypeGetDwollaAccountBalance];
}

-(IBAction)okButtonAction:(id)sender {
    
    if (pinTF.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Input!" message:@"Please enter your Dwolla Pin correctly." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        [SVProgressHUD showWithStatus:@"Processing your transaction..." maskType:SVProgressHUDMaskTypeGradient];
        UserModel *user = [AppInfo sharedInfo].user;
        NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:parkedOrderId, user.tokenID, pinTF.text, [NSNumber numberWithDouble:total-donation], [NSNumber numberWithDouble:donation], notesTV.text, nil] forKeys:[NSArray arrayWithObjects:@"parkedOrderId", @"tokenId", @"pin", @"amount", @"donationAmount", @"notes", nil]];
        [HTTPRequest requestGetWithMethod:@"DwollaService/Send" Params:params andDelegate:self andRequestType:HTTPRequestTypeSendDwollaMoney];
    }
}

-(IBAction)cancelButtonAction:(id)sender {
    
    [self dismissPaymentAlert];
}

-(IBAction)backButtonAction:(id)sender {
    
    CGPoint center = self.view.center;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        center.y-=20.0;
    }
    if (donate_change_btn.selected) {
        donation = change;
    }
    else if (donate_one_btn.selected) {
        donation = 1.0;
    }
    else if (donate_three_btn.selected) {
        donation = 3.0;
    }
    else if (donate_five_btn.selected) {
        donation = 5.0;
    }
    else if (custom_donate_btn.selected) {
        if (customAmountTF.text.length == 0) {
            donation = 0.0;
        }
        else {
            donation = [customAmountTF.text floatValue];
        }
    }
    summary_view.hidden = YES;
    donation_view.hidden = NO;
    donation_view.center = center;
}

-(IBAction)donateButtonAction:(id)sender {

    [self okDwollaButtonAction:nil];
//    CGPoint center = self.view.center;
//    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
//        center.y-=20.0;
//    }
//    summary_view.hidden = YES;
//    available_payment_view.hidden = NO;
//    available_payment_view.center = center;
}

-(IBAction)notNowButtonAction:(id)sender {
    
    donation = 0.0;
    [self continueButtonAction:nil];

//    CGPoint center = self.view.center;
//    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
//        center.y-=20.0;
//    }
//    donation = 0.0;
//    total = donation+subTotal+tax+gratuity;
//    donation_view.hidden = YES;
//    available_payment_view.hidden = NO;
//    available_payment_view.center = center;
}

-(IBAction)continueButtonAction:(id)sender {
    
    CGPoint center = self.view.center;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        center.y-=20.0;
    }
    total = subTotal+tax+gratuity+donation+convenience_fee;
    donation_view.hidden = YES;
    summary_view.hidden = NO;
    summary_view.center = center;
    subtotal_lbl.text = [NSString stringWithFormat:@"$%.2f", subTotal];
    tax_lbl.text = [NSString stringWithFormat:@"$%.2f", tax];
    gratuity_lbl.text = [NSString stringWithFormat:@"$%.2f", gratuity];
    donation_lbl.text = [NSString stringWithFormat:@"$%.2f", donation];
    convenience_fee_lbl.text = [NSString stringWithFormat:@"$%.2f", convenience_fee];
    total_lbl.text = [NSString stringWithFormat:@"$%.2f", total];
    
    if (total > 0.0) {
        pay_now_lbl.alpha = 1.0;
        pay_now_btn.enabled = YES;
        [pay_now_btn setUserInteractionEnabled:YES];
    }
    else {
        pay_now_lbl.alpha = 0.5;
        pay_now_btn.enabled = NO;
        [pay_now_btn setUserInteractionEnabled:NO];
    }
}

-(IBAction)goToSecondHarvest:(id)sender {
    
    @synchronized(self) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SECOND_HARVEST_URL]];
    }
}

#pragma mark
#pragma mark UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
 
    textField.inputAccessoryView = toolbar;
    CGPoint center = self.view.center;
    float yOffset = 0.0;
    if ([UIScreen mainScreen].bounds.size.height <= 480.0) {
        yOffset+=88.0;
    }
    else {
        yOffset+=50.0;
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        yOffset+=20.0;
    }
    else {
        yOffset-=10.0;
    }
    if (textField == customAmountTF) {
        [self.view setUserInteractionEnabled:NO];
        center.y -= (yOffset+40);
        [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            donation_view.center = center;
        }completion:^(BOOL finished){
            if (finished) {
                [self.view setUserInteractionEnabled:YES];
            }
        }];
    }
    else if (textField == pinTF) {
        [notesTV setUserInteractionEnabled:NO];
    }
    return YES;
}

#pragma mark
#pragma mark UITextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    pinTF.enabled = NO;
    textView.inputAccessoryView = toolbar;
    [self.view setUserInteractionEnabled:NO];
    CGPoint center = self.view.center;
    float yOffset = 0.0;
    if ([UIScreen mainScreen].bounds.size.height <= 480.0) {
        yOffset+=88.0;
    }
    else {
        yOffset+=40.0;
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        yOffset+=20.0;
    }
    else {
        yOffset-=10.0;
    }
    center.y -= (yOffset+30);
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        send_money_view.center = center;
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
    if (httpRequest.requestType == HTTPRequestTypeGetDwollaAccountBalance) {
        CGPoint center = self.view.center;
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
            center.y-=20.0;
        }
        available_payment_view.hidden = YES;
        summary_view.hidden = YES;
        if (data && [data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue] && [data objectForKey:@"Message"] && [[data objectForKey:@"Message"] floatValue] >= total) {
            send_money_view.hidden = NO;
            send_money_view.center = center;
        }
        else {
            insufficient_funds_view.hidden = NO;
            insufficient_funds_view.center = center;
        }
    }
    else if (httpRequest.requestType == HTTPRequestTypeSendDwollaMoney) {
        [self dismissPaymentAlert];
        if (data && [data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue]) {
            if (delegate && [delegate respondsToSelector:@selector(paymentSuccessful:)]) {
                [delegate paymentSuccessful:[data objectForKey:@"Message"]];
            }
        }
        else {
            if (delegate && [delegate respondsToSelector:@selector(paymentFailed:)]) {
                [delegate paymentFailed:[data objectForKey:@"Message"]];
            }
        }
    }
}

-(void)didFailRequest:(HTTPRequest*)httpRequest withError:(NSString*)errorMessage {
    
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
