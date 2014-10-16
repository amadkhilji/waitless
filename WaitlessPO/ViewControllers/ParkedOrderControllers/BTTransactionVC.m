//
//  BTTransactionVC.m
//  WaitlessPO
//
//  Created by Amad Khilji on 18/03/2014.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import "BTTransactionVC.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "UserModel.h"

@interface BTTransactionVC ()

-(void)loadOrderCost;
-(void)dismissPaymentAlert;

@end

@implementation BTTransactionVC

@synthesize subTotal, tax, gratuity, total;
@synthesize convenience_fee;
@synthesize isConvenienceFee;
@synthesize delegate;
@synthesize parkedOrderId, paymentTitle;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    payment_alert_view.hidden = NO;
    payment_alert_view.center = center;
    summary_alert_view.hidden = YES;
    summary_alert_view.center = center;
    total = subTotal+tax+gratuity;
    convenience_fee = ((total*0.029+0.3)+0.5)/2;
    if (!isConvenienceFee) {
        convenience_fee = 0.0;
    }
    total += convenience_fee;
    subtotal_lbl.text = [NSString stringWithFormat:@"$%.2f", subTotal];
    tax_lbl.text = [NSString stringWithFormat:@"$%.2f", tax];
    gratuity_lbl.text = [NSString stringWithFormat:@"$%.2f", gratuity];
    convenience_fee_lbl.text = [NSString stringWithFormat:@"$%.2f", convenience_fee];
    total_lbl.text = [NSString stringWithFormat:@"$%.2f", total];
    credit_card_lbl.text = paymentTitle;
    
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

-(IBAction)chargeButtonAction:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Processing your payment..." maskType:SVProgressHUDMaskTypeBlack];
    UserModel *user = [AppInfo sharedInfo].user;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:user.tokenID forKey:@"tokenId"];
    [params setObject:parkedOrderId forKey:@"parkedOrderId"];
    [HTTPRequest requestGetWithMethod:@"BrainTreeService/BTPay" Params:params andDelegate:self andRequestType:HTTPRequestTypeBrainTreePayment];
}

-(IBAction)okButtonAction:(id)sender {
    
    payment_alert_view.hidden = YES;
    summary_alert_view.hidden = NO;
}

-(IBAction)backButtonAction:(id)sender {
    
    payment_alert_view.hidden = NO;
    summary_alert_view.hidden = YES;
}

-(IBAction)cancelButtonAction:(id)sender {
    
    [self dismissPaymentAlert];
}

#pragma mark
#pragma mark HTTPRequestDelegate Methods

-(void)didFinishRequest:(HTTPRequest*)httpRequest withData:(id)data {
    
    [SVProgressHUD dismiss];
    if (data && [data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue]) {
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
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Couldn't process your payment." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)didFailRequest:(HTTPRequest*)httpRequest withError:(NSString*)errorMessage {
    
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
