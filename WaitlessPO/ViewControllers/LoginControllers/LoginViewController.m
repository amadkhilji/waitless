//
//  LoginViewController.m
//  WaitlessPO
//
//  Created by Amad Khilji on 28/10/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "LoginViewController.h"
#import "SVProgressHUD.h"
#import "RestaurantViewController.h"
#import "ParkedOrderViewController.h"
#import "UserModel.h"
#import "RestaurantModel.h"
#import "SignupViewController.h"
#import "MFSideMenu.h"
#import "SideMenuViewController.h"
#import "PasscodeViewController.h"
#import "DwollaViewController.h"
#import "PaymentsViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController ()

-(void)requestForLogin;
-(void)requestForDeviceRegistration;
-(void)requestForFacebookUpdate;
-(void)requestForGooglePlusUpdate;
-(void)requestForFacebookSignup;
-(void)requestForGooglePlusSignup;
-(BOOL)isLoginSuccessflul:(id)data;
-(void)showMenuViewController;
-(void)resignAllTextFields;
-(void)showZipCodeAlertView;
-(void)showDwollaViewController;
-(void)showPaymentAlert;

@end

@implementation LoginViewController

@synthesize emailTF, passwordTF, zipCodeTF;
@synthesize isPasscodeEnabled;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    isPasscodeEnabled = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignAllTextFields)];
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    [scrollView addGestureRecognizer:tapGesture];
    
    [scrollView setContentSize:CGSizeMake(320, 548)];
    [GPPSignIn sharedInstance].delegate = self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:EMAIL] && [defaults objectForKey:PASSWORD]) {
        emailTF.text = [defaults objectForKey:EMAIL];
        passwordTF.text = [defaults objectForKey:PASSWORD];
    }
    else {
        emailTF.text = @"";
        passwordTF.text = @"";
    }
    if (passwordTF.text.length < 8) {
        login_btn.enabled = NO;
    }
    else {
        login_btn.enabled = YES;
    }
    if ([defaults boolForKey:PASSCODE] && [defaults objectForKey:PASSCODE_VALUE] && [[defaults objectForKey:PASSCODE_VALUE] isKindOfClass:[NSString class]] && [[defaults objectForKey:PASSCODE_VALUE] length] == 4 && isPasscodeEnabled) {
        PasscodeViewController *passcodeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PasscodeViewController"];
        passcodeVC.isAlertPasscodeView = YES;
        passcodeVC.parentController = self;
        [self presentViewController:passcodeVC animated:NO completion:Nil];
    }
    else if (isPasscodeEnabled == NO || [defaults boolForKey:PASSCODE] == NO) {
        if ([AppInfo sharedInfo].sessionType == SessionTypeWaitless) {
            [self loginButtonClick:Nil];
        }
        else if ([AppInfo sharedInfo].sessionType == SessionTypeFacebook) {
            [self signInWithFB:Nil];
        }
        else if ([AppInfo sharedInfo].sessionType == SessionTypeGooglePlus) {
            [self signInWithGoogle:Nil];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Private Methods

-(NSString*)getFormattedDateStringFromFBString:(NSString*)dateString {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *date = [formatter dateFromString:dateString];
    [formatter setDateFormat:@"MM/dd/yy"];
    return [formatter stringFromDate:date];
}

-(NSString*)getFormattedDateStringFromGoogleString:(NSString*)dateString {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:dateString];
    [formatter setDateFormat:@"MM/dd/yy"];
    NSString *tmpStr = [formatter stringFromDate:date];
    return (tmpStr)?tmpStr:@"";
}

-(BOOL)isLoginSuccessflul:(id)data {
    
    if ([data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue] == true) {
        
        UserModel *user = [[UserModel alloc] init];
        user.loginID = [data objectForKey:@"LoginId"];
        user.message = [data objectForKey:@"Message"];
        user.tokenID = [data objectForKey:@"TokenId"];
        user.isSuccessful = [[data objectForKey:@"IsSuccessful"] boolValue];
        user.authenticationList = [NSMutableArray arrayWithArray:[[data objectForKey:@"AuthenticationList"] objectForKey:@"List"]];
        user.promotionList = [NSMutableArray arrayWithArray:[[data objectForKey:@"PromotionList"] objectForKey:@"List"]];
        [user sortPromotionsList];
        user.parkedOrderList = [NSMutableArray arrayWithArray:[[data objectForKey:@"ParkedOrderList"] objectForKey:@"List"]];
        NSArray *list = [[[data objectForKey:@"ParkedOrderList"] objectForKey:@"RestaurantList"] objectForKey:@"List"];
        for (int i=0; i<[list count]; i++) {
            RestaurantModel *restaurant = [[RestaurantModel alloc] init];
            [restaurant loadData:[list objectAtIndex:i]];
            [user.restaurantList addObject:restaurant];
        }
        [user sortRestaurantsList];
        [user loadData:[data objectForKey:@"Member"]];
        if ([[data objectForKey:@"SettingList"] objectForKey:@"List"] && [[[data objectForKey:@"SettingList"] objectForKey:@"List"] isKindOfClass:[NSArray class]]) {
            [user loadSettingsFromList:[[data objectForKey:@"SettingList"] objectForKey:@"List"]];
        }
        [[AppInfo sharedInfo] setUserModel:user];
//        [[AppInfo sharedInfo] setRestaurantList:list];
        
        return YES;
    }
    
    return NO;
}

-(void)requestForLogin {
    
    [SVProgressHUD showWithStatus:@"Signing in..." maskType:SVProgressHUDMaskTypeGradient];
    requestType = HTTPRequestTypeWaitless;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:emailTF.text, @"emailaddress", passwordTF.text, @"password", nil];
    [HTTPRequest requestGetWithMethod:@"MembershipService/Login" Params:params andDelegate:self];
}

-(void)requestForDeviceRegistration {
    
    [SVProgressHUD showWithStatus:@"Signing in..." maskType:SVProgressHUDMaskTypeGradient];
    requestType = HTTPRequestTypeDeviceRegistration;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *device_token = nil;
    if ([defaults objectForKey:DEVICE_TOKEN] && (NSNull*)[defaults objectForKey:DEVICE_TOKEN] != [NSNull null]) {
        device_token = [NSString stringWithFormat:@"%@", [defaults objectForKey:DEVICE_TOKEN]];
    }
    else {
        UIDevice *device = [UIDevice currentDevice];
        device_token = [NSString stringWithFormat:@"%@ %@ %@ %@", device.name, device.model, device.systemName, device.systemVersion];
    }
    UserModel *user = [AppInfo sharedInfo].user;
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:user.userID, user.tokenID, device_token, [NSNumber numberWithInt:2], nil] forKeys:[NSArray arrayWithObjects:@"userId", @"tokenId", @"registrationId", @"deviceType", nil]];
    [HTTPRequest requestPostWithMethod:@"MembershipService/UserRegistration/Insert" Params:params andDelegate:self];
}

-(void)requestForFacebookSignup {
    
    [SVProgressHUD showWithStatus:@"Validating user..." maskType:SVProgressHUDMaskTypeGradient];
    requestType = HTTPRequestTypeFacebookSignUp;
    FBSession *session = [FBSession activeSession];
    UIDevice *device = [UIDevice currentDevice];
    NSString *deviceId = [NSString stringWithFormat:@"%@ %@ %@ %@", device.name, device.model, device.systemName, device.systemVersion];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[[AppInfo sharedInfo].fbUserData objectForKey:@"first_name"], @"firstName", [[AppInfo sharedInfo].fbUserData objectForKey:@"last_name"], @"lastName", [[AppInfo sharedInfo].fbUserData objectForKey:@"email"], @"emailAddress", [NSString stringWithFormat:@"%@", session.accessTokenData.accessToken], @"password", @"", @"city", @"", @"state", zipCodeTF.text, @"zipCode", [self getFormattedDateStringFromFBString:[[AppInfo sharedInfo].fbUserData objectForKey:@"birthday"]], @"dateofBirth", [[[[AppInfo sharedInfo].fbUserData objectForKey:@"gender"] substringToIndex:1] lowercaseString], @"gender", [NSNumber numberWithBool:YES], @"readTerms", deviceId, @"deviceId", nil];
    [HTTPRequest requestPostWithMethod:@"MembershipService/User/Add" Params:params andDelegate:self];
}

-(void)requestForGooglePlusSignup {
    
    [SVProgressHUD showWithStatus:@"Validating user..." maskType:SVProgressHUDMaskTypeGradient];
    requestType = HTTPRequestTypeGooglePlusSignUp;
    GTLPlusPerson *user = [GPPSignIn sharedInstance].googlePlusUser;
    UIDevice *device = [UIDevice currentDevice];
    NSString *deviceId = [NSString stringWithFormat:@"%@ %@ %@ %@", device.name, device.model, device.systemName, device.systemVersion];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:user.name.givenName, @"firstName", user.name.familyName, @"lastName", [GPPSignIn sharedInstance].userEmail, @"emailAddress", [NSString stringWithFormat:@"%@", [GPPSignIn sharedInstance].idToken], @"password", @"", @"city", @"", @"state", zipCodeTF.text, @"zipCode", [self getFormattedDateStringFromGoogleString:user.birthday], @"dateofBirth", [[user.gender substringToIndex:1] lowercaseString], @"gender", [NSNumber numberWithBool:YES], @"readTerms", deviceId, @"deviceId", nil];
    [HTTPRequest requestPostWithMethod:@"MembershipService/User/Add" Params:params andDelegate:self];
}

-(void)requestForFacebookUpdate {
    
    [SVProgressHUD showWithStatus:@"Signing in..." maskType:SVProgressHUDMaskTypeGradient];
    requestType = HTTPRequestTypeFacebookConnect;
    FBSession *session = [FBSession activeSession];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[AppInfo sharedInfo].fbUserData objectForKey:@"email"], [NSString stringWithFormat:@"%@", session.accessTokenData.accessToken], @"facebook", nil] forKeys:[NSArray arrayWithObjects:@"emailaddress", @"password", @"thirdPartyType", nil]];
    [HTTPRequest requestGetWithMethod:@"MembershipService/User/Update" Params:dictionary andDelegate:self];
    
}

-(void)requestForGooglePlusUpdate {
    
    [SVProgressHUD showWithStatus:@"Signing in..." maskType:SVProgressHUDMaskTypeGradient];
    requestType = HTTPRequestTypeGooglePlusConnect;
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[GPPSignIn sharedInstance].userEmail, [NSString stringWithFormat:@"%@", [GPPSignIn sharedInstance].idToken], @"google", nil] forKeys:[NSArray arrayWithObjects:@"emailaddress", @"password", @"thirdPartyType", nil]];
    [HTTPRequest requestGetWithMethod:@"MembershipService/User/Update" Params:dictionary andDelegate:self];
}

-(void)showMenuViewController {
    
    UIViewController *viewController = Nil;
    if ([[AppInfo sharedInfo] shouldShowPaymentSignUp]) {
        PaymentsViewController *paymentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PaymentsViewController"];
        viewController = paymentVC;
    }
    else if ([[AppInfo sharedInfo].user.parkedOrderList count] == 0) {
        RestaurantViewController *restaurantVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"RestaurantViewController"];
        viewController = restaurantVC;
    }
    else {
        ParkedOrderViewController *parkedOrderVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ParkedOrderViewController"];
        viewController = parkedOrderVC;
    }
    [AppInfo sharedInfo].isPaymentMethodVisible = NO;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];

    SideMenuViewController *sideMenuController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewController" bundle:[NSBundle mainBundle]];
    
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:navigationController
                                                    leftMenuViewController:sideMenuController
                                                    rightMenuViewController:nil];
    
    container.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:container animated:YES completion:nil];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
}

-(void)showDwollaViewController {
    
    DwollaViewController *dwollaVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"DwollaViewController"];
    dwollaVC.shouldShowListButton = YES;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dwollaVC];
    
    SideMenuViewController *sideMenuController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewController" bundle:[NSBundle mainBundle]];
    
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:navigationController
                                                    leftMenuViewController:sideMenuController
                                                    rightMenuViewController:nil];
    
    container.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:container animated:YES completion:nil];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }
}

-(void)resignAllTextFields {
    
    [emailTF resignFirstResponder];
    [passwordTF resignFirstResponder];
}

-(void)showZipCodeAlertView {
    
    [self.view setUserInteractionEnabled:NO];
    CGRect frame = zipCodeView.frame;
    frame.origin = CGPointMake(0, 0);
    zipCodeView.frame = frame;
    zipCodeView.alpha = 0.0;
    zipCodeTF.text = @"";
    done_btn.enabled = NO;
    [self.view addSubview:zipCodeView];
    
    [UIView animateWithDuration:0.5 animations:^ {
        
        zipCodeView.alpha = 1.0;
    }completion:^(BOOL finished) {
        
        if (finished) {
            [self.view setUserInteractionEnabled:YES];
        }
    }];
    
}

-(void)showPaymentAlert {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Waitless" message:@"Add a payment source now." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Not Now", nil];
    [alertView show];
}

#pragma mark
#pragma mark Logical Methods

-(void)showLoginAlert {
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"iWaitless" message:@"Please login to proceed." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
//    [alertView show];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:EMAIL] && [defaults objectForKey:PASSWORD]) {
        emailTF.text = [defaults objectForKey:EMAIL];
        passwordTF.text = [defaults objectForKey:PASSWORD];
    }
    else {
        emailTF.text = @"";
        passwordTF.text = @"";
    }
    [self requestForLogin];
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)loginButtonClick:(id)sender {
    
    NSString *errorMessage = nil;
    if (emailTF.text.length == 0) {
        errorMessage = @"Please enter a valid username.";
    }
    else if (passwordTF.text.length == 0) {
        errorMessage = @"Please enter a valid password";
    }
    if (errorMessage) {
        if ([AppInfo sharedInfo].sessionType == SessionTypeNone) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Input" message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }
    else {
        [self requestForLogin];
    }
}

-(IBAction)signInWithGoogle:(id)sender {
    
    if (![GPPSignIn sharedInstance].authentication) {
        [GPPSignIn sharedInstance].shouldFetchGoogleUserID = YES;
        [GPPSignIn sharedInstance].shouldFetchGoogleUserEmail = YES;
        [GPPSignIn sharedInstance].shouldFetchGooglePlusUser = YES;
        [GPPSignIn sharedInstance].scopes = [NSArray arrayWithObjects:kGTLAuthScopePlusLogin, kGTLAuthScopePlusMe, nil];
        [[GPPSignIn sharedInstance] authenticate];
    }
    else if ([[GPPSignIn sharedInstance] hasAuthInKeychain]) {
        [SVProgressHUD showWithStatus:@"Connecting with Google+" maskType:SVProgressHUDMaskTypeGradient];
        [[GPPSignIn sharedInstance] trySilentAuthentication];
    }
    
}

-(IBAction)signInWithFB:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Connecting with Facebook" maskType:SVProgressHUDMaskTypeGradient];
    BOOL flag = [[FBSession activeSession] isOpen];
    [FBSession openActiveSessionWithReadPermissions:[NSArray arrayWithObjects:@"user_birthday", @"user_location", @"basic_info", @"email", nil] allowLoginUI:!flag completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        if (!error && status == FBSessionStateOpen) {
            [SVProgressHUD showWithStatus:@"Fetching user info..." maskType:SVProgressHUDMaskTypeGradient];
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                
                if (!error && result) {
                    [SVProgressHUD showWithStatus:@"Authenticating user..." maskType:SVProgressHUDMaskTypeGradient];
                    requestType = HTTPRequestTypeFacebookFindUser;
                    [AppInfo sharedInfo].fbUserData = result;
                    NSDictionary *params = [NSDictionary dictionaryWithObject:[result objectForKey:@"email"] forKey:@"emailaddress"];
                    [HTTPRequest requestGetWithMethod:@"MembershipService/Get" Params:params andDelegate:self];
                }
                else {
                    [SVProgressHUD dismiss];
                }
            }];
        }
        else {
            [SVProgressHUD dismiss];
        }
    }];
}

-(IBAction)doneZipCodeAction:(id)sender {
    
    [self.view setUserInteractionEnabled:NO];
    [zipCodeTF resignFirstResponder];
    
    [UIView animateWithDuration:0.5 animations:^ {
        
        zipCodeView.alpha = 0.0;
    }completion:^(BOOL finished) {
        
        if (finished) {
            [zipCodeView removeFromSuperview];
            [self.view setUserInteractionEnabled:YES];
            if (requestType == HTTPRequestTypeFacebookFindUser) {
                [self requestForFacebookSignup];
            }
            else if (requestType == HTTPRequestTypeGooglePlusFindUser) {
                [self requestForGooglePlusSignup];
            }
        }
    }];
}

-(IBAction)createAccount:(id)sender {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    SignupViewController *signupVC = [storyBoard instantiateViewControllerWithIdentifier:@"SignupViewController"];
    signupVC.parentController = self;
    [self presentViewController:signupVC animated:YES completion:Nil];
}

-(IBAction)forgotPasswordAccount:(id)sender {
    
    @synchronized(self) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:FORGOT_PASSWORD_URL]];
    }
}

-(IBAction)termsAction:(id)sender {
    
    @synchronized(self) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TERMS_OF_USE_URL]];
    }
}

-(IBAction)privacyAction:(id)sender {
    
    @synchronized(self) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PRIVACY_POLICY_URL]];
    }
}

#pragma mark
#pragma mark UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == emailTF) {
        [textField resignFirstResponder];
        [passwordTF becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSInteger length = [textField.text length];
    if (string.length == 0) {
        length--;
    }
    else {
        length += string.length;
    }
    
    if (textField == passwordTF) {
        if (length < 8) {
            login_btn.enabled = NO;
        }
        else {
            login_btn.enabled = YES;
        }
    }
    
    if (textField == zipCodeTF) {
        if (length > 0) {
            done_btn.enabled = YES;
        }
        else {
            done_btn.enabled = NO;
        }
    }
    
    return YES;
}

#pragma mark
#pragma mark HTTPRequestDelegate Methods

-(void)didFinishRequest:(HTTPRequest*)httpRequest withData:(id)data {
    
    [SVProgressHUD dismiss];
    
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        if (requestType == HTTPRequestTypeFacebookFindUser) {
            
            if ([data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue]) {
                [self requestForFacebookUpdate];
            }
            else {
                [self showZipCodeAlertView];
            }
        }
        else if (requestType == HTTPRequestTypeFacebookConnect) {
            BOOL isSuccessful = [self isLoginSuccessflul:data];
            if (isSuccessful) {
                [AppInfo sharedInfo].sessionType = SessionTypeFacebook;
                [[AppInfo sharedInfo] saveUserSession];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults removeObjectForKey:EMAIL];
                [defaults removeObjectForKey:PASSWORD];
                [defaults synchronize];
                emailTF.text = @"";
                passwordTF.text = @"";
                login_btn.enabled = NO;
                [self showMenuViewController];
//                [self requestForDeviceRegistration];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[data objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (requestType == HTTPRequestTypeFacebookSignUp) {
            if ([data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue] == YES) {
                //Facebook signup successful
                [self requestForFacebookUpdate];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[data objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (requestType == HTTPRequestTypeGooglePlusFindUser) {
            
            if ([data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue]) {
                [self requestForGooglePlusUpdate];
            }
            else {
                [self showZipCodeAlertView];
            }
        }
        else if (requestType == HTTPRequestTypeGooglePlusConnect) {
            BOOL isSuccessful = [self isLoginSuccessflul:data];
            if (isSuccessful) {
                [AppInfo sharedInfo].sessionType = SessionTypeGooglePlus;
                [[AppInfo sharedInfo] saveUserSession];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults removeObjectForKey:EMAIL];
                [defaults removeObjectForKey:PASSWORD];
                [defaults synchronize];
                emailTF.text = @"";
                passwordTF.text = @"";
                login_btn.enabled = NO;
                [self showMenuViewController];
//                [self requestForDeviceRegistration];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[data objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (requestType == HTTPRequestTypeGooglePlusSignUp) {
            if ([data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue] == YES) {
                //Google plus signup successful
                [self requestForGooglePlusUpdate];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[data objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (requestType == HTTPRequestTypeWaitless) {
            BOOL isSuccessful = [self isLoginSuccessflul:data];
            if (isSuccessful) {
                [AppInfo sharedInfo].sessionType = SessionTypeWaitless;
                [[AppInfo sharedInfo] saveUserSession];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:emailTF.text forKey:EMAIL];
                [defaults setObject:passwordTF.text forKey:PASSWORD];
                [defaults synchronize];
                [self showMenuViewController];
//                [self requestForDeviceRegistration];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[data objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else if (requestType == HTTPRequestTypeDeviceRegistration) {
            if ([data objectForKey:@"IsSuccessful"] && [[data objectForKey:@"IsSuccessful"] boolValue]) {
                [self showMenuViewController];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[data objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }
}

-(void)didFailRequest:(HTTPRequest*)httpRequest withError:(NSString*)errorMessage {
    
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark
#pragma mark GPPSignInDelegate Methods

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    
    [SVProgressHUD dismiss];
    if (!error) {
        [SVProgressHUD showWithStatus:@"Authenticating user..." maskType:SVProgressHUDMaskTypeGradient];
        requestType = HTTPRequestTypeGooglePlusFindUser;
        NSDictionary *params = [NSDictionary dictionaryWithObject:[GPPSignIn sharedInstance].userEmail forKey:@"emailaddress"];
        [HTTPRequest requestGetWithMethod:@"MembershipService/Get" Params:params andDelegate:self];
    }
    else {
        NSLog(@"error logging in with google.");
    }
}

#pragma mark
#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self showDwollaViewController];
    }
    else {
        [self showMenuViewController];
    }
}

@end
