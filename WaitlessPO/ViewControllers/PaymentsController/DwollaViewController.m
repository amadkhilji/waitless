//
//  DwollaViewController.m
//  WaitlessPO
//
//  Created by Amad Khilji on 29/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "DwollaViewController.h"
#import "SVProgressHUD.h"
#import "UserModel.h"
#import "MFSideMenu.h"

@interface DwollaViewController ()

-(void)loadDwolla;
-(void)requestForUpdateToken;

@end

@implementation DwollaViewController

@synthesize isModalPresentationStyle, shouldShowListButton;

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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    isUpdatingToken = NO;
    if (shouldShowListButton) {
        list_btn_view.hidden = NO;
        back_btn_view.hidden = YES;
    }
    else {
        list_btn_view.hidden = YES;
        back_btn_view.hidden = NO;
    }
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
    [self performSelector:@selector(loadDwolla) withObject:Nil afterDelay:0.1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Private Methods

-(void)loadDwolla {
    
    float yOffset = 0.0;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        yOffset = 20.0;
    }
    NSArray *scopes = [[NSArray alloc] initWithObjects:@"send", @"balance", @"accountinfofull", @"contacts", @"funding",  @"request", @"transactions", nil];
    dwollaOAuthClient = [[DwollaOAuth2Client alloc] initWithFrame:CGRectMake(0, 0, 320, webView_container.frame.size.height) key:DWOLLA_API_KEY secret:DWOLLA_API_SECRET redirect:@"https://www.dwolla.com" response:@"code" scopes:scopes view:webView_container reciever:self];
    [dwollaOAuthClient login];
}

-(void)requestForUpdateToken {
    
    isUpdatingToken = YES;
    [SVProgressHUD showWithStatus:@"Authenticating payment info..." maskType:SVProgressHUDMaskTypeGradient];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[AppInfo sharedInfo].user.userID, [AppInfo sharedInfo].user.tokenID, @"Dwolla", [[DwollaAPI sharedInstance] getAccessToken], nil] forKeys:[NSArray arrayWithObjects:@"userId", @"tokenId", @"Provider", @"OAuthToken", nil]];
    [HTTPRequest requestGetWithMethod:@"AuthenticationService/Update" Params:params andDelegate:self];
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)backAction:(id)sender {
    
    if (isModalPresentationStyle) {
        [self dismissViewControllerAnimated:YES completion:Nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(IBAction)listAction:(id)sender {
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}

#pragma mark
#pragma mark IDwollaMessages Methods

-(void)successfulLogin
{
    [SVProgressHUD dismiss];
    if ([dwollaOAuthClient isAuthorized]) {
//        DwollaAPI *dwollaAPI = [DwollaAPI sharedInstance];
//        [dwollaAPI setAccessToken:[dwollaOAuthClient.oAuthTokenRepository getAccessToken]];
//        [dwollaAPI setClientKey:[dwollaOAuthClient.oAuthTokenRepository getClientKey]];
//        [dwollaAPI setClientSecret:[dwollaOAuthClient.oAuthTokenRepository getClientSecret]];
//        [dwollaAPI setBaseURL:DWOLLA_API_BASEURL];
        [self requestForUpdateToken];
    }
}

-(void)failedLogin:(NSArray*)errors
{
    if (!isUpdatingToken) {
        [SVProgressHUD dismiss];
    }
}

-(void)startLoading {
    
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
}

-(void)didLoad {
    
    if (!isUpdatingToken) {
        [SVProgressHUD dismiss];
    }
}

-(void)didFailToLoad {
    
    if (!isUpdatingToken) {
        [SVProgressHUD dismiss];
    }
}

#pragma mark
#pragma mark HTTPRequestDelegate Methods

-(void)didFinishRequest:(HTTPRequest*)httpRequest withData:(id)data {
    
    [SVProgressHUD dismiss];
    if (data && [data isKindOfClass:[NSDictionary class]] && [data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue]) {
        [[AppInfo sharedInfo].user updateUserAuthentication:data];
        [self backAction:Nil];
    }
    
}

-(void)didFailRequest:(HTTPRequest*)httpRequest withError:(NSString*)errorMessage {
    
    [SVProgressHUD dismiss];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
    [alertView show];
}

#pragma mark
#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self backAction:Nil];
}

@end
