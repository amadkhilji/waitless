//
//  BrainTreeViewController.h
//  WaitlessPO
//
//  Created by Amad Khilji on 09/03/2014.
//  Copyright (c) 2014 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrainTreeViewController : UIViewController <UIWebViewDelegate> {
    
    IBOutlet UIWebView  *webView_container;
    NSString            *cardType, *maskedNumber;
    BOOL                didRegisterBrainTreeSuccessfully;
}

-(IBAction)backAction:(id)sender;

@end
