//
//  LogoutViewController.m
//  WaitlessPO
//
//  Created by SSASOFT on 12/9/13.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "LogoutViewController.h"
#import "SideMenuViewController.h"
#import "AppDelegate.h"

@interface LogoutViewController ()

-(void)dismissLogoutAlert;

@end

@implementation LogoutViewController

@synthesize delegate;

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
#pragma mark Logical Methods

-(void)showLogoutAlert {
    
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIWindow *window = appDelegate.window;
    CGRect frame = self.view.frame;
    frame.origin = CGPointZero;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        frame.size.height+=20.0;
    }
    self.view.frame = frame;
    self.view.alpha = 0.0;
    [window addSubview:self.view];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 1.0;
    }completion:^(BOOL finished){
        
        if (finished) {
//            [self.view removeFromSuperview];
        }
    }];
}

-(void)dismissLogoutAlert {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0.0;
    }completion:^(BOOL finished){
        
        if (finished) {
            [self.view removeFromSuperview];
        }
    }];
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)okButtonAction:(id)sender {

    [self dismissLogoutAlert];
    if (delegate && [delegate respondsToSelector:@selector(logoutUser)]) {
        [delegate logoutUser];
    }
}

-(IBAction)cancelButtonAction:(id)sender {

    [self dismissLogoutAlert];
}

@end
