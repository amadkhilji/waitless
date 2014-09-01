//
//  OpenSourceViewController.m
//  WaitlessPO
//
//  Created by SSASOFT on 1/1/14.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import "OpenSourceViewController.h"
#import "WebViewController.h"

@interface OpenSourceViewController ()

@end

@implementation OpenSourceViewController

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
    
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, 575)];
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

-(IBAction)facebookWebsiteAction:(id)sender {
    
    @synchronized(self) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://developers.facebook.com/docs/ios/"]];
    }
}

-(IBAction)googlePlusWebsiteAction:(id)sender {
    
    @synchronized(self) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://developers.google.com/+/mobile/ios/getting-started"]];
    }
}

-(IBAction)apacheLicenseAction:(id)sender {
    
    @synchronized(self) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.apache.org/licenses/LICENSE-2.0"]];
    }
}

-(IBAction)OAuthConsumerWebsiteAction:(id)sender {
    
    @synchronized(self) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://code.google.com/p/oauthconsumer/"]];
    }
}

-(IBAction)MITLicenseAction:(id)sender {
    
    @synchronized(self) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://opensource.org/licenses/mit-license.php"]];
    }
}

-(IBAction)dwollaWebsiteAction:(id)sender {
 
    @synchronized(self) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/Dwolla/dwolla-ios"]];
    }
}

-(IBAction)SDWebImageWebsiteAction:(id)sender {
    
    @synchronized(self) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/rs/SDWebImage"]];
    }
}

-(IBAction)JSONKitWebsiteAction:(id)sender {
 
    @synchronized(self) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://github.com/johnezang/JSONKit"]];
    }
}

@end
