//
//  WebViewController.h
//  WaitlessPO
//
//  Created by SSASOFT on 12/9/13.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate> {
    
    IBOutlet UILabel *title_lbl;
    IBOutlet UIWebView *webView;
    IBOutlet UIActivityIndicatorView *indicator;
    IBOutlet UIView *back_btn_view, *menu_btn_view;
}

@property (nonatomic, retain) NSString *title_str, *url_str;

-(IBAction)backAction:(id)sender;
-(IBAction)menuAction:(id)sender;

@end
