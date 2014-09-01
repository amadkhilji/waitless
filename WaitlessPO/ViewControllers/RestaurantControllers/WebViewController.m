//
//  WebViewController.m
//  WaitlessPO
//
//  Created by SSASOFT on 12/9/13.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import "WebViewController.h"
#import "MFSideMenu.h"

@interface WebViewController ()

@end

@implementation WebViewController

@synthesize title_str, url_str;

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
    
    if ([url_str isEqualToString:HELP_URL]) {
        back_btn_view.hidden = YES;
        menu_btn_view.hidden = NO;
    }
    else {
        back_btn_view.hidden = NO;
        menu_btn_view.hidden = YES;
    }
    
    indicator.center = CGPointMake(webView.center.x, webView.center.y);
    title_lbl.text = (title_str && title_str.length>0)?title_str:@"Waitless";
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url_str]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark
#pragma mark Private Methods

-(void)zoomToFit
{
    
    if ([webView respondsToSelector:@selector(scrollView)])
    {
        UIScrollView *scrollView = [webView scrollView];
        
        float zoom = webView.bounds.size.width/scrollView.contentSize.width;
        [scrollView setZoomScale:zoom animated:NO];
    }
}

#pragma mark
#pragma mark IBAction Methods

-(IBAction)backAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)menuAction:(id)sender {
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateLeftMenuOpen];
}

#pragma mark
#pragma mark UIWebViewDelegate Methods

- (BOOL)webView:(UIWebView *)_webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {

    [indicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
//    [self zoomToFit];
    [indicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [indicator stopAnimating];
}

@end
