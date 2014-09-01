//
//  BrainTreeViewController.m
//  WaitlessPO
//
//  Created by Amad Khilji on 09/03/2014.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import "BrainTreeViewController.h"
#import "SVProgressHUD.h"
#import "UserModel.h"

@interface BrainTreeViewController ()

@end

@implementation BrainTreeViewController

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
    didRegisterBrainTreeSuccessfully = NO;
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
    [webView_container loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:BRAIN_TREE_SIGNUP_URL]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 
#pragma mark IBAction Methods

-(IBAction)backAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
#pragma mark UIWebViewDelegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    int foundIndex = 0;
    NSArray *list = [request.URL.absoluteString componentsSeparatedByString:@"?"];
    if (list && [list count] > 1) {
        list = [[list objectAtIndex:1] componentsSeparatedByString:@"&"];
        if (list && [list count] > 1) {
            for (int i=0; i<[list count]; i++) {
                NSString *parameter = [list objectAtIndex:i];
                if ([parameter hasPrefix:@"maskedNumber="]) {
                    maskedNumber = [parameter stringByReplacingOccurrencesOfString:@"maskedNumber=" withString:@""];
                    foundIndex++;
                }
                else if ([parameter hasPrefix:@"cardType="]) {
                    cardType = [parameter stringByReplacingOccurrencesOfString:@"cardType=" withString:@""];
                    foundIndex++;
                }
            }
        }
    }
    if (foundIndex == 2) {
        didRegisterBrainTreeSuccessfully = YES;
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {

    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    [SVProgressHUD dismiss];
    if (didRegisterBrainTreeSuccessfully) {
        //do something
        UserModel *user = [AppInfo sharedInfo].user;
        NSMutableDictionary *oAuthPayment = [NSMutableDictionary dictionary];
        [oAuthPayment setObject:[cardType stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"CardType"];
        [oAuthPayment setObject:maskedNumber forKey:@"OAuthToken"];
        [oAuthPayment setObject:BRAINTREE_PAYMENT forKey:@"Provider"];
        [oAuthPayment setObject:user.userID forKey:@"UserId"];
        [user updateUserAuthentication:oAuthPayment];
        [self backAction:Nil];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [SVProgressHUD dismiss];
    didRegisterBrainTreeSuccessfully = NO;
}

@end
