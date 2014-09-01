//
//  LegalPrivacyViewController.m
//  WaitlessPO
//
//  Created by SSASOFT on 12/16/13.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "LegalPrivacyViewController.h"
#import "WebViewController.h"
#import "OpenSourceViewController.h"

@interface LegalPrivacyViewController ()

@end

@implementation LegalPrivacyViewController

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

#pragma mark
#pragma mark IBAction Methods

-(IBAction)backAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)termsOfServiceAction:(id)sender {
    
    WebViewController *webVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"WebViewController"];
    webVC.url_str = TERMS_OF_USE_URL_M;
    [self.navigationController pushViewController:webVC animated:YES];
}

-(IBAction)privacyPolicyAction:(id)sender {
    
    WebViewController *webVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"WebViewController"];
    webVC.url_str = PRIVACY_POLICY_URL_M;
    [self.navigationController pushViewController:webVC animated:YES];
}

-(IBAction)openSourceAttributionsAction:(id)sender {
    
    OpenSourceViewController *openSourceVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"OpenSourceViewController"];
    [self.navigationController pushViewController:openSourceVC animated:YES];
}

@end
