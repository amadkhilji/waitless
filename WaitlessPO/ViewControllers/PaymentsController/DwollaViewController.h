//
//  DwollaViewController.h
//  WaitlessPO
//
//  Created by Amad Khilji on 29/12/2013.
//  Copyright (c) 2013 Amad Khilji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DwollaAPI.h"
#import "DwollaOAuth2Client.h"
#import "HTTPRequest.h"

@interface DwollaViewController : UIViewController <IDwollaMessages, HTTPRequestDelegate> {
    
    DwollaOAuth2Client *dwollaOAuthClient;
    
    IBOutlet UIView *back_btn_view, *list_btn_view;
    IBOutlet UIView *webView_container;
    
    BOOL isUpdatingToken;
}

@property (atomic, assign) BOOL isModalPresentationStyle, shouldShowListButton;

-(IBAction)backAction:(id)sender;
-(IBAction)listAction:(id)sender;

@end
